//
//  SPPApiRequest.h
//  SponsorPay
//
//  Created by Daniel Barden on 9/9/13.
//  Copyright (c) 2013 Daniel Barden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SPPSuccess) (NSDictionary *jsonDict);
typedef void (^SPPFailure) (NSError *error);

/**
 Manages the communication with the SponsorPay API.
 
 Given a few parameters (appId, pub0, uid and apiKey), this class will retrieve the offers available to the user. In this very specific example, the following data will be sent in the request:
 
 - appID: given by the user;
 - pub0: given by the user;
 - format: hardcoded as json;
 - locale: locale used by the system;
 - ip: fetched from the system;
 - offer_types: currently using only 112 (Free offers);
 - os_version: The version of the system's operating system;
 - device_id: the advertisement identifier of the device;
 - hash_key: the signature of the request
 
 This class is responsible also for performing the signing the request and verifying the response is signed correctly.
 */
@interface SPPOfferRequest : NSObject <NSURLConnectionDelegate>

/**
 Validates, the parameters, create a request and executes a call to SponsorPay API.
 
 @param appId identification of the application
 @param apiKey Key that will be used to sign and verify the requests
 @param pub0 Custom parameters
 @param uid Unique user Id used by the application
 @param success Block that will be used in case of success
 @param failure Block that will be used to handle failures
 */
+ (void)createRequestWithAppId:(NSString *)appId
                        apiKey:(NSString *)apiKey
                          pub0:(NSString *)pub0
                           uid:(NSString *)uid
                       success:(void (^)(NSDictionary *jsonDict))success
                       failure:(void (^)(NSError *error))failure;
@end
