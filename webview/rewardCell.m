//
//  rewardCell.m
//  webview
//
//  Created by Misbah Khan on 1/28/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "rewardCell.h"

@implementation rewardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

//        _image = [[lazyImage alloc] initWithFrame:CGRectMake(0, 0, 60, 59)];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(98, 18, 150, 65)];
        [_label setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        [_label setNumberOfLines:3];
        _label.opaque = NO;
        
        _points = [[UILabel alloc] initWithFrame:CGRectMake(30, 21, 192, 20)];
        [_points setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        _points.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
//        _points.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
//        _points.layer.borderWidth = 1.25f;
//        _points.layer.cornerRadius = 2.5f;
        [_points setTextAlignment:NSTextAlignmentCenter];
//        [_points setNumberOfLines:1];
        _points.opaque = NO;
        
        _image = [[UIImageView alloc] initWithFrame:CGRectMake(30, 21, 60, 59)];
        _image.layer.cornerRadius = 10.0f;
        [_image setClipsToBounds:YES];
        
        [self.contentView addSubview:_image];
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_points];
        
//        [self.contentView addSubview:_cell];
//        [self.contentView addSubview:_image];
    }
    return self;
}

        // Initialization code

@end
