//
//  offerCell.h
//  FreeAppLife
//
//  Created by Misbah Khan on 5/29/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "rewardCell.h"

@interface offerCell : rewardCell

@property (nonatomic, strong) UILabel *refpoints;
@property (nonatomic, strong) UIImageView *ref;

- (void) format;

@end
