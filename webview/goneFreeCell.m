//
//  goneFreeCell.m
//  FreeAppLife
//
//  Created by Misbah Khan on 7/14/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "goneFreeCell.h"

@implementation goneFreeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _price = [[UILabel alloc] initWithFrame:CGRectMake(30, 21, 192, 20)];
        [_price setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        _price.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    return self;
}

- (void) format
{
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
