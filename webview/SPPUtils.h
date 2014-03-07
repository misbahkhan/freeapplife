//
//  SPPUtils.h
//  SponsorPay
//
//  Created by Daniel Barden on 9/13/13.
//  Copyright (c) 2013 Daniel Barden. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class containing some goodies to take away.
 Simple methods that could be used by general parts of the system
 */
@interface SPPUtils : NSObject

/**
 Returns the locale of the system.
 @returns the Country Code of the locale of the systemm
 */
+ (NSString *)getLocale;

/**
 Returns the IP address of the device.
 In case of running in the simulator, it returns the address 109.235.143.113
 @return the IP address
 */
+ (NSString *)getIPAddress;
/**
 Returns an NSString representing the timestamp.
 The timestamp will be in the UNIX Epoch format
 @returns the timestamp in the UNIX Epoch format
 */
+ (NSString *)getTimestamp;

/**
 Returns the version of the Operating system currently installed
 @returns the current Operating system version
 */
+ (NSString *)getOSVersion;

/**
 Returns the advertising Identifier of the device
 @returns the advertising Identifier of the device.
 */
+ (NSString *)getDeviceId;

/**
 Calculates the SHA1 string of a given string
 @param input the string for which will be calculated the SHA1
 @return the SHA1 of the input
 */
+ (NSString *)sha1:(NSString *)input;
@end