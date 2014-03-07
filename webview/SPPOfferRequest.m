//
//  SPPApiRequest.m
//  SponsorPay
//
//  Created by Daniel Barden on 9/9/13.
//  Copyright (c) 2013 Daniel Barden. All rights reserved.
//

#import "SPPOfferRequest.h"
#import "SPPUtils.h"


@interface SPPOfferRequest() {
    NSString *_hashKey;
    NSMutableData *_requestData;
}

/** Stores the appId */
@property (nonatomic, copy) NSString *appId;
 /** Stores the pub0 */
@property (nonatomic, copy) NSString *pub0;
/** Stores the uid */
@property (nonatomic, copy) NSString *uid;
/** Stores the apiKey*/
@property (nonatomic, copy) NSString *apiKey;

/** Stores the success block */
@property (nonatomic, copy) SPPSuccess successBlock;

/** Stores the failure block */
@property (nonatomic, copy) SPPFailure failureBlock;
/** Stores the created request */
@property (nonatomic, strong) NSURLRequest *request;
/** Stores the created response */
@property (nonatomic, strong) NSHTTPURLResponse *response;
/** Stores the error generated in case of failing connection */
@property (nonatomic, strong) NSError *error;

@end

@implementation SPPOfferRequest

static NSString *requestURL = @"http://api.sponsorpay.com/feed/v1/offers.json";

#pragma mark - Initializers
+ (void)createRequestWithAppId:(NSString *)appId
                        apiKey:(NSString *)apiKey
                          pub0:(NSString *)pub0
                           uid:(NSString *)uid
                       success:(void (^)(NSDictionary *jsonDict))success
                       failure:(void (^)(NSError *error))failure
{
    if (appId.length == 0 || apiKey.length == 0 || pub0.length == 0 || uid.length == 0) {
        if (failure) {
            failure([[NSError alloc] initWithDomain:@"com.danielbarden.SponsorPayValidationDomain"
                    code:1000 userInfo:@{NSLocalizedDescriptionKey: @"All parameters are required."}]);
        }
        return;
    }
    SPPOfferRequest *offerRequest = [SPPOfferRequest sharedInstance];
    
    // Sets initial parameters
    offerRequest.appId = appId;
    offerRequest.apiKey = apiKey;
    offerRequest.pub0 = pub0;
    offerRequest.uid = uid;
    
    offerRequest.successBlock = success;
    offerRequest.failureBlock = failure;
    offerRequest.error = nil;
    
    // Perform the connection
    [offerRequest startConnection];
}

+ (id)sharedInstance
{
    static SPPOfferRequest *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _requestData = [[NSMutableData alloc] init];
    }
    return self;
}

// Creates the request and fires the connection 
- (void)startConnection
{
    NSString *getParameters = [self createGetParameters];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", requestURL, getParameters]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

// Returns a list of the parameters in alphabetic order and signed
- (NSString *)createGetParameters {
    
    NSDictionary *paramData = @{@"appid": self.appId,
                                @"pub0": self.pub0,
                                @"format": @"json",
                                @"locale": @"en",
                                @"device_id": [SPPUtils getDeviceId],
                                @"ip": [SPPUtils getIPAddress],
                                @"offer_types": [self getOfferTypes],
                                @"os_version": [SPPUtils getOSVersion],
                                @"timestamp": [SPPUtils getTimestamp],
                                @"uid": self.uid};
    
    NSString *getParameters = [self appendHashKeyToGetParameters:paramData];
    return getParameters;
}

// Sorts the dictionary and appends the hash key parameter
- (NSString *)appendHashKeyToGetParameters:(NSDictionary *)getParameters {
    __block NSMutableString *hashString = [[NSMutableString alloc] init];
    
    // Creates an array with ordered keys and organizes the objects for the respective order
    NSArray *orderedKeys = [[getParameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [orderedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [hashString appendFormat:@"%@=%@&", obj, getParameters[obj]];
    }];
    
    // Create a copy of the string before appending the apiKey and calculates the sha1
    NSMutableString *getParametersString = [hashString mutableCopy];
    
    [hashString appendFormat:@"%@", self.apiKey];
    
    NSString *output = [SPPUtils sha1:hashString];
    _hashKey = output;
    
    // Adds the hashkey
    [getParametersString appendFormat:@"hashkey=%@", _hashKey];
    
    return getParametersString;
}


#pragma mark - Helper methods

- (NSString *)getOfferTypes
{
    return @"101";
}


#pragma mark - NSURLConnectionDelegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = (NSHTTPURLResponse *)response;
    [_requestData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_requestData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Considers a bad request as error
    if (self.response.statusCode >= 400 && self.response.statusCode < 499) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:_requestData options:0 error:nil];
        self.error = [NSError errorWithDomain:@"com.danielbarden.SponsorPayURLErrorDomain" code:self.response.statusCode userInfo:@{NSLocalizedDescriptionKey: responseDict[@"message"]}];
    }
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
    [self finish];
}

// Wraps up the connection, validates the request and call appropriate block
- (void)finish
{
    // When the connection already presented an error (invalid appid, for example), checkValidResponse would mask the original response. That's why I'm calling just when error is not defined
    if (!self.error) {
        NSString *response = [[NSString alloc] initWithData:_requestData encoding:NSUTF8StringEncoding];
        [self checkValidResponse:[NSString stringWithFormat:@"%@%@", response, self.apiKey]];
    }
    
    if (!self.error){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_requestData options:0 error:0];
        SPPSuccess success = self.successBlock;
        if (success) {
            success(dict);
        }
    } else {
        SPPFailure failure = self.failureBlock;
        if (failure) {
            failure(self.error);
        }
    }
}

// Checks if the response is valid. If not, creates an error
- (BOOL)checkValidResponse:(NSString *)response
{
    NSString *header = self.response.allHeaderFields[@"X-Sponsorpay-Response-Signature"];
    BOOL is_valid = [header isEqualToString:[SPPUtils sha1:response]];
    if (!is_valid) {
        self.error = [NSError errorWithDomain:@"com.danielbarden.SponsorPayURLErrorDomain" code:self.response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Response signature doesn't match."}];
    }
    return is_valid;
}

@end
