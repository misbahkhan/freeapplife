//
//  popUp.h
//  FreeAppLife
//
//  Created by Misbah Khan on 5/7/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol popUpDelegate

- (void)buttonClicked:(id)offerView;

@end

@interface popUp : UIView

@property (nonatomic, strong) UIView *main;
@property (nonatomic, strong) UIView *inner;
-(id)initWithPop;
//-(id)initWithInner:(UIView *)inner;
-(void) show;
-(void) hide;
-(void) resize; 
@end

