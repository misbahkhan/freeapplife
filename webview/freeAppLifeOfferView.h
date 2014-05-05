//
//  freeAppLifeOfferView.h
//  FreeAppLife
//
//  Created by Misbah Khan on 5/5/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"

@interface freeAppLifeOfferView : UIView

@property (nonatomic, strong) NSDictionary *offerData;
@property (nonatomic, strong) API *sharedInstance;

-(id)initWithData:(NSDictionary *)data;

@end
