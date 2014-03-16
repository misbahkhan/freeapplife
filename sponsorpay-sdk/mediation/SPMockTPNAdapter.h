//
//  SPMockTPNAdapter.h
//  SponsorPay iOS SDK
//
//  Created by David Davila on 6/13/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTPNVideoAdapter.h"
#import "../AdNetworkSettings.h"

typedef enum {
    SPMockValidationBehaviorTimeOut,
    SPMockValidationBehaviorTriggerResult
} SPMockValidationBehavior;

typedef enum {
    SPMockPlayingBehaviorTimeOut,
    SPMockPlayingBehaviorTriggerResultOnce,
    SPMockPlayingBehaviorTriggerStartAndTimeOut,
    SPMockPlayingBehaviorTriggerStartAndFinalResult
} SPMockPlayingBehavior;

@interface SPMockTPNAdapter : NSObject <SPTPNVideoAdapter>

@property (assign) SPMockValidationBehavior validationBehavior;
@property (assign) SPTPNValidationResult validationResultToTrigger;

@property (assign) SPMockPlayingBehavior playingBehavior;
@property (assign) SPTPNVideoEvent videoEventToTrigger;

@end
