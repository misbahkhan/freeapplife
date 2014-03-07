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
        // Initialization code
        _view = [[UIView alloc] initWithFrame:CGRectMake(19, 6, 280, 90)];
        [_view setBackgroundColor:[UIColor colorWithRed:242.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
        [_view.layer setCornerRadius:5.0f];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(98, 18, 182, 65)];
        [_label setNumberOfLines:3];
//        _points = [[UILabel alloc] initWithFrame:CGRectMake(98, 65, 192, 20)];
//        [_points setNumberOfLines:1];
        _image = [[UIImageView alloc] initWithFrame:CGRectMake(30, 21, 60, 59)];
        _image.layer.cornerRadius = 10.0f;
        [_image setClipsToBounds:YES]; 
        [self.contentView addSubview:_view];
        [self.contentView addSubview:_image];
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_points];
        
        NSDictionary *data = [[NSDictionary alloc] init]; 
    }
    return self;
}

- (void) outline
{
    self.view.layer.borderColor = [UIColor blueColor].CGColor;
    self.view.layer.borderWidth = 3.0f;
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
