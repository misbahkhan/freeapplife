//
//  SPMediationCoordinator.m
//  SponsorPay iOS SDK
//
//  Created by David Davila on 5/16/13.
// Copyright 2011-2013 SponsorPay. All rights reserved.
//

#import "SPMediationCoordinator.h"
#import "SPVungleAdapter.h"
#import "SPFlurryAdapter.h"
#import "SPTPNGenericAdapter.h"
#import "SPApplifierAdapter.h"
#import "SPLogger.h"

@interface SPMediationCoordinator ()

@property (strong) NSDictionary *providersByName;
@property (assign) BOOL didStartThirdPartySDKs;

@end

@implementation SPMediationCoordinator

- (void)startThirdPartySDKs
{
    if (self.didStartThirdPartySDKs)
        return;

    NSMutableDictionary *p = [NSMutableDictionary dictionary];

#ifdef SPVungleSDKAvailable_1_3_2
    SPVungleAdapter *vungleAdapter = [[SPVungleAdapter alloc] initWithAppId:SPVungleAppID];
    [p setObject:vungleAdapter forKey:[vungleAdapter.providerName lowercaseString]];
    [vungleAdapter startProvider];
#endif

#ifdef SPFlurrySDKAvailable_4_2_1
    SPFlurryAdapter *flurryAdapter = [[SPFlurryAdapter alloc] initWithAPIKey:SPFlurryAPIKey
                                                               videoAdsSpace:SPFlurryVideoAdsSpace];
    [p setObject:flurryAdapter forKey:[flurryAdapter.providerName lowercaseString]];
    [flurryAdapter startProvider];
#endif

#ifdef SPApplifierSDKAvailable_1_0_10
    SPApplifierAdapter *applifierAdapter = [[SPApplifierAdapter alloc] initWithGameId:SPApplifierGameID];
    SPTPNGenericAdapter *applifierAdapterWrapper = [[SPTPNGenericAdapter alloc] initWithVideoNetworkAdapter:applifierAdapter];
    applifierAdapter.delegate = applifierAdapterWrapper;
    [p setObject:applifierAdapterWrapper forKey:[applifierAdapterWrapper.providerName lowercaseString]];
    [applifierAdapterWrapper startProvider];
//    [applifierAdapterWrapper release];
//    [applifierAdapter release];
#endif

#ifdef SPMockTPNAvailable
    SPMockTPNAdapter *mockAdapter = [[SPMockTPNAdapter alloc] init];
    [p setObject:mockAdapter forKey:[mockAdapter.providerName lowercaseString]];
    self.mockAdapter = mockAdapter;
    [mockAdapter startProvider];
    [mockAdapter release];
#endif

    self.providersByName = [NSDictionary dictionaryWithDictionary:p];
    self.didStartThirdPartySDKs = YES;
}

- (id<SPTPNVideoAdapter>)providerWithName:(NSString *)name
{
    return [self.providersByName objectForKey:[name lowercaseString]];
}

- (BOOL)providerAvailable:(NSString *)providerKey
{
    return [self providerWithName:providerKey] != nil;
}

- (void)videosFromProvider:(NSString *)providerKey available:(SPTPNValidationResultBlock)callback;
{
    BOOL integrated = [self providerAvailable:providerKey];

    [SPLogger log:@"Provider %@ integrated: %@", providerKey, integrated ? @"YES" : @"NO"];

    if (!integrated) {
        callback(providerKey, SPTPNValidationNoVideoAvailable);
    }

    id provider = [self providerWithName:providerKey];
    [provider videosAvailable:callback];
}

-(void)playVideoFromProvider:(NSString *)providerKey eventsCallback:(SPTPNVideoEventsHandlerBlock)eventsCallback
{
    [SPLogger log:@"Playing video from %@", providerKey];

    id provider = [self providerWithName:providerKey];
    // TODO could self.hostViewController be nil?
    [provider playVideoWithParentViewController:self.hostViewController
                              notifyingCallback:eventsCallback];
    self.hostViewController = nil;
}

@end
