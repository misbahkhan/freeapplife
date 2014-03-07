//
//  topBar.m
//  webview
//
//  Created by Misbah Khan on 2/27/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "topBar.h"
#import "API.h"

@implementation topBar

- (id)initDefault
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if(self){
        [self setBackgroundColor:[UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
