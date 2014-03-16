//
//  SPMockTPNAdapter.m
//  SponsorPay iOS SDK
//
//  Created by David Davila on 6/13/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import "SPMockTPNAdapter.h"
#import "SPMockTPNPlayViewController.h"

static const NSTimeInterval kDelayForPlayStartEvent = 0.5;
static const NSTimeInterval kDelayForPlayFinalEvent = 4.5;

@interface SPMockTPNAdapter()

@property (strong) SPMockTPNPlayViewController *mockPlayer;

@end

@implementation SPMockTPNAdapter

- (NSString *)providerName
{
    return @"mockmediatednetwork";
}

- (void)startProvider
{

}

- (void)videosAvailable:(SPTPNValidationResultBlock)callback
{
    switch (self.validationBehavior) {
        case SPMockValidationBehaviorTimeOut:
            // Ignore call and let it time out
            break;
        case SPMockValidationBehaviorTriggerResult:
            callback(self.providerName, self.validationResultToTrigger);
            break;
    }
}

- (void)playVideoWithParentViewController:(UIViewController *)parentVC
                        notifyingCallback:(SPTPNVideoEventsHandlerBlock)eventsCallback
{
    switch (self.playingBehavior) {
        case SPMockPlayingBehaviorTimeOut: {
            // Ignore call and let it time out
            break;
        }
        case SPMockPlayingBehaviorTriggerStartAndTimeOut: {
            dispatch_after([self dispatchTimeAfterDelay:kDelayForPlayStartEvent],
                           [self queueForAsyncEvents],
                           ^{
                               eventsCallback(self.providerName, SPTPNVideoEventStarted);
                           });
            break;
        }
        case SPMockPlayingBehaviorTriggerResultOnce: {
            dispatch_async([self queueForAsyncEvents], ^{
                eventsCallback(self.providerName, self.videoEventToTrigger);
            });
            break;
        }
        case SPMockPlayingBehaviorTriggerStartAndFinalResult: {

            // Start event
            dispatch_after([self dispatchTimeAfterDelay:kDelayForPlayStartEvent],
                           [self queueForAsyncEvents],
                           ^{
                               [self performSelectorOnMainThread:@selector(presentMockPlayerFromViewController:) withObject:parentVC waitUntilDone:YES];
                               eventsCallback(self.providerName, SPTPNVideoEventStarted);
                           });
            // Result event
            dispatch_after([self dispatchTimeAfterDelay:kDelayForPlayFinalEvent],
                           [self queueForAsyncEvents],
                           ^{
                               [self performSelectorOnMainThread:@selector(dismissMockPlayer) withObject:nil waitUntilDone:YES];
                               eventsCallback(self.providerName, self.videoEventToTrigger);

                               if (self.videoEventToTrigger == SPTPNVideoEventFinished)
                                   eventsCallback(self.providerName, SPTPNVideoEventClosed);
                           });
            break;
        }
    }
}

- (dispatch_queue_t)queueForAsyncEvents
{
    return dispatch_get_main_queue();
}

// Undefined for negative values of delay
- (dispatch_time_t)dispatchTimeAfterDelay:(NSTimeInterval)delay
{
    double delayInNanoseconds = delay * pow(10, 9);
    dispatch_time_t dispatchDelta = (dispatch_time_t)delayInNanoseconds;
    return dispatch_time(DISPATCH_TIME_NOW, dispatchDelta);
}

- (void)presentMockPlayerFromViewController:(UIViewController *)parentViewController
{
    self.mockPlayer = [[SPMockTPNPlayViewController alloc] init];
    [parentViewController presentViewController:self.mockPlayer animated:YES completion:nil];
}

- (void)dismissMockPlayer
{
    [self.mockPlayer.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.mockPlayer = nil;
}

@end
