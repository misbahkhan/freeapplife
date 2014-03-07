//
//  SPGenericAdapter.m
//  SponsorPaySample
//
//  Created by David Davila on 9/29/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import "SPTPNGenericAdapter.h"

typedef enum {
    SPTPNGenericAdapterStateReady,
    SPTPNGenericAdapterStateValidating,
    SPTPNGenericAdapterStatePlaying
} SPTPNGenericAdapterState;

@interface SPTPNGenericAdapter()

@property (retain) id<SPVideoNetworkAdapter> videoNetworkAdapter;
@property (copy) SPTPNValidationResultBlock validationResultCallback;
@property (copy) SPTPNVideoEventsHandlerBlock videoEventsCallback;
@property (assign) SPTPNGenericAdapterState state;

@property (retain) NSTimer *validationTimeoutTimer;

@end

@implementation SPTPNGenericAdapter

- (id)initWithVideoNetworkAdapter:(id<SPVideoNetworkAdapter>)adapter
{
    self = [super init];
    if (self) {
        self.videoNetworkAdapter = adapter;
    }
    return self;
}

#pragma mark - SPTPNVideoAdapter implementation

- (NSString *)providerName
{
    return self.videoNetworkAdapter.providerName;
}

- (void)startProvider
{
    [self.videoNetworkAdapter startProvider];
}

- (void)videosAvailable:(SPTPNValidationResultBlock)callback
{
    self.state = SPTPNGenericAdapterStateValidating;
    self.validationResultCallback = callback;
    [self startValidationTimeoutTimer];
    [self.videoNetworkAdapter checkAvailability];
}

- (void)playVideoWithParentViewController:(UIViewController *)parentVC
                        notifyingCallback:(SPTPNVideoEventsHandlerBlock)eventsCallback
{
    self.state = SPTPNGenericAdapterStatePlaying;
    self.videoEventsCallback = eventsCallback;
    [self.videoNetworkAdapter playVideoWithParentViewController:parentVC];
}

#pragma mark - SPVideoNetworkAdapterDelegate implementation

- (void)adapter:(id<SPVideoNetworkAdapter>)adapter didReportVideoAvailable:(BOOL)videoAvailable
{
    [self stopValidationTimeoutTimer];
    [self reportValidationResult:videoAvailable ? SPTPNValidationSuccess : SPTPNValidationNoVideoAvailable];
}

- (void)adapterVideoDidStart:(id<SPVideoNetworkAdapter>)adapter
{
    [self reportVideoEvent:SPTPNVideoEventStarted];
}

- (void)adapterVideoDidAbort:(id<SPVideoNetworkAdapter>)adapter
{
    [self reportVideoEvent:SPTPNVideoEventAborted];
}

- (void)adapterVideoDidFinish:(id<SPVideoNetworkAdapter>)adapter
{
    [self reportVideoEvent:SPTPNVideoEventFinished];
}

- (void)adapterVideoDidClose:(id<SPVideoNetworkAdapter>)adapter
{
    [self reportVideoEvent:SPTPNVideoEventClosed];
}

- (void)adapter:(id<SPVideoNetworkAdapter>)adapter didFailWithError:(NSError *)error
{
    switch (self.state) {
        case SPTPNGenericAdapterStateReady:
            break;
        case SPTPNGenericAdapterStateValidating:
            [self reportValidationResult:SPTPNValidationError];
            break;
        case SPTPNGenericAdapterStatePlaying:
            [self reportVideoEvent:SPTPNVideoEventError];
            break;
    }
}

- (void)adapterDidTimeout:(id<SPVideoNetworkAdapter>)adapter
{
    switch (self.state) {
        case SPTPNGenericAdapterStateReady:
            break;
        case SPTPNGenericAdapterStateValidating:
            break;
        case SPTPNGenericAdapterStatePlaying:
            [self reportVideoEvent:SPTPNVideoEventTimeout];
            break;
    }
}

#pragma mark - Result reporting

- (void)reportValidationResult:(SPTPNValidationResult)result
{
    if (self.state != SPTPNGenericAdapterStateValidating)
        return;

    if (!self.validationResultCallback)
        return;

    self.validationResultCallback(self.providerName, result);
}

- (void)reportVideoEvent:(SPTPNVideoEvent)event
{
    if (self.state != SPTPNGenericAdapterStatePlaying)
        return;

    if (!self.videoEventsCallback)
        return;

    self.videoEventsCallback(self.providerName, event);
}

#pragma mark - Timeout management

- (void)startValidationTimeoutTimer
{
    self.validationTimeoutTimer =
    [NSTimer scheduledTimerWithTimeInterval:SPTPNTimeoutInterval
                                     target:self
                                   selector:@selector(validationDidTimeOut)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)stopValidationTimeoutTimer
{
    [self.validationTimeoutTimer invalidate];
    self.validationTimeoutTimer = nil;
}

- (void)validationDidTimeOut
{
    [self reportValidationResult:SPTPNValidationTimeout];
    self.validationTimeoutTimer = nil;
}

- (void)dealloc
{
    if (self.validationTimeoutTimer) {
        [self stopValidationTimeoutTimer];
    }
}

@end
