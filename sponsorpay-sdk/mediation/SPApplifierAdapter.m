//
//  SPApplifierAdapter.m
//  SponsorPaySample
//
//  Created by David Davila on 10/1/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import "SPApplifierAdapter.h"
#import "SPLogger.h"

@interface SPApplifierAdapter()

@property (strong) NSString *gameId;

@end

@implementation SPApplifierAdapter

@synthesize delegate = _delegate;

- (id)initWithGameId:(NSString *)gameId
{
    self = [super init];
    if (self) {
        self.gameId = gameId;
    }
    return self;

}

- (NSString *)providerName
{
    return @"applifier";
}

- (void)startProvider
{
#ifdef SPApplifierSDKAvailable_1_0_10

    ApplifierImpact *applifierInstance = [ApplifierImpact sharedInstance];
#ifdef APPLIFIER_TEST_MODE
    [applifierInstance setDebugMode:YES];
    [applifierInstance setTestMode:YES];
#endif

    [applifierInstance setDelegate:self];
    [applifierInstance startWithGameId:self.gameId];

#endif
}

- (void)checkAvailability
{
#ifdef SPApplifierSDKAvailable_1_0_10
    BOOL videoAvailable = [ApplifierImpact sharedInstance].canShowImpact;
    [self.delegate adapter:self didReportVideoAvailable:videoAvailable];
#endif
}

- (void)playVideoWithParentViewController:(UIViewController *)parentVC
{
#ifdef SPApplifierSDKAvailable_1_0_10
    [[ApplifierImpact sharedInstance] setViewController:parentVC
                         showImmediatelyInNewController:NO];
    [[ApplifierImpact sharedInstance] showImpact:@{kApplifierImpactOptionVideoUsesDeviceOrientation:@true}];
#endif
}

#pragma mark - ApplifierImpactDelegate selectors

#ifdef SPApplifierSDKAvailable_1_0_10

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact
{
    [SPLogger log:@"%s", __PRETTY_FUNCTION__];
}

- (void)applifierImpactCampaignsFetchFailed:(ApplifierImpact *)applifierImpact
{
    [self.delegate adapter:self didFailWithError:nil]; // TODO provide a meaningful error
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact
{
    [self.delegate adapterVideoDidStart:self];
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact
completedVideoWithRewardItemKey:(NSString *)rewardItemKey
        videoWasSkipped:(BOOL)skipped
{
    if (skipped) {
        [self.delegate adapterVideoDidAbort:self];
    } else {
        [self.delegate adapterVideoDidFinish:self];
    }
}

- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact
{
    [self.delegate adapterVideoDidClose:self];
}

#endif
@end
