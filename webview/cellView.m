//
//  cellView.m
//  FreeAppLife
//
//  Created by Misbah Khan on 4/17/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "cellView.h"
#import "API.h"

@implementation cellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        // Initialization code
    }
    return self;
}

- (void) setData:(NSDictionary *)data
{
    _data = data;
    [self setNeedsDisplay]; 
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
    UIFont* font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    UIColor* textColor = [UIColor blackColor];
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
    
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:[_data objectForKey:@"name"] attributes:stringAttrs];
    
    [attrStr drawAtPoint:CGPointMake(10.f, 10.f)];
}


@end
