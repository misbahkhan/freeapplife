//
//  videoViewController.m
//  FreeAppLife
//
//  Created by Misbah Khan on 7/3/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "videoViewController.h"
#import "API.h"
#import <AdSupport/AdSupport.h>
#import "offerCell.h"

@interface videoViewController ()
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
    API *sharedInstance;
    UIWebView *video;
    NSString *aarkiHelp;
    NSString *videoCode;
    UIRefreshControl *refreshControl;
    int sep;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
    UIWebView *fblikewebview;
    BOOL loggedIn;
    BOOL redirectedToPage;
    BOOL liked;
}


@end

@implementation videoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedInstance = [API sharedInstance];
    [_table registerClass:[offerCell class] forCellReuseIdentifier:@"offerCell"];
    [self videoOffers];
    [_web setAllowsInlineMediaPlayback:YES];
    [_web setDelegate:self];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [_table addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(videoOffers) forControlEvents:UIControlEventAllEvents];
    // Do any additional setup after loading the view.
}

- (void) videoOffers
{
//    refreshing = TRUE;
    NSString *postString = [NSString stringWithFormat:@"userID=%@&idfa=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"offersVideo" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@", strData);
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

                [_table reloadData];
                [self getImages];
            }else{
                refreshing = FALSE;
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
                                           [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                       });
                                   }else{
                                       //NSLog(@"NO DATA");
                                   }
                               }];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sponsorData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentData = [sponsorData objectAtIndex:indexPath.row];
    
    NSString *title = [currentData objectForKey:@"name"];
    
    NSString *pointsLabel;
    pointsLabel = [NSString stringWithFormat:@"+ %@", [currentData objectForKey:@"points"]];
       
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

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", request.URL);
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"finished");
//    [_web stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"video\")[0].setAttribute(\"webkit-playsinline\", \"\");"];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *current = [sponsorData objectAtIndex:indexPath.row];
    NSString *url = [current objectForKey:@"url"];
    NSLog(@"%@", url); 
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_web loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
