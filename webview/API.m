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

@implementation API
{

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
        
        _topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [_topBar setImage:[UIImage imageNamed:@"topBar.png"]]; 
        
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

- (NSString *) currentPoints
{
    if([_userData objectForKey:@"points"]>0){
        return [NSString stringWithFormat:@"%@", [_userData objectForKey:@"points"]];
    }else{
        return @"";
    }
}

- (UILabel *) getPoints
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 24, 100, 20)];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setText:_points.text];
    [label setTextColor:[UIColor grayColor]];
    return label; 
}

- (UIView *) getBar
{
    UIView *bar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    UIImageView *barImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [barImage setImage:[UIImage imageNamed:@"topBar.png"]];
    
    [bar addSubview:barImage];
    return bar; 
}

- (void) clear
{
    [_userData removeObjectForKey:@"points"];
    [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self];
    [self user]; 
}

- (void) user
{
    
    NSArray *a = [self makeForData:[self serialNumber]];
    NSString *postString = [NSString stringWithFormat:@"userID=%@&sn=%@&a=%@&t=%@",[self serialNumber], [self serialNumber], [a objectAtIndex:0], [a objectAtIndex:1]];
    NSMutableURLRequest *request = [self requestForEndpoint:@"user" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"%@", response);
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"user: %@", strData);
            _userData = [json mutableCopy];
//            if(![_userData isEqual:json]){
                [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self];
//            }
            [_points setText:[NSString stringWithFormat:@"%@", [json objectForKey:@"points"]]];
//            [_referrals setText:[NSString stringWithFormat:@"Referrals: %@", [json objectForKey:@"referrals_count"]]];
        }
    }];

}

- (void) refer:(NSString *)person
{
    NSLog(@"REFER PERSON");
    
    NSString *postString = [NSString stringWithFormat:@"userID=%@&referrer=%@", [self serialNumber], person];
    NSMutableURLRequest *request = [self requestForEndpoint:@"anonRefer" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSLog(@"%@", response);
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"user: %@", strData);
        }
    }];
}

- (void) stuff
{
    NSLog(@"stuff");
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
