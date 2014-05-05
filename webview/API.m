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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [self appURL]]];
            exit(0);
        }
    }else{
        [self user];
    }
}

- (void) user
{
    
    NSArray *a = [self makeForData:[self serialNumber]];
    NSString *postString = [NSString stringWithFormat:@"userID=%@&sn=%@&a=%@&t=%@",[self serialNumber], [self serialNumber], [a objectAtIndex:0], [a objectAtIndex:1]];
    NSMutableURLRequest *request = [self requestForEndpoint:@"user" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            NSLog(@"%@", response);
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"user: %@", strData);
            _userData = [json mutableCopy];
//            if(![_userData isEqual:json]){
                [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self];
            if([[json objectForKey:@"maint_mode"] boolValue] == TRUE) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maintenence Mode" message:@"FreeAppLife is currently in maintenance mode. We will return shortly!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            if([[json objectForKey:@"version"] floatValue] > [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]){
//                outdated = YES;
                versionAlert = [[UIAlertView alloc] initWithTitle:@"Old Version" message:@"You're currently running an outdated version of FreeAppLife, please update now." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
                [versionAlert show];
            }
            
//            }
            [_points setText:[NSString stringWithFormat:@"%@", [json objectForKey:@"points"]]];
//            [_referrals setText:[NSString stringWithFormat:@"Referrals: %@", [json objectForKey:@"referrals_count"]]];
        }
    }];

}

- (void) refer:(NSString *)person
{
//    NSLog(@"REFER PERSON");
    
    NSString *postString = [NSString stringWithFormat:@"userID=%@&referrer=%@", [self serialNumber], person];
    NSMutableURLRequest *request = [self requestForEndpoint:@"anonRefer" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
//            NSLog(@"%@", response);
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"user: %@", strData);
        }
    }];
}

- (void) stuff
{
//    NSLog(@"stuff");
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

- (NSString *)userID
{
    return [self md5ForString:[self serialNumber]];
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
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return request;
    
}


@end
