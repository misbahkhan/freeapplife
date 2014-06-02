//
//  offerCell.m
//  FreeAppLife
//
//  Created by Misbah Khan on 5/29/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "offerCell.h"

@implementation offerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _refpoints = [[UILabel alloc] initWithFrame:CGRectMake(30, 41, 192, 20)];
        [_refpoints setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        _refpoints.textColor = [UIColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:113.0/255.0 alpha:1.0];
        [_refpoints setTextAlignment:NSTextAlignmentCenter];
        _refpoints.opaque = NO;
        
        _ref = [[UIImageView alloc] initWithFrame:CGRectMake(230, 41, 15, 15)];
        [_ref setImage:[UIImage imageNamed:@"friends.png"]];
        [self.contentView addSubview:_ref];
        [self.contentView addSubview:_refpoints];
    }
    return self;
}

-(void) format
{
    NSString *pointsLabel;
    pointsLabel = [NSString stringWithFormat:@"+ %@", [self.data objectForKey:@"points"]];
    
    self.points.text = pointsLabel;
    [self.points sizeToFit];
    
    [self.refpoints setText:[NSString stringWithFormat:@"%@", [self.data objectForKey:@"referral_points"]]];
    [self.refpoints sizeToFit];
    
    CGRect oldFrame = self.points.frame;
    oldFrame.size.width = oldFrame.size.width+20;
    oldFrame.size.height = oldFrame.size.height+10;
    oldFrame.origin.x = 280-oldFrame.size.width;
    oldFrame.origin.x += 20;
    oldFrame.origin.y = 21+((60-oldFrame.size.height)/2);
    
    CGRect oldFrame2 = self.refpoints.frame;
    oldFrame2.size.width = oldFrame2.size.width+20;
    oldFrame2.size.height = oldFrame2.size.height+10;
    oldFrame2.origin.x = 280-oldFrame2.size.width;
    oldFrame2.origin.x += 20;
    oldFrame2.origin.y = 38+((60-oldFrame2.size.height)/2);
    
    CGRect personFrame = self.ref.frame;
    personFrame.origin.y = oldFrame2.origin.y + 5;
    personFrame.origin.x = oldFrame.origin.x+5;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if(screenWidth > 320){
        oldFrame.origin.x = screenWidth-75;
        oldFrame2.origin.x = screenWidth-75;
        personFrame.origin.x = screenWidth-75;
    }
    
    self.points.frame = oldFrame;
    self.refpoints.frame = oldFrame2;
    self.ref.frame = personFrame;
}

@end
