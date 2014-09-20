//
//  API.m
//  webview
//
//  Created by Misbah Khan on 2/22/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "API.h"
#import <dlfcn.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Parse/Parse.h>
#import <AdSupport/ASIdentifierManager.h>
#include <dlfcn.h>
#import <sys/sysctl.h>

@implementation API
{
    UIAlertView *versionAlert;
}

+ (id)sharedInstance {
    static API *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[self alloc] init];
        
        
    });
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _baseURL = @"https://freeapplife.com/api/";
        
//        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//        [_topBar setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
        
//        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
//            _topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1536, 44)];
//            [_topBar setImage:[UIImage imageNamed:@"topBariPad.png"]];
//        }else{
//            _topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//            [_topBar setImage:[UIImage imageNamed:@"topBar.png"]];
//        }
        _imageCache = [[NSMutableDictionary alloc] init]; 
        
        _points = [[UILabel alloc] initWithFrame:CGRectMake(140, 20, 160, 20)];
        [_points setTextAlignment:NSTextAlignmentRight];

        _referrals = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 160, 20)];
        [_referrals setTextAlignment:NSTextAlignmentLeft];
        
        _appURL = @"https://freeapplife.com/fal/update/";
        _refshown = 0;
        _sponsoralert = NO;
        
//        [_topBar addSubview:_points];
//        [_topBar addSubview:_referrals];
        
//        someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
        _notificationName = @"userNotification"; 
    }
    return self;
}

- (void)tweet:(NSString *)message
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                 NSDictionary *params = @{@"status" : message};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                              URL:url
                                       parameters:params];
                 
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
                                  //                                  NSLog(@"Timeline Response: %@\n", timelineData);
//                                  NSLog(@"user: %@", [[timelineData objectForKey:@"status"] objectForKey:@"id"]);
                              }
                              else {
                                  // Our JSON deserialization went awry
//                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
//                              NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
//                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
}

- (NSString *) currentPoints
{
    if([_userData objectForKey:@"points"]>0){
        return [NSString stringWithFormat:@"%@", [_userData objectForKey:@"points"]];
    }else{
        return @"";
    }
}

- (NSString *) giveaway
{
    if([_userData objectForKey:@"giveaway"] > 0){
        if([[_userData objectForKey:@"giveaway"] intValue] == 1){
            return [NSString stringWithFormat:@"%@", [_userData objectForKey:@"giveaway"]];
        }
        return [NSString stringWithFormat:@"%@", [_userData objectForKey:@"giveaway"]];
    }else{
        return @"0";
    }
}

- (UILabel *) getPoints
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 24, 100, 20)];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        label = [[UILabel alloc] initWithFrame:CGRectMake(645, 24, 100, 20)];
    }
    [label setTextAlignment:NSTextAlignmentRight];
    [label setBackgroundColor:[UIColor clearColor]]; 
    [label setText:_points.text];
    [label setTextColor:[UIColor grayColor]];
    return label; 
}

- (UIView *) getBar
{
    UIView *bar;
    UIImageView *barImage;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        bar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)];
        barImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)];
        [barImage setImage:[UIImage imageNamed:@"topBariPad.png"]];
    }else{
        bar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        barImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [barImage setImage:[UIImage imageNamed:@"topBar.png"]];
    }
    
    [bar addSubview:barImage];
    return bar; 
}

- (void) clear
{
    [_userData removeObjectForKey:@"points"];
    [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self];
    [self user]; 
}

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView == versionAlert){
        if(buttonIndex == 0){
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            exit(0);
        }else if(buttonIndex == 1){
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://freeapplife.com/fal/FINAL"]];
            exit(0);
        }
    }else{
        [self user];
    }
}

- (void) user
{
    
//    NSArray *a = [self makeForData:[self serialNumber]];
    NSString *postString = [NSString stringWithFormat:@"userID=%@",[self userID]];
    NSMutableURLRequest *request = [self requestForEndpoint:@"user" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            Log(@"%@", json);
            _userData = [json mutableCopy];
            [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self];
            if([json[@"referral_code"] length] > 0){
    //            NSLog(@"%@", response);
                NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //            NSLog(@"user: %@", strData);


                
    //            NSLog(@"%@", _userData); 
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                NSString *channel = [NSString stringWithFormat:@"ref_%@", [json objectForKey:@"referral_code"]];
                [currentInstallation addUniqueObject:channel forKey:@"channels"];
                [currentInstallation saveInBackground];

    //            if(![_userData isEqual:json]){
    //                [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self];
                if([[json objectForKey:@"didv_mode"] boolValue] == TRUE) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maintenence Mode" message:@"FreeAppLife is currently in maintenance mode. We will return shortly!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    [alert show];
                }
                
    //            NSLog(@"%@", [json objectForKey:@"version"]);
                
                if([[json objectForKey:@"version"] floatValue] > [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]){
    //                outdated = YES;
                    versionAlert = [[UIAlertView alloc] initWithTitle:@"Old Version" message:@"You're currently running an outdated version of FreeAppLife, please update now." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
                    [versionAlert show];
                }
//                versionAlert = [[UIAlertView alloc] initWithTitle:@"Old Version" message:@"You're currently running an outdated version of FreeAppLife, please update now." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
//                [versionAlert show];
                
                if ([[_userData objectForKey:@"pending"] count] > 0){
                    [self processCheck];
                }
                
    //            }
                [_points setText:[NSString stringWithFormat:@"%@", [json objectForKey:@"points"]]];
    //            [_referrals setText:[NSString stringWithFormat:@"Referrals: %@", [json objectForKey:@"referrals_count"]]];
                [self processCheck];
            }
        }
    }];
}

- (void) userpend
{
//  NSArray *a = [self makeForData:[self serialNumber]];
    NSString *postString = [NSString stringWithFormat:@"userID=%@",[self userID]];
    NSMutableURLRequest *request = [self requestForEndpoint:@"userpend" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            //            NSLog(@"%@", response);
//            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"user: %@", strData);
            [_userData setValue:[json objectForKey:@"pending"] forKey:@"pending"];
//            NSLog(@"%@", _userData);
            
            if ([[_userData objectForKey:@"pending"] count] > 0){
                [self processCheck];
            }
        }
    }];
}

- (void) processCheck
{
    if ([[_userData objectForKey:@"pending"] count] < 1) return;

    NSMutableArray *tocheck = [[NSMutableArray alloc] init];
    for(int i = 0; i < [[_userData objectForKey:@"pending"] count]; ++i){
        [tocheck addObject:[[[_userData objectForKey:@"pending"] objectAtIndex:i] objectForKey:@"pn"]];
    }
    NSMutableArray *del = [[NSMutableArray alloc] init];
    NSArray *running = [self runningProcesses];
    NSMutableArray *temp = [[_userData objectForKey:@"pending"] mutableCopy];
    for (NSDictionary *penditem in [_userData objectForKey:@"pending"]) {
        if([running containsObject:[NSString stringWithFormat:@"%@", [penditem objectForKey:@"pn"]]]){
//            NSLog(@"process found with name: %@", [penditem objectForKey:@"pn"]);
            [self next:penditem];
            [temp removeObject:penditem];
        }
    }
    
    [_userData setValue:temp forKey:@"pending"];
}



- (NSString *) ifa
{
    char a[33] = {0x5b,0xb5,0x2a,0x7a,0xad,0x7b,0x6f,0x79,0x70,0xc0,0x77,0x1c,0x94,0x18,0x3d,0x68,0xde,0xb9,0xb1,0x93,0x96,0x37,0xf3,0xc,0x1e,0xd5,0x2,0xc4,0xa9,0x3d,0xfd,0x13,0xe5};
    char b[33] = {0x3e,0xed,0x7a,0x1f,0xe5,0x2e,0x3b,0x9,0x17,0x90,0x2,0x77,0xad,0x55,0x52,0x24,0xb8,0x8e,0xcb,0xe0,0xe2,0x50,0x94,0x4a,0x73,0xb0,0x7a,0x87,0xf8,0x49,0xbb,0x7a,0xe5};
    for (int i = 0; i < 33; i++) {
        b[i] = b[i] ^ a[i];
    }
    return [NSString stringWithCString:b encoding:NSASCIIStringEncoding];
}

- (NSString *) enc
{
    char a[33] = {0xed,0xbd,0x56,0x60,0xcf,0xdc,0x27,0xa8,0xe0,0x56,0x56,0x53,0x47,0x6,0xdc,0xac,0xce,0x96,0x8d,0xd0,0x4a,0xef,0xda,0xc4,0xbb,0x43,0xc5,0xbd,0x2c,0x61,0x4a,0xeb,0xf1};
    char b[33] = {0x9c,0xfc,0x65,0xb,0x8e,0x90,0x6f,0xe5,0x82,0x6,0x1d,0x3b,0x13,0x67,0xae,0xea,0x8f,0xf8,0xd4,0x9e,0x3e,0x9e,0x88,0x92,0x82,0x1,0x91,0xec,0x64,0x13,0x20,0x8c,0xf1};
    for (int i = 0; i < 33; i++) {
        b[i] = b[i] ^ a[i];
    }
    return [NSString stringWithCString:b encoding:NSASCIIStringEncoding];
}

- (NSString*)hw
{
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

- (void) next:(NSDictionary *)data
{
//    NSLog(@"next called");
    char pad[33] = {0x55,0x24,0x63,0x49,0x9d,0xd9,0xbc,0x9a,0x97,0xa5,0x71,0xb4,0x1e,0xa4,0x6c,0x87,0x92,0x82,0x52,0xff,0xff,0xdf,0x31,0x8e,0xb0,0x71,0xc,0xa1,0x70,0x2f,0x76,0xbb,0x5f};
    char key[33] = {0x33,0x65,0x59,0x39,0xe9,0xee,0xc1,0xa1,0xd2,0xd0,0x5f,0x96,0x6b,0xea,0x5b,0xc5,0xc4,0xe4,0x38,0xb9,0xb1,0xac,0x1d,0xd2,0x99,0x5,0x3a,0x8e,0x32,0x13,0x4e,0xeb,0x5f};
    for (int i = 0; i < 33; i++) {
        key[i] = key[i] ^ pad[i];
    }
    NSString *mean = [NSString stringWithCString:key encoding:NSASCIIStringEncoding];
    
    NSString *uid = [self userID];
    NSString *cid = [data objectForKey:@"cid"];
    NSString *aid = [data objectForKey:@"aid"];
    NSString *pn = [data objectForKey:@"pn"];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    NSString *dfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *tommy = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%d", mean, uid, cid, aid, deviceType, dfa, pn, 2];
    
    tommy = [self shapeforstring:tommy];
    deviceType = [deviceType stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
    NSString *toes = [NSString stringWithFormat:@"userID=%@&a=%@&jk=%@", uid, aid, tommy];
//    NSLog(@"%@", toes);
//
    NSError *error;
    NSMutableURLRequest *request = [self requestForEndpoint:@"next" andBody:toes];
//    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            NSLog(@"json: %@", json);
//            NSLog(@"%@", response);
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"user: %@", strData);
        }
    }];
    
}

- (void) refer:(NSString *)person
{
//    NSLog(@"REFER PERSON");
    
    NSString *postString = [NSString stringWithFormat:@"userID=%@&referrer=%@", [self userID], person];
    NSMutableURLRequest *request = [self requestForEndpoint:@"anonRefer" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
//            NSLog(@"%@", response);
//            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"user: %@", strData);
        }
    }];
}

- (void) token
{
//    NSString *postString2 = [NSString stringWithFormat:@"userID=%@&token=%@", [self md5ForString:[self serialNumber]], [NSString stringWithFormat:@"%@", _deviceToken]];
//    NSMutableURLRequest *request3 = [self requestForEndpoint:@"push" andBody:postString2];
//    [NSURLConnection sendAsynchronousRequest:request3 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        
//    }];
}

- (NSString *)sha2:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
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

//    NSLog(@"%@", [[UIDevice currentDevice] systemVersion]);

- (NSString *) idfa
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]; 
}

- (NSString *) mk
{
    NSString *h = [self sha1:[self hw]];
    NSString *full = [h stringByAppendingString:[self idfa]];
    full = [full stringByAppendingString:[self ifa]];
    full = [self sha2:full];
    NSData* one = [[self enc] dataUsingEncoding:NSUTF8StringEncoding];
    NSData* two = [full dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *signatureData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, one.bytes, one.length, two.bytes, two.length, signatureData.mutableBytes);
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    NSString *someString = [[signatureData description] stringByTrimmingCharactersInSet:charsToRemove];
    someString = [someString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return someString;
}

- (NSString *) mk2
{
    NSString *one = [self sha2:[self serialNumber]];
    NSString *two = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] systemVersion]];
    NSString *three = [self idfa];
    char a[33] = {0xba,0x55,0x1e,0x4b,0xd2,0x2d,0x8c,0x8a,0x37,0xd5,0x47,0x73,0xe2,0x4b,0xcc,0xeb,0xb8,0xda,0x4d,0x78,0x35,0x76,0x28,0x22,0x83,0xee,0x6,0x8,0xeb,0xc1,0xab,0xe4,0x48};
    char b[33] = {0xe0,0x5,0x75,0x33,0xba,0x7c,0xd9,0xfe,0x70,0x85,0x71,0x3d,0xa6,0x3c,0xb4,0xb9,0xe0,0xe3,0xf,0x20,0x73,0x30,0x69,0x48,0xeb,0xbb,0x5c,0x69,0xa3,0x97,0xec,0x83,0x48};
    for (int i = 0; i < 33; i++) {
        b[i] = b[i] ^ a[i];
    }
    NSString *four = [NSString stringWithCString:b encoding:NSASCIIStringEncoding];
    
    NSString *five = [one stringByAppendingString:two];
    five = [five stringByAppendingString:three];
    five = [five stringByAppendingString:four];
    five = [self sha2:five];
    
    char c[33] = {0x5c,0x6f,0xfa,0x51,0xe6,0x2b,0x30,0x9,0x8b,0x4d,0xcb,0xb6,0x15,0xd3,0xe1,0x1c,0xc0,0xd6,0xc3,0x1e,0xec,0x5b,0xad,0x98,0xce,0xbd,0xe3,0xbf,0x7,0xcc,0xd7,0x17,0xb2};
    char d[33] = {0x4,0x2,0x91,0xb,0x83,0x53,0x7a,0x7a,0xef,0x29,0xb8,0xf3,0x62,0x82,0xb4,0x4a,0x95,0x94,0xb3,0x26,0xad,0x3c,0xc2,0xf5,0xf6,0xcb,0x92,0xcb,0x4f,0xa7,0xa4,0x47,0xb2};
    for (int i = 0; i < 33; i++) {
        d[i] = d[i] ^ c[i];
    }
    NSString *six = [NSString stringWithCString:d encoding:NSASCIIStringEncoding];
    
    NSData* first = [six dataUsingEncoding:NSUTF8StringEncoding];
    NSData* second = [five dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *seven = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, first.bytes, first.length, second.bytes, second.length, seven.mutableBytes);
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    NSString *someString = [[seven description] stringByTrimmingCharactersInSet:charsToRemove];
    someString = [someString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return someString;
}

- (NSArray *) makeForData:(NSString *)data
{
    NSData *ipD = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://freeapplife.com/beta/ip"]];
    NSString *ip = [[NSString alloc] initWithData:ipD encoding:NSUTF8StringEncoding];
    ip = [ip stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *origSN = [self serialNumber];
    NSDate *date = [NSDate date];
    NSString *epoch = [NSString stringWithFormat:@"%lli", [@(floor([date timeIntervalSince1970])) longLongValue]];
    NSString *final = [ip stringByAppendingString:origSN];
    final = [final stringByAppendingString:epoch];
    final = [self sha1:final];
    
    NSData* secretData = [final dataUsingEncoding:NSUTF8StringEncoding];
    NSData* stringData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *signatureData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, stringData.bytes, stringData.length, signatureData.mutableBytes);
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    NSString *someString = [[signatureData description] stringByTrimmingCharactersInSet:charsToRemove];
    someString = [someString stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    NSLog(@"origSN: %@", origSN);
    //    NSLog(@"epoch: %@", epoch);
    //    NSLog(@"signatureData %@", someString);
    return @[someString, epoch];
}

- (NSString *)serialNumber
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        return @"";
    }
    
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

- (NSArray *)runningProcesses {
    
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess){
            if (process){
                free(process);
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess){
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--){
                    
                    //                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    [array addObject:processName];
                    //                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                    //                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];
                    //                    [array addObject:dict];
                }
                free(process);
                return array;
            }
        }
    }
    
    return nil;
}

- (NSString *)userID
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        return [self mk];
    }else{
        return [self mk2];
    }
//    return [self md5ForString:[self serialNumber]];
}

- (NSString*)md5ForString:(NSString *)string
{
    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    return output;
}

-(NSString*) shapeforstring:(NSString*)input
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

- (void) pending:(int)state fordata:(NSDictionary *)data withnice:(NSString *)nice
{
    if(![[data objectForKey:@"vendor"] isEqualToString:@"fal"]) return;
    NSString *uid = [self userID];
    NSString *cid = [data objectForKey:@"campid"];
    NSString *aid = [data objectForKey:@"appid"];
    NSString *deviceType = [UIDevice currentDevice].model;
    NSString *dfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSString *tommy = [NSString stringWithFormat:@"%@%@%@%@%@%@%d", nice, uid, cid, aid, deviceType, dfa, state];
    
    tommy = [self shapeforstring:tommy];
    deviceType = [deviceType stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *toes = [NSString stringWithFormat:@"userID=%@&c=%@&a=%@&dm=%@&fa=%@&jk=%@&s=%d", uid, cid, aid, deviceType, dfa, tommy, state];
    NSError *error;
    NSMutableURLRequest *request = [self requestForEndpoint:@"state" andBody:toes];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
}


//NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://freeapplife.com/api/register"]];
//[request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
//[request setHTTPMethod:@"POST"];

- (NSMutableURLRequest *) requestForEndpoint:(NSString *)endPoint andBody:(NSString *)postString
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _baseURL, endPoint]]];
    NSString *fakeUserAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU %@ OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25", [UIDevice currentDevice].model, [UIDevice currentDevice].model];
    [request setAllHTTPHeaderFields:@{@"User-Agent":fakeUserAgent}];
    [request setHTTPMethod:@"POST"];
    
    if(postString != nil){
        NSString *vers = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        postString = [postString stringByAppendingString:[NSString stringWithFormat:@"&falappversion=%@&falappidfa=%@", vers, [self idfa]]];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return request;
}


@end
