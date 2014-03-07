//
//  popup.m
//  webview
//
//  Created by Misbah Khan on 2/6/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "popup.h"

@implementation popup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        UIToolbar *blurbar = [[UIToolbar alloc] initWithFrame:self.frame];
        blurbar.barStyle = UIBarStyleDefault;
        blurbar.clipsToBounds = YES;
        [blurbar.layer setCornerRadius:9.0f];
        [self addSubview:blurbar];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        titleLabel.text = _title;
        [self addSubview:titleLabel];

        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        descriptionLabel.text = _description;
        [self addSubview:descriptionLabel];
        
//        UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 100, 22)];
//        [close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
//        
//        [close setBackgroundColor:[UIColor blackColor]];
//        [self addSubview:close];
        
        
    }
    return self;
}

- (void) show {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _window.windowLevel = UIWindowLevelAlert;
    _window.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
    
    self.center = CGPointMake(160.0f, CGRectGetMidY(_window.bounds));
    
    [_window addSubview:self];
    [_window makeKeyAndVisible];
}

- (void) hide {
    _window.hidden = YES;
    _window = nil;
    [self removeFromSuperview];
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
