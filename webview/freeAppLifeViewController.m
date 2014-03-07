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
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CommonCrypto/CommonHMAC.h>
#import "CXAlertView.h"
#import <dlfcn.h>
#import "API.h"
#import "rewardCell.h"
#import "CustomIOS7AlertView.h"

@interface freeAppLifeViewController ()
{
    NSString *advertisingIdentifier;
    NSString *isAdvertisingTrackingEnabled;
    NSMutableData *body;
    NSUserDefaults *defaults;
    NSMutableArray *sponsorData, *imageLinks, *images;
    int redirects;
    BOOL refreshing;
    UITextField *referralBox; 
    IBOutlet UILabel *points;
    IBOutlet UILabel *referral_count;
    CustomIOS7AlertView *sponsorClicked;
    API *sharedInstance;
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
    
    refreshing = FALSE;
    
    sponsorData = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] init];
    imageLinks = [[NSMutableArray alloc] init];
    
    body = [[NSMutableData alloc] init];
    redirects = 0;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    [_tableView registerClass:[rewardCell class] forCellReuseIdentifier:@"rewardCell"];
    
    defaults = [NSUserDefaults standardUserDefaults];
//    BOOL activated = [defaults boolForKey:@"activated"];
//    BOOL activated = TRUE; 
//    if(activated){
//        _waitView.hidden = YES;
//        NSLog(@"activated");
////        [self getSponsorPay];
//    }else{
//        advertisingIdentifier = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//        isAdvertisingTrackingEnabled = (NSClassFromString(@"ASIdentifierManager") && [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) ? @"YES" : @"NO";
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://www.freeapplife.com/fal/activate.php?APIKey=%@&enabled=%@", advertisingIdentifier, isAdvertisingTrackingEnabled]];
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//        [request setHTTPMethod:@"GET"];
//        [request setAllHTTPHeaderFields:@{@"User-Agent": [_webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]}];
//        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//        [connection start];
//    }
//    NSLog(@"idfa: %@", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
    [sharedInstance user]; 
    [self getSponsorPay];
    [self.view addSubview:[sharedInstance topBar]];
    
    UIImageView *featured = [[UIImageView alloc] initWithFrame:CGRectMake(20, 44, 280, 100)];
    [self.view addSubview:featured];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://freeapplife.com/fal/png/featured.png"]];
    [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            UIImage *image = [UIImage imageWithData:data];
            [featured setImage:image];
            [featured setContentMode:UIViewContentModeScaleAspectFit];
            featured.layer.cornerRadius = 5.0f;
            [featured setClipsToBounds:YES];
        }
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [sharedInstance user];
    [self.view addSubview:[sharedInstance topBar]];
//    NSLog(@"Appeared");
//    [_tableView reloadData];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    NSLog(@"refresh: %d", refreshing);
    if(refreshing == FALSE){
        NSLog(@"REFRESHED");
        [self getSponsorPay];
    }
    [refreshControl endRefreshing];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        NSLog(@"%@", [referralBox text]); 
        [sharedInstance refer:[referralBox text]];
    }
}

- (void) getAarki
{
    refreshing = TRUE;
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ar.aarki.net/garden?src=F0DD2C0C7EB3DCD6AA&advertising_id=10B36851-5C1C-4C1C-9973-B9B525A6598D&user_id=5bb186539e2729bb29950bc67a0c7435&offer_type=install"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"%@", dataArray);
            [sponsorData addObjectsFromArray:dataArray];
        }
        [sponsorData removeAllObjects];
        [images removeAllObjects];
        [imageLinks removeAllObjects];
//        [_tableView reloadData];
        [self getSponsorPay];
        
        // This will get the NSURLResponse into NSHTTPURLResponse format
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        // This will Fetch the status code from NSHTTPURLResponse object
        int responseStatusCode = [httpResponse statusCode];
        
        //Just to make sure, it works or not
        NSLog(@"Status Code :: %d", responseStatusCode);
    }];
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (NSString *)serialNumber
{
	NSString *serialNumber = nil;
	
	void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
	if (IOKit)
	{
		mach_port_t *kIOMasterPortDefault = dlsym(IOKit, "kIOMasterPortDefault");
		CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
		mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
		CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(IOKit, "IORegistryEntryCreateCFProperty");
		kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(IOKit, "IOObjectRelease");
		
		if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease)
		{
			mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
			if (platformExpertDevice)
			{
				CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
				if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
				{
					serialNumber = [NSString stringWithString:(__bridge NSString*)platformSerialNumber];
					CFRelease(platformSerialNumber);
				}
				IOObjectRelease(platformExpertDevice);
			}
		}
		dlclose(IOKit);
	}
	
	return serialNumber;
}

- (void) getSponsorPay
{
    refreshing = TRUE;
    NSLog(@"getting sponsorpay");
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://freeapplife.com"]]];
//    NSString *API = @"0642980c502cfff5b6d2909b6c1420187872aec5";

//    NSString *queryString = [NSString stringWithFormat:@"appid=17956&apple_idfa=%@&apple_idzfa_tracking_enabled=YES&device=phone&ip=%@&locale=en&offer_types=101&timestamp=%.0f&uid=asdf&", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString], [self getIPAddress], [[NSDate date] timeIntervalSince1970]];
    
//    NSString *finalString = [queryString stringByAppendingString:[@"&hashkey=" stringByAppendingString:[self sha1:[queryString stringByAppendingString:API]]]];
    
//    NSString *SponsorPayURL = [NSString stringWithFormat:@"http://api.sponsorpay.com/feed/v1/offers.json?%@", finalString];
    
    
    NSString *SponsorPayURL = [NSString stringWithFormat:@"http://freeapplife.com/api/offers?userID=%@&idfa=%@", [self serialNumber], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SponsorPayURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dataDictionary);
        // This will get the NSURLResponse into NSHTTPURLResponse format
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        // This will Fetch the status code from NSHTTPURLResponse object
        int responseStatusCode = [httpResponse statusCode];
        
        //Just to make sure, it works or not
        NSLog(@"Status Code :: %d", responseStatusCode);
        if(responseStatusCode == 200){
            [sponsorData removeAllObjects];
            [images removeAllObjects];
            [imageLinks removeAllObjects];
        
            [sponsorData addObjectsFromArray:[dataDictionary objectForKey:@"offers"]];
            [_tableView reloadData];
            [self getImages];
        }else{
            refreshing = FALSE;
        }
    }];
}

- (void) getImages{
    for(int i = 0; i<[sponsorData count]; i++){
        NSDictionary *thisOne = [sponsorData objectAtIndex:i];
        NSURL *imageURL = [[NSURL alloc] init];
        if([thisOne objectForKey:@"image_url"]){
            imageURL = [NSURL URLWithString:[thisOne objectForKey:@"image_url"]];
        }else{
            imageURL = [NSURL URLWithString:[[thisOne objectForKey:@"thumbnail"] objectForKey:@"hires"]];
        }
        [imageLinks addObject:imageURL];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        for (int i = 0; i<[imageLinks count]; i++){
            NSData *tempImageData = [NSData dataWithContentsOfURL:[imageLinks objectAtIndex:i]];
            UIImage *image = [UIImage imageWithData:tempImageData];
            [images addObject:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
        refreshing = FALSE;
    });
}

- (void) appVideoToggle:(id)sender
{
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//        NSString *CellIdentifier = @"app";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *currentData = [sponsorData objectAtIndex:indexPath.row];
    NSString *title = ([currentData objectForKey:@"title"] > [currentData objectForKey:@"name"] ? [currentData objectForKey:@"title"] : [currentData objectForKey:@"name"]);

    title = [NSString stringWithFormat:@"%@\n%@ points", title, [currentData objectForKey:@"payout"]];
//        return cell;
    
    rewardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rewardCell" forIndexPath:indexPath];
    cell.label.text = title; 
    cell.image.image = nil;
    cell.data = currentData;
    if([images count]>indexPath.row){
        cell.image.image = [images objectAtIndex:indexPath.row];
        cell.image.layer.cornerRadius = 10.0f;
        cell.image.clipsToBounds = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    redirects = 0;
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    rewardCell *currentCell = (rewardCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, 210, 240, 10)];
    [_progress setProgress:0.0f];
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
    [progressView addSubview:_progress];
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 225)];
    [cellView setBackgroundColor:[UIColor clearColor]];
    [cellView addSubview:progressView];

    NSString *title = [currentCell.data objectForKey:@"title"];
    NSString *instruct = [currentCell.data objectForKey:@"required_actions"];
    instruct = [NSString stringWithFormat:@"Instructions: %@", instruct];
    
    NSString *guide = @"Make sure to keep the app open for 30 seconds and not switch networks (e.g. WiFi > 3G).";
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 20, 160, 20)];
    [titleLabel setText:title];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [titleLabel setNumberOfLines:1];
//    [titleLabel sizeToFit];
    CGRect titleFrame = titleLabel.frame;
    titleLabel.frame = titleFrame;
    [cellView addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 59)];
    imageView.image = currentCell.image.image;
    imageView.layer.cornerRadius = 10.0f;
    [imageView setClipsToBounds:YES];
    [cellView addSubview:imageView];
    
    UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(90, titleFrame.size.height+20, 190, 120)];
    [instructions setText:instruct];
    [instructions setNumberOfLines:3];
    [instructions sizeToFit];
    [cellView addSubview:instructions];
    
    UILabel *guidelines = [[UILabel alloc] initWithFrame:CGRectMake(20, titleFrame.size.height+80, 240, 120)];
    [guidelines setText:guide];
    [guidelines setNumberOfLines:5];
    [guidelines setFont: [UIFont fontWithName:@"Helvetica Neue" size:15.0f]];
    [guidelines setTextAlignment:NSTextAlignmentCenter];
    [guidelines sizeToFit];
    [cellView addSubview:guidelines];
    
//    NSLog(@"%@", currentCell.data);
    
//    sponsorClicked = [[CXAlertView alloc] initWithTitle:title contentView:cellView cancelButtonTitle:@"Cancel"];
//    [sponsorClicked addButtonWithTitle:@"Continue" type:CXAlertViewButtonTypeCustom handler:
//     ^(CXAlertView *alertView, CXAlertButtonItem *button) {
//         [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[sponsorData objectAtIndex:indexPath.row] objectForKey:@"link"]]]];
//     }
//     ];
//    [sponsorClicked show];
    
    sponsorClicked = [[CustomIOS7AlertView alloc] init];
    sponsorClicked.delegate = self;
    [sponsorClicked setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Continue", nil]];
    [sponsorClicked setContainerView:cellView];
    [sponsorClicked setUseMotionEffects:TRUE];
    UIWebView *web = _webView;
    NSString *URL = [[sponsorData objectAtIndex:indexPath.row] objectForKey:@"link"];
    [sponsorClicked show];
    [sponsorClicked setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        if(buttonIndex == 0){
            [alertView close];
        }else if(buttonIndex == 1) {
            UIButton *button = (UIButton *)[[[[alertView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
            if(![button.titleLabel.text isEqualToString:@"Loading"]){
                [button setTitle:@"Loading" forState:UIControlStateNormal];
                [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
            }
        }
    }];
}

- (void) loadRequest:(NSString *)string
{
    
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if ([alertView tag]==0) {
        if(buttonIndex == 0){
            [_webView stopLoading];
        }
        if(buttonIndex == 1){

        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sponsorData count];
}

- (void) plus
{
    [_progress setProgress:_progress.progress+0.2f animated:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    [self plus];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    NSLog(@"request: %@", [request URL]);
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self plus];
    BOOL status = TRUE;
    [defaults setBool:status forKey:@"activated"];
    [defaults synchronize];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"itunes.apple.com" options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    NSUInteger regexNums = [regex numberOfMatchesInString:[[request URL] absoluteString] options:0 range:NSMakeRange(0, [[[request URL] absoluteString] length])];
//    NSLog(@"request: %@", [request URL]);
    if(regexNums > 0){
        [sponsorClicked close];
    }
    redirects++;
    [_progress setProgress:redirects*0.15];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
