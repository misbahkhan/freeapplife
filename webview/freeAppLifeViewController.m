//
//  freeAppLifeViewController.m
//  webview
//
//  Created by Adrian D'Urso on 1/11/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "freeAppLifeViewController.h"
#import <AdSupport/ASIdentifierManager.h>
#import <QuartzCore/QuartzCore.h>
#import "API.h"
#import "rewardCell.h"
#import <StoreKit/StoreKit.h>
#import "offerPopUp.h"
#import "customPopUp.h"

@interface freeAppLifeViewController ()
{
    NSString *advertisingIdentifier;
    NSString *isAdvertisingTrackingEnabled;
    NSMutableData *body;
    NSUserDefaults *defaults;
    NSMutableArray *sponsorData, *goneFreeData, *imageLinks, *images;
    int redirects;
    BOOL refreshing;
    BOOL outdated;
    UITextField *referralBox; 
    IBOutlet UILabel *points;
    IBOutlet UILabel *referral_count;
    UIAlertView *referralAlert;
    UIAlertView *versionAlert;
    API *sharedInstance;
    UIWebView *video;
    NSString *aarkiHelp;
    NSString *videoCode;
    UIRefreshControl *refreshControl;
    offerPopUp *offerView;
    int sep;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@end

@implementation freeAppLifeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedInstance = [API sharedInstance];
    CGRect alpha = CGRectMake(0, 0, 320, 22);
    UIView *alphaView = [[UIView alloc] initWithFrame:alpha];
    [alphaView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.65f]];
    [self.view addSubview:alphaView];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    sep = 0;
    
    refreshing = FALSE;
    
    sponsorData = [[NSMutableArray alloc] init];
    goneFreeData = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] init];
    imageLinks = [[NSMutableArray alloc] init];
    
    body = [[NSMutableData alloc] init];
    redirects = 0;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    [_tableView registerClass:[rewardCell class] forCellReuseIdentifier:@"rewardCell"];
    [_tableView registerClass:[rewardCell class] forCellReuseIdentifier:@"tutorialCell"];
    _tableView.delegate = self;
    
    [self featuredImage];
    [self videoCode];
    
    UIView *topBar = [sharedInstance getBar];
    [self.view addSubview:topBar];
    
    _pointsLabel = [sharedInstance getPoints];
    [self.view addSubview:_pointsLabel];
    
    UIButton *refresh = [[UIButton alloc]initWithFrame:CGRectMake(5, 23, 34, 19)];
    [refresh setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [refresh addTarget:sharedInstance action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:[sharedInstance notificationName] object:nil];

    [self registerUser];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [UIColor lightGrayColor];
    
    int heightSubtractor = 44;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        heightSubtractor = 20;
    }
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, screenHeight-_tableView.frame.origin.y-heightSubtractor);
}

- (void) viewDidAppear:(BOOL)animated
{
    [sharedInstance user];
//    [_tableView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated
{

}

- (void) dataUpdated:(id)sender
{
    _pointsLabel.text = [sharedInstance currentPoints];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    //NSLog(@"refresh: %d", refreshing);
//    if(refreshing == FALSE){
        //NSLog(@"REFRESHED");
        [self aggregateOffers];
//    }
//    [refreshControl endRefreshing];
}

- (void) changeTab{
    if([[[sharedInstance userData] objectForKey:@"link"] length] > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[sharedInstance userData] objectForKey:@"link"]]];
    }else{
        int tab = [[[sharedInstance userData] objectForKey:@"tab"] intValue];
        [self.tabBarController setSelectedIndex:tab];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView == referralAlert){
        if(buttonIndex == 1){
            [sharedInstance refer:[referralBox text]];
        }
    }else if(alertView == versionAlert){
        if(buttonIndex == 0){
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            exit(0);
        }else if(buttonIndex == 1){
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [sharedInstance appURL]]];
        }
    }
}

- (void) registerUser
{
    NSArray *a = [sharedInstance makeForData:[sharedInstance serialNumber]];
    NSString *postString = [NSString stringWithFormat:@"sn=%@&a=%@&t=%@", [sharedInstance serialNumber], [a objectAtIndex:0], [a objectAtIndex:1]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"register" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@", strData);
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if([json objectForKey:@"status"]){
                referralAlert = [[UIAlertView alloc] initWithTitle:@"Get More Points!" message:@"If you were referred to FreeAppLife by a friend, input their referral code now and earn an excess of 400 points to be rewarded." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add!", nil];
                referralAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                referralBox = [referralAlert textFieldAtIndex:0];
                [referralAlert show];
            }
        }
        
        [sharedInstance token];
        Log(@"%@", [sharedInstance deviceToken]);
        [self version];
        
    }];
    
}

- (void) videoCode
{
    NSMutableURLRequest *request3 = [sharedInstance requestForEndpoint:@"video" andBody:nil];
    [NSURLConnection sendAsynchronousRequest:request3 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            videoCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }];
}

- (void) version
{
    NSString *postString = [NSString stringWithFormat:@"u=%@&v=%.2f", [sharedInstance md5ForString:[sharedInstance serialNumber]], [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]];
    NSMutableURLRequest *request2 = [sharedInstance requestForEndpoint:@"version" andBody:postString];
    [NSURLConnection sendAsynchronousRequest:request2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self aggregateOffers];
    }];
}

- (void) featuredImage
{
    UIButton *featured = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth/2)-140, 44, 280, 100)];
    [self.view addSubview:featured];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://freeapplife.com/fal/png/featured.png"]];
    [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            UIImage *image = [UIImage imageWithData:data];
            [featured setBackgroundImage:image forState:UIControlStateNormal];
            [featured addTarget:self action:@selector(changeTab) forControlEvents:UIControlEventTouchUpInside];
            [featured setContentMode:UIViewContentModeScaleAspectFit];
            featured.layer.cornerRadius = 5.0f;
            [featured setClipsToBounds:YES];
        }
    }];
}

- (void) pendingOffers
{
    NSString *postString = [NSString stringWithFormat:@"userID=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"pendingList" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int responseStatusCode = [httpResponse statusCode];
            
            if(responseStatusCode == 200){
                NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:[dataDictionary objectForKey:@"pendingList"]];
                if([tmp count] > 0){
                    [sponsorData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"separator", @"type", nil]];
                    sep = [sponsorData count]-1;
                }
                [sponsorData addObjectsFromArray:tmp];
                [_tableView reloadData];
                [self getImages];
            }
        }
    }];
}

- (void) aggregateOffers
{
    refreshing = TRUE;
    NSString *postString = [NSString stringWithFormat:@"userID=%@&idfa=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    
    #ifdef DEBUG
        NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"offersSorted" andBody:postString];
    #else
        NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"offersSorted" andBody:postString];
    #endif
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            // This will get the NSURLResponse into NSHTTPURLResponse format
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            
            // This will Fetch the status code from NSHTTPURLResponse object
            int responseStatusCode = [httpResponse statusCode];
            
            //Just to make sure, it works or not
//            NSLog(@"Status Code :: %d", responseStatusCode);
            [images removeAllObjects];
            [imageLinks removeAllObjects];
            
            if(responseStatusCode == 200){
                NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:[dataDictionary objectForKey:@"offers"]];
                sponsorData = [tmp mutableCopy];
                sharedInstance.sponsorPayHelp = [dataDictionary objectForKey:@"spay_support"];
                sharedInstance.aarkiHelp = [dataDictionary objectForKey:@"aarki_support"];
                NSDictionary *popUp = [[NSDictionary alloc] initWithObjectsAndKeys:@"popup", @"link", @"0", @"payout", @"WATCH", @"description", @"Install Tutorial", @"name", @"https://freeapplife.com/fal/png/store.png", @"image", @"custom", @"type", [NSString stringWithFormat:@"<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('yt',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='yt' type='text/html' width='%d' height='%d' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1&controls=0' frameborder='0'></body></html>", 280, 158, videoCode], @"html", @"158", @"height", nil];
                [sponsorData insertObject:popUp atIndex:0];
                [_tableView reloadData];
//                [self getImages];
//                [self goneFreeList];
                [self pendingOffers];
            }else{
                refreshing = FALSE;
            }
        }
    }];
}

- (void) goneFreeList {
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"goneFreeList" andBody:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int responseStatusCode = (int)[httpResponse statusCode];
            if(responseStatusCode == 200){
//                NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:[dataDictionary objectForKey:@"goneFree"]];
//                NSLog(@"%@", dataDictionary);
            }else{
//                refreshing = FALSE;
            }
        }
    }];
}

- (void) getImages {
    [refreshControl endRefreshing];
    for (int i = 0; i < [sponsorData count]; i++) {
        NSString *URL = [[sponsorData objectAtIndex:i] objectForKey:@"image"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
        request.URL = [NSURL URLWithString:URL];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
               if([data length] > 0){
                   [sharedInstance.imageCache setObject:data forKey:URL];
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                   });
               }else{
                   //NSLog(@"NO DATA");
               }
           }];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == sep && sep>0){
        return 30.0f;
    }
    return 102.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentData = [sponsorData objectAtIndex:indexPath.row];
    
    if([[currentData objectForKey:@"type"] isEqualToString:@"separator"]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalCell"];
        }
        cell.textLabel.text = @"Pending Offers";
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        return cell;
    }
    
    NSString *title = [currentData objectForKey:@"name"];
    
    NSString *pointsLabel;
    pointsLabel = [NSString stringWithFormat:@"+ %@", [currentData objectForKey:@"points"]];
    
    if([currentData objectForKey:@"completed"] > 0){
        pointsLabel = @"PENDING";
    }
    
    if([currentData objectForKey:@"link"]>0){
        if([[currentData objectForKey:@"link"] isEqualToString:@"popup"]){
            title = [NSString stringWithFormat:@"%@", [currentData objectForKey:@"name"]];
            pointsLabel = @"";
        }
    }
    
    rewardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rewardCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[rewardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rewardCell"];
    }
    
    cell.points.text = pointsLabel;
    [cell.points sizeToFit];
    CGRect oldFrame = cell.points.frame;
    oldFrame.size.width = oldFrame.size.width+20;
    oldFrame.size.height = oldFrame.size.height+10;
    oldFrame.origin.x = 280-oldFrame.size.width;
    oldFrame.origin.x += 20;
    oldFrame.origin.y = 21+((60-oldFrame.size.height)/2);

    if(screenWidth > 320){
        oldFrame.origin.x = screenWidth-75;
    }

    cell.points.frame = oldFrame;
    cell.image.image = nil;
    
    if([[sharedInstance imageCache] objectForKey:[currentData objectForKey:@"image"]] > 0){
        cell.image.image = [UIImage imageWithData:[[sharedInstance imageCache] objectForKey:[currentData objectForKey:@"image"]]];
    }

    cell.data = currentData;
    cell.label.text = title;
    
    if(screenWidth > 320){
        CGRect oldFrame = cell.label.frame;
        cell.label.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width + 300, oldFrame.size.height);
    }
    return cell;
}

- (void) sponsorPayHelpClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sharedInstance.sponsorPayHelp]];
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    redirects = 0;
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *currentData = [sponsorData objectAtIndex:indexPath.row];
    NSString *type = [currentData objectForKey:@"type"];
    
    if([type isEqualToString:@"separator"]){
        [table deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if([type isEqualToString:@"offer"] || [type isEqualToString:@"pending"]){
        offerView = [[offerPopUp alloc] initWithData:currentData];
        offerView.web = _webView;
        [offerView show];
    }else if([type isEqualToString:@"custom"]){
        customPopUp *custom = [[customPopUp alloc] initWithFrame:CGRectMake(0, 0, 280, [[currentData objectForKey:@"height"] floatValue])];
        [custom.web loadHTMLString:[currentData objectForKey:@"html"] baseURL:nil];
        [custom show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sponsorData count];
}

- (void) plus
{
    [offerView.progress setProgress:_progress.progress+0.2f animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self plus];
    BOOL status = TRUE;
    [defaults setBool:status forKey:@"activated"];
    [defaults synchronize];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *currentURL = webView.request.URL.absoluteString;
    if ([currentURL rangeOfString:@"preview"].location == NSNotFound) {
    } else {
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"input\")[1].click()"];
    }
}

- (void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [offerView afterMessage];
    [self dismissViewControllerAnimated:NO completion:^{
        [offerView show];
    }];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"itunes.apple.com" options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger regexNums = [regex numberOfMatchesInString:[[request URL] absoluteString] options:0 range:NSMakeRange(0, [[[request URL] absoluteString] length])];
    
    
    if(regexNums > 0){
        [offerView afterMessage];
        return YES;
    }
    redirects++;
    [offerView.progress setProgress:redirects*0.1];
    return YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
