//
//  popUp.m
//  FreeAppLife
//
//  Created by Misbah Khan on 5/7/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "popUp.h"

@implementation popUp

- (void) resize
{
    CGRect oldMain = self.main.frame;
    
    float x = [UIScreen mainScreen].bounds.size.width/2;
    x -= (self.inner.frame.size.width+30)/2;
    
    float y = [UIScreen mainScreen].bounds.size.height/2;
    y -= (self.inner.frame.size.height+10)/2;
    
    oldMain.origin.y = y;
    oldMain.origin.x = x;
    
    oldMain.size.height = self.inner.frame.size.height+10;
    
    self.main.frame = oldMain;
}

- (id) initWithPop
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        _inner = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 280, 475)];
        [_inner setBackgroundColor:[UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1]];
        _inner.layer.cornerRadius = 10.0f;
        [_inner setClipsToBounds:YES]; 
        _main = [[UIView alloc] initWithFrame:CGRectMake(5, 25, 290, 490)];
        [self addSubview:_main];
        [_main addSubview:_inner];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
        [button setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [_main addSubview:button];
    }
    return self;
}

- (void)show
{
    [self resize]; 
    _main.layer.shouldRasterize = YES;
    _main.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _main.layer.opacity = 0.5f;
    _main.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _main.layer.opacity = 1.0f;
                         _main.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];
}

- (void)hide
{
    CATransform3D currentTransform = _inner.layer.transform;
    
    CGFloat startRotation = [[_inner valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
    
    _main.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    _main.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _main.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _main.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        _inner = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 280, frame.size.height)];
        [_inner setBackgroundColor:[UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1]];
        _inner.layer.cornerRadius = 10.0f;
        [_inner setClipsToBounds:YES];
        float y = [UIScreen mainScreen].bounds.size.height/2;
        y -= (frame.size.height+15)/2;
        
        _main = [[UIView alloc] initWithFrame:CGRectMake(5, y, 290, frame.size.height+15)];
        [self addSubview:_main];
        [_main addSubview:_inner];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
        [button setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [_main addSubview:button];
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
