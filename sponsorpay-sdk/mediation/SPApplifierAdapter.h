//
//  SPApplifierAdapter.h
//  SponsorPaySample
//
//  Created by David Davila on 10/1/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPVideoNetworkAdapter.h"
#import "AdNetworkSettings.h"

#ifdef SPApplifierSDKAvailable_1_0_10
#import <ApplifierImpact/ApplifierImpact.h>
#define ApplifierProtocol , ApplifierImpactDelegate
#else
#define ApplifierProtocol
#endif

//#define APPLIFIER_TEST_MODE

#ifdef APPLIFIER_TEST_MODE
#warning Applifier adapter test mode enabled
#endif

@interface SPApplifierAdapter : NSObject <SPVideoNetworkAdapter ApplifierProtocol>

@property (readonly, strong) NSString *gameId;

- (id)initWithGameId:(NSString *)gameId;

@end