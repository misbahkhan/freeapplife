//
//  SPGenericAdapter.h
//  SponsorPaySample
//
//  Created by David Davila on 9/29/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTPNVideoAdapter.h"
#import "SPVideoNetworkAdapter.h"

@interface SPTPNGenericAdapter : NSObject <SPTPNVideoAdapter, SPVideoNetworkAdapterDelegate>

- (id)initWithVideoNetworkAdapter:(id<SPVideoNetworkAdapter>)adapter;

@end
