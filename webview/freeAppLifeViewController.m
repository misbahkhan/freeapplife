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
    BOOL outdated;
    UITextField *referralBox; 
    IBOutlet UILabel *points;
    IBOutlet UILabel *referral_count;
    CustomIOS7AlertView *sponsorClicked;
    UIAlertView *referralAlert;
    UIAlertView *versionAlert;
    API *sharedInstance;
    UIWebView *video;
    NSString *sponsorPayHelp;
    NSString *aarkiHelp;
    NSString *videoCode;
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
    
    UIButton *featured = [[UIButton alloc] initWithFrame:CGRectMake(20, 44, 280, 100)];
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
    
    NSLog(@"advertising: %@", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
    
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
    NSString *postString = [NSString stringWithFormat:@"u=%@&v=%@", [sharedInstance md5ForString:[sharedInstance serialNumber]], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
//    NSLog(@"%@", postString);
    NSMutableURLRequest *request2 = [sharedInstance requestForEndpoint:@"version" andBody:postString];
    [NSURLConnection sendAsynchronousRequest:request2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data: %@", strData);
            
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if([[json objectForKey:@"error"] isEqualToString:@"wrong version"]){
                outdated = YES;
                versionAlert = [[UIAlertView alloc] initWithTitle:@"Old Version" message:@"You're currently running an outdated version of FreeAppLife, please update now." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
                [versionAlert show];
            }else{
                [self newAarki];
            }
        }
    }];
    
    NSMutableURLRequest *request3 = [sharedInstance requestForEndpoint:@"video" andBody:nil];
    [NSURLConnection sendAsynchronousRequest:request3 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            videoCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [sharedInstance user];
//    [_tableView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [sponsorClicked close];
}

- (void) dataUpdated:(id)sender
{
    _pointsLabel.text = [sharedInstance currentPoints];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    NSLog(@"refresh: %d", refreshing);
    if(refreshing == FALSE){
        NSLog(@"REFRESHED");
        [self newAarki];
    }
    [refreshControl endRefreshing];
}

- (void) changeTab{
    NSLog(@"change tab");
    int tab = [[[sharedInstance userData] objectForKey:@"tab"] intValue];
    [self.tabBarController setSelectedIndex:tab];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView == referralAlert){
        if(buttonIndex == 1){
            NSLog(@"%@", [referralBox text]);
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
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://freeapplife.com/api/register"]];
    //    [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
    //    [request setHTTPMethod:@"POST"];
    //    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray *a = [sharedInstance makeForData:[sharedInstance serialNumber]];
    NSString *postString = [NSString stringWithFormat:@"sn=%@&a=%@&t=%@", [sharedInstance serialNumber], [a objectAtIndex:0], [a objectAtIndex:1]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"register" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSLog(@"%@", response);
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", strData);
            //            NSError *error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if([json objectForKey:@"status"]){
                referralAlert = [[UIAlertView alloc] initWithTitle:@"Get More Points!" message:@"If you were referred to FreeAppLife by a friend, input their referral code now and earn an excess of 400 points to be rewarded." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add!", nil];
                referralAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                referralBox = [referralAlert textFieldAtIndex:0];
                [referralAlert show];
            }
        }
    }];
    
}

- (void) getAarki
{
    refreshing = TRUE;
//    NSString *SponsorPayURL = [NSString stringWithFormat:@"http://freeapplife.com/api/offers?userID=%@&idfa=%@", [self serialNumber], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
//    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"register" andBody:@"aarki"];
    
    NSString *postString = [NSString stringWithFormat:@"userID=%@&idfa=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"aarki" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            //B3C14AA3-862C-4120-ADA1-295FC5250092
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"%@", dataArray);
            [sponsorData addObjectsFromArray:dataArray];
        }
        [sponsorData removeAllObjects];
        [images removeAllObjects];
        [imageLinks removeAllObjects];
        [_tableView reloadData];
        [self getSponsorPay];
        
        // This will get the NSURLResponse into NSHTTPURLResponse format
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        // This will Fetch the status code from NSHTTPURLResponse object
        int responseStatusCode = [httpResponse statusCode];
        
        //Just to make sure, it works or not
        NSLog(@"Status Code :: %d", responseStatusCode);
    }];
}

- (void) getSponsorPay
{
    refreshing = TRUE;
    NSLog(@"getting sponsorpay");
    //    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://freeapplife.com"]]];
    
    NSString *postString = [NSString stringWithFormat:@"userID=%@&idfa=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"offers" andBody:postString];

    
//    NSString *SponsorPayURL = [NSString stringWithFormat:@"http://freeapplife.com/api/offers?userID=%@&idfa=%@", [self serialNumber], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dataDictionary);
        // This will get the NSURLResponse into NSHTTPURLResponse format
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        // This will Fetch the status code from NSHTTPURLResponse object
        int responseStatusCode = [httpResponse statusCode];
        
        //Just to make sure, it works or not
        NSLog(@"Status Code :: %d", responseStatusCode);
        [images removeAllObjects];
        [imageLinks removeAllObjects];
        
        if(responseStatusCode == 200){
//            [sponsorData addObjectsFromArray:d[dataDictionary objectForKey:@"offers"]];
            sponsorPayHelp = [[dataDictionary objectForKey:@"information"] objectForKey:@"support_url"];
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:[dataDictionary objectForKey:@"offers"]];
            [tmp addObjectsFromArray:sponsorData];
            sponsorData = [tmp mutableCopy];
            NSDictionary *popUp = [[NSDictionary alloc] initWithObjectsAndKeys:@"popup", @"link", @"0", @"payout", @"WATCH", @"required_actions", @"Install Tutorial", @"title", @"https://freeapplife.com/fal/png/store.png", @"image_url", nil];
            [sponsorData insertObject:popUp atIndex:0];
            [_tableView reloadData];
        }else{
            refreshing = FALSE;
        }
        
        [self getImages];
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

- (void) newAarki
{
    refreshing = TRUE;
    NSLog(@"getting aarki");
    
    NSString *postString = [NSString stringWithFormat:@"userID=%@&idfa=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"aarki" andBody:postString];
    
//    NSString *aarki = [NSString stringWithFormat:@"http://freeapplife.com/api/aarki?userID=%@&idfa=%@", [self serialNumber], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSMutableArray *filteredData = [dataArray mutableCopy];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        
        NSLog(@"%@", filteredData);
        // This will get the NSURLResponse into NSHTTPURLResponse format
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        // This will Fetch the status code from NSHTTPURLResponse object
        int responseStatusCode = [httpResponse statusCode];
        
        //Just to make sure, it works or not
        NSLog(@"Status Code :: %d", responseStatusCode);
        
        [sponsorData removeAllObjects];
        [images removeAllObjects];
        [imageLinks removeAllObjects];
        
        if(responseStatusCode == 200){
            for(int i = 0; i<[filteredData count]; i++){
                if([[[filteredData objectAtIndex:i] objectForKey:@"purchase"] integerValue] == 1){
                    [toRemove addObject:[filteredData objectAtIndex:i]];
                }
            }
            
            for(int i = 0; i<[toRemove count]; i++){
                [filteredData removeObject:[toRemove objectAtIndex:i]];
            }
            [sponsorData addObjectsFromArray:filteredData];
        }else{
            [sponsorData removeAllObjects];
            refreshing = FALSE;
        }
        [_tableView reloadData];
        [self getSponsorPay];
    }];
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
            if([[[imageLinks objectAtIndex:i] absoluteString] isEqualToString:@"https://freeapplife.com/fal/png/store.png"]){
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[imageLinks objectAtIndex:i]];
                [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
                NSURLResponse *response;
                NSError *error = nil;
                NSData* data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
                UIImage *image = [UIImage imageWithData:data];
                [images addObject:image];
            }else{
                NSData *tempImageData = [NSData dataWithContentsOfURL:[imageLinks objectAtIndex:i]];
                UIImage *image = [UIImage imageWithData:tempImageData];
                [images addObject:image];
            }
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
    
    BOOL isAarki = false;
    
    NSDictionary *currentData = [sponsorData objectAtIndex:indexPath.row];
    NSString *title = ([currentData objectForKey:@"title"] > [currentData objectForKey:@"name"] ? [currentData objectForKey:@"title"] : [currentData objectForKey:@"name"]);

    if([title length]>17){
        title = [title substringToIndex: MIN(17, [title length])];
        title = [title stringByAppendingString:@"..."];
    }
    
    if([currentData objectForKey:@"url"] > 0){
        NSString *url = [currentData objectForKey:@"url"];
        NSError  *error  = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"aarki" options:0 error:&error];
        NSRange range   = [regex rangeOfFirstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
        NSString *result = [url substringWithRange:range];
        
        if ([result length]>0) {
            isAarki = true;
        }
    }
    
    if(isAarki){
        title = [NSString stringWithFormat:@"%@\n%@", title, [currentData objectForKey:@"reward"]];
    }else{
        title = [NSString stringWithFormat:@"%@\n%@ points", title, [currentData objectForKey:@"payout"]];
    }
    
    if([currentData objectForKey:@"link"]>0){
        if([[currentData objectForKey:@"link"] isEqualToString:@"popup"]){
            title = [NSString stringWithFormat:@"%@", [currentData objectForKey:@"title"]];
        }
    }
    

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

- (void) sponsorPayHelpClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sponsorPayHelp]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    redirects = 0;
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    rewardCell *currentCell = (rewardCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, 240, 240, 10)];
    [_progress setProgress:0.0f];
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
    [progressView addSubview:_progress];
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 275)];
    [cellView setBackgroundColor:[UIColor clearColor]];
    [cellView addSubview:progressView];

    NSString *title;
    if([currentCell.data objectForKey:@"name"] > 0){
        title = [currentCell.data objectForKey:@"name"];
    }else{
        title = [currentCell.data objectForKey:@"title"];
    }
    
    NSString *guide = @"Remember to open the app for a minimum of 30 seconds and do not switch networks (e.g. 3G, LTE > Wi-Fi). Some offers may take up to 24 hours to credit to your account.";
    
    NSString *credit = @"Some offers may take up to 24 hours to credit to your account.";
    
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
    [instructions setNumberOfLines:3];
    NSString *instruct;
    
    if([currentCell.data objectForKey:@"ad_copy"] > 0){
        instruct = [currentCell.data objectForKey:@"ad_copy"];
        [instructions setNumberOfLines:6];
        [instructions setFont: [UIFont fontWithName:@"Helvetica Neue" size:11.0f]];
    }else{
        UIButton *helpLabel = [[UIButton alloc] initWithFrame:CGRectMake(20, titleFrame.size.height+180, 240, 20)];
        [helpLabel setTitle:@"Missing Points? Tap for Help!" forState:UIControlStateNormal];
        [helpLabel.titleLabel setFont: [UIFont fontWithName:@"Helvetica Neue" size:13.0f]];
        [helpLabel setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [helpLabel addTarget:self action:@selector(sponsorPayHelpClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cellView addSubview:helpLabel];
        
        instruct = [currentCell.data objectForKey:@"required_actions"];
    }
    
    instruct = [NSString stringWithFormat:@"Instructions: %@", instruct];
    [instructions setText:instruct];
    [instructions sizeToFit];
    [cellView addSubview:instructions];
    
    UILabel *guidelines = [[UILabel alloc] initWithFrame:CGRectMake(20, titleFrame.size.height+100, 240, 120)];
    [guidelines setText:guide];
    [guidelines setNumberOfLines:5];
    [guidelines setFont: [UIFont fontWithName:@"Helvetica Neue" size:13.0f]];
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
    
    
    if([currentCell.data objectForKey:@"link"]>0){
        if([[currentCell.data objectForKey:@"link"] isEqualToString:@"popup"]){
            [guidelines removeFromSuperview];
            [progressView removeFromSuperview];
            [sponsorClicked setButtonTitles:[NSMutableArray arrayWithObjects:@"Get Started", nil]];
            video = [[UIWebView alloc] initWithFrame:CGRectMake(0, 90, 280, 158)];
            
//            [video loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://freeapplife.com/fal/video.html"]]];
//            [video loadHTMLString:@"<style type=\"text/css\">body{margin:0;padding:0;}</style><iframe width=“280” height=“158” src=\"http://www.youtube.com/embed/OlHeQpzxtTM?rel=0\" frameborder=\"0\" allowfullscreen></iframe>" baseURL:nil];
            
            [video setAllowsInlineMediaPlayback:YES];
            [video setMediaPlaybackRequiresUserAction:NO];
            [video.scrollView setScrollEnabled:NO];
            NSString* embedHTML = [NSString stringWithFormat:@"\
                                   <html>\
                                   <body style='margin:0px;padding:0px;'>\
                                   <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
                                   <script type='text/javascript'>\
                                   function onYouTubeIframeAPIReady()\
                                   {\
                                   ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})\
                                   }\
                                   function onPlayerReady(a)\
                                   { \
                                   a.target.playVideo(); \
                                   }\
                                   </script>\
                                   <iframe id='playerId' type='text/html' width='%d' height='%d' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
                                   </body>\
                                   </html>", 280, 158, videoCode];
            [video loadHTMLString:embedHTML baseURL:nil];
            
            CGRect oldFrame = cellView.frame;
            oldFrame.size.height = cellView.frame.size.height-30;
            cellView.frame = oldFrame;
            [cellView addSubview:video];
        }
    }
    

    [sponsorClicked setContainerView:cellView];
    [sponsorClicked setUseMotionEffects:TRUE];
    UIWebView *web = _webView;
    
    NSString *URL;
    
    if([[sponsorData objectAtIndex:indexPath.row] objectForKey:@"link"] > 0){
        URL = [[sponsorData objectAtIndex:indexPath.row] objectForKey:@"link"];
        
        NSLog(@"%@", URL);
    }else{
        URL = [[sponsorData objectAtIndex:indexPath.row] objectForKey:@"url"];
    }
    
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
            [video stringByEvaluatingJavaScriptFromString:@"ytplayer.stopVideo();"];
            [video loadRequest:nil];
            [video removeFromSuperview];
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

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *currentURL = webView.request.URL.absoluteString;
    NSLog(@"URL is: %@", currentURL);
    if ([currentURL rangeOfString:@"preview"].location == NSNotFound) {
        NSLog(@"URL is not a preview");
    } else {
        NSLog(@"URL is a preview");
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"input\")[1].click()"];
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", [request.URL absoluteString]); 
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
    [_progress setProgress:redirects*0.1];
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
