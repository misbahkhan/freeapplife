//
//  rightLine.m
//  webview
//
//  Created by Misbah Khan on 2/28/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "rightLine.h"

@implementation rightLine

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.671 green:0.675 blue:0.694 alpha:1.000].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, CGRectGetWidth(self.frame),0);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGContextStrokePath(context);
}


@end
