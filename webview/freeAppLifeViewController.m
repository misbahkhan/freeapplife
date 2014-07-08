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
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "API.h"
#import "rewardCell.h"
#import "offerCell.h"
#import <StoreKit/StoreKit.h>
#import "offerPopUp.h"
#import "customPopUp.h"

@interface freeAppLifeViewController ()
{
    NSString *advertisingIdentifier;
    NSString *isAdvertisingTrackingEnabled;
    NSMutableData *body;
    NSUserDefaults *defaults;
    NSMutableArray *sponsorData, *goneFreeData, *imageLinks, *images, *social;
    int redirects;
    BOOL refreshing;
    BOOL outdated;
    UITextField *referralBox; 
    IBOutlet UILabel *points;
    IBOutlet UILabel *referral_count;
    UIAlertView *referralAlert;
    UIAlertView *versionAlert;
    UIAlertView *emailAlert;
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
    CustomIOS7AlertView *fblikealert;
    UIWebView *fblikewebview;
    BOOL loggedIn;
    BOOL redirectedToPage;
    BOOL liked;
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
    social = [[NSMutableArray alloc] init];
    goneFreeData = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] init];
    imageLinks = [[NSMutableArray alloc] init];
    
    body = [[NSMutableData alloc] init];
    redirects = 0;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    [_tableView registerClass:[offerCell class] forCellReuseIdentifier:@"offerCell"];
    [_tableView registerClass:[rewardCell class] forCellReuseIdentifier:@"rewardCell"];
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
    
//    UIWebView *pixel = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
//    [pixel loadHTMLString:@"<!-- Facebook Conversion Code for FreeAppLife --><script type=\"text/javascript\">var fb_param = {};fb_param.pixel_id = '6010056835246';fb_param.value = '0.01';fb_param.currency = 'USD';(function(){var fpw = document.createElement('script');fpw.async = true;fpw.src = '//connect.facebook.net/en_US/fp.js';var ref = document.getElementsByTagName('script')[0];ref.parentNode.insertBefore(fpw, ref);})();</script><noscript><img height=\"1\" width=\"1\" alt=\"\" style=\"display:none\" src=\"https://www.facebook.com/offsite_event.php?id=6010056835246&amp;value=0.01&amp;currency=USD\"/></noscript>" baseURL:nil];
//    [pixel setHidden:YES];
//    [self.view addSubview:pixel];
    
    fblikealert = [[CustomIOS7AlertView alloc] init];
    
    fblikewebview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, 300)];
    [fblikewebview.scrollView setScrollEnabled:NO];
    fblikewebview.delegate = self;
    [fblikewebview.scrollView.layer setCornerRadius:10.0f];
    [fblikewebview.scrollView clipsToBounds];
    [fblikewebview.layer setCornerRadius:10.0f];
    [fblikewebview clipsToBounds];
    [fblikealert setContainerView:fblikewebview];
    loggedIn = NO;
    redirectedToPage = NO;
    liked = NO;
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
    [social removeAllObjects];
    
    if(!([[[sharedInstance userData] objectForKey:@"twitter"] isEqualToString:@"DONE"])){
        NSDictionary *twitter = [[NSDictionary alloc] initWithObjectsAndKeys:@"popup", @"link", @"25", @"points", @"WATCH", @"description", @"Follow @FreeAppLife", @"name", @"https://freeapplife.com/fal/png/twitter_icon.png", @"image", @"custom", @"type", @"", @"html", @"158", @"height", @"twitter", @"meta", nil];
        [social addObject:twitter];
    }

    if(!([[[sharedInstance userData] objectForKey:@"facebook"] isEqualToString:@"DONE"])){
        NSDictionary *twitter = [[NSDictionary alloc] initWithObjectsAndKeys:@"popup", @"link", @"25", @"points", @"WATCH", @"description", @"Like FreeAppLife", @"name", @"https://freeapplife.com/fal/png/facebook_icon.png", @"image", @"custom", @"type", @"", @"html", @"158", @"height", @"facebook", @"meta", nil];
        [social addObject:twitter];
    }
    
    if([[[sharedInstance userData] objectForKey:@"email"] length]<1){
        NSDictionary *twitter = [[NSDictionary alloc] initWithObjectsAndKeys:@"popup", @"link", @"25", @"points", @"WATCH", @"description", @"Add a backup Email Address", @"name", @"https://freeapplife.com/fal/png/mail_icon.png", @"image", @"custom", @"type", @"", @"html", @"158", @"height", @"email", @"meta", nil];
        [social addObject:twitter];
    }
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
    }else if(alertView == emailAlert){
        if(buttonIndex == 1){
            UITextField *emailField = [alertView textFieldAtIndex:0];
            if([[emailField text] length] > 0){
                if ([[emailField text] rangeOfString:@"@"].location != NSNotFound) {
                    if ([[emailField text] rangeOfString:@"."].location != NSNotFound) {
                        NSString *postString = [NSString stringWithFormat:@"userID=%@&email=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]], [emailField text]];
                        NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"email" andBody:postString];
                        
                        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                            if([data length] > 0){
                                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                if([json objectForKey:@"status"]){
                                    [self removeMeta:@"email"];
                                }
                            }
                        }];
                    }else{
                    }
                }
            }
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
            NSLog(@"%@", strData);
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if([json objectForKey:@"status"]){
                referralAlert = [[UIAlertView alloc] initWithTitle:@"Get More Points!" message:@"If you were referred to FreeAppLife by a friend, input their referral code now to ensure that you both benefit. As a bonus, you'll start with 50 points!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add!", nil];
                referralAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                referralBox = [referralAlert textFieldAtIndex:0];
                [referralAlert show];
            }
        }
        
        [sharedInstance token];
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
                NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
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
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", strData);
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
                if([tmp count] < 1){
                    UIAlertView *noSponsors = [[UIAlertView alloc] initWithTitle:@"No Available Sponsors" message:@"Either you've completed all available offers or your region isn't currently supported. Thank you for your interest in FreeAppLife and follow us on both Twitter and Facebook for updates." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    [noSponsors show];
                }
                sponsorData = [tmp mutableCopy];
                sharedInstance.sponsorPayHelp = [dataDictionary objectForKey:@"spay_support"];
                sharedInstance.aarkiHelp = [dataDictionary objectForKey:@"aarki_support"];
                NSDictionary *popUp = [[NSDictionary alloc] initWithObjectsAndKeys:@"popup", @"link", @"0", @"points", @"WATCH", @"description", @"Install Tutorial", @"name", @"https://freeapplife.com/fal/png/store.png", @"image", @"custom", @"type", [NSString stringWithFormat:@"<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('yt',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='yt' type='text/html' width='%d' height='%d' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1&controls=0' frameborder='0'></body></html>", 280, 158, videoCode], @"html", @"158", @"height", nil];
                [sponsorData insertObject:popUp atIndex:0];
                for(int i = 0; i<[social count]; i++){
                    [sponsorData insertObject:[social objectAtIndex:i] atIndex:i+1];
                }
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
        rewardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rewardCell" forIndexPath:indexPath];
        if (cell == nil){
            cell = [[rewardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rewardCell"];
        }
        cell.data = currentData;
        [cell format]; 
        if([[currentData objectForKey:@"link"] isEqualToString:@"popup"]){
            title = [NSString stringWithFormat:@"%@", [currentData objectForKey:@"name"]];
        }
    
        cell.image.image = nil;
        
        if([[sharedInstance imageCache] objectForKey:[currentData objectForKey:@"image"]] > 0){
            cell.image.image = [UIImage imageWithData:[[sharedInstance imageCache] objectForKey:[currentData objectForKey:@"image"]]];
        }
        
        cell.label.text = title;
        
        if(screenWidth > 320){
            CGRect oldFrame = cell.label.frame;
            cell.label.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width + 300, oldFrame.size.height);
        }
        return cell;
    }else{
        offerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offerCell" forIndexPath:indexPath];
        if (cell == nil){
            cell = [[offerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"offerCell"];
        }

        cell.data = currentData;
        [cell format];
        
        cell.image.image = nil;
        
        if([[sharedInstance imageCache] objectForKey:[currentData objectForKey:@"image"]] > 0){
            cell.image.image = [UIImage imageWithData:[[sharedInstance imageCache] objectForKey:[currentData objectForKey:@"image"]]];
        }
        
        cell.label.text = title;
        
        if(screenWidth > 320){
            CGRect oldFrame = cell.label.frame;
            cell.label.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width + 300, oldFrame.size.height);
        }
        return cell;
    }

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
        offerView.preseneter = self; 
        offerView.web = _webView;
        [offerView show];
    }else if([type isEqualToString:@"custom"]){
        if([currentData objectForKey:@"meta"]){
            if([[currentData objectForKey:@"meta"] isEqualToString:@"twitter"]){
                [self getTwitterAccountInformation];
            }else if([[currentData objectForKey:@"meta"] isEqualToString:@"facebook"]){
                [fblikewebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.facebook.com/profile.php"]]];
            }else if([[currentData objectForKey:@"meta"] isEqualToString:@"email"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    emailAlert = [[UIAlertView alloc] initWithTitle:@"Add Email Address" message:@"Add a backup email address for 25 points!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                    emailAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [emailAlert show];
                });
            }
        }else{
            customPopUp *custom = [[customPopUp alloc] initWithFrame:CGRectMake(0, 0, 280, [[currentData objectForKey:@"height"] floatValue])];
            [custom.web loadHTMLString:[currentData objectForKey:@"html"] baseURL:nil];
            [custom show];
        }
    }
}

- (void) removeMeta:(NSString *)metaName
{
    for(int i = 0; i<5; i++){
        NSDictionary *current = [sponsorData objectAtIndex:i];
        if([current objectForKey:@"meta"]){
            if([[current objectForKey:@"meta"] isEqualToString:metaName]){
                [sponsorData removeObject:current];
                [social removeObject:current];
                [_tableView reloadData];
            }
        }
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
    if(webView == _webView){
        NSString *currentURL = webView.request.URL.absoluteString;
        if ([currentURL rangeOfString:@"preview"].location == NSNotFound) {
        } else {
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"input\")[1].click()"];
        }
    }else if(webView == fblikewebview){
        if (loggedIn != TRUE) {
            [fblikealert show];
        }
        
        if(redirectedToPage == TRUE){
            [webView
             stringByEvaluatingJavaScriptFromString:
             @"var isLiking = document.getElementsByClassName(\"_4g34\")[2].children[0].children[1].innerHTML; if(isLiking=='Like'){document.getElementsByClassName(\"_4g34\")[2].children[0].click()}"];
            NSString *postString = [NSString stringWithFormat:@"userID=%@&social=facebook", [sharedInstance md5ForString: [sharedInstance serialNumber]]];
            NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"social" andBody:postString];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){}];
            liked = TRUE;
        }
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
    if(webView == _webView){
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
    }else if(webView == fblikewebview){
        NSError *error = NULL;
        NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"itunes" options:NSRegularExpressionCaseInsensitive error:&error];
        NSUInteger regexNums2 = [regex2 numberOfMatchesInString:[[request URL] absoluteString] options:0 range:NSMakeRange(0, [[[request URL] absoluteString] length])];
        NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:@"r.php" options:NSRegularExpressionCaseInsensitive error:&error];
        NSUInteger regexNums3 = [regex3 numberOfMatchesInString:[[request URL] absoluteString] options:0 range:NSMakeRange(0, [[[request URL] absoluteString] length])];
        if(regexNums2 > 0 || regexNums3 > 0){
            return NO;
        }
        if(loggedIn == FALSE){
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"login.php" options:NSRegularExpressionCaseInsensitive error:&error];
            if (error){}
            NSUInteger regexNums = [regex numberOfMatchesInString:[[request URL] absoluteString] options:0 range:NSMakeRange(0, [[[request URL] absoluteString] length])];
            if(regexNums < 1 && ![[request.URL absoluteString] isEqualToString:@"http://www.facebook.com/profile.php"]){
                [fblikealert close];
                [self removeMeta:@"facebook"]; 
                loggedIn = TRUE;
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://facebook.com/freeapplife"]]];
                redirectedToPage = TRUE;
            }
        }
        return YES;
    }
    return YES;
}

- (void)getTwitterAccountInformation
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            //NSLog(@"granted");
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                [self fetchTimelineForUser:twitterAccount.username];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *connectTwitter = [[UIAlertView alloc] initWithTitle:@"Connect a Twitter Account" message:@"Plesase connect a Twitter account to your device first. To earn the credits go into Settings > Twitter and enter your credentials and sign in." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                    [connectTwitter show];
                });
            }
        }else{}
    }];
}

- (void)fetchTimelineForUser:(NSString *)username
{
    if ([self userHasAccessToTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType =
        [accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/friendships/create.json"];
                 NSDictionary *params = @{@"screen_name" : @"freeapplife",
                                          @"follow" : @"true"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                              URL:url
                                       parameters:params];
                 [request setAccount:[twitterAccounts firstObject]];
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              NSError *jsonError;
                              NSDictionary *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  [self retweet:@"443123073655398400"];
                                  NSString *postString = [NSString stringWithFormat:@"userID=%@&social=twitter", [sharedInstance md5ForString: [sharedInstance serialNumber]]];
                                  NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"social" andBody:postString];
                                  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                      if([data length] > 0){
                                          NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                          NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                          if([json objectForKey:@"status"]){
                                              [self removeMeta:@"twitter"];
                                          }
                                      }
                                  }];
                                  [sharedInstance tweet:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Score points at: https://freeapplife.com  #FAL #FreeAppLife"];
                              }else {}
                          }else {}
                      }
  }];}else {}}];}}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)retweet:(NSString *)tweetId
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com"
                                                    @"/1.1/statuses/retweet/%@.json", tweetId]];
                 //                 NSDictionary *params = @{@"screen_name" : @"freeapplife",
                 //                                          @"follow" : @"true"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                              URL:url
                                       parameters:nil];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts firstObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              NSDictionary *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  //                                  //NSLog(@"Timeline Response: %@\n", timelineData);
                                  //NSLog(@"user: %@", [[timelineData objectForKey:@"status"] objectForKey:@"id"]);
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  //NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              //NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 //NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
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
