//
//  SPPUtils.m
//  SponsorPay
//
//  Created by Daniel Barden on 9/13/13.
//  Copyright (c) 2013 Daniel Barden. All rights reserved.
//

#import "SPPUtils.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/ASIdentifierManager.h>


@implementation SPPUtils

+ (NSString *)getLocale
{
    // Not sure which key to use, but apparently SponsorPay uses the name of the country
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

// Get IP Address - I need to tell you, I fetched from Internet :P
+ (NSString *)getIPAddress
{
    // The simulator does not provide an IP
#if TARGET_IPHONE_SIMULATOR
    return @"109.235.143.113";
#endif
    
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

+ (NSString *)getTimestamp
{
    NSNumber *timestamp = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    return [timestamp stringValue];
}

+ (NSString *)getOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getDeviceId
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

// Calculates the sha1
+ (NSString *)sha1:(NSString *)input
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

@end
