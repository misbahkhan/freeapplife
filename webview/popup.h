//
//  popUp.h
//  FreeAppLife
//
//  Created by Misbah Khan on 5/7/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface popUp : UIView

@property (nonatomic, strong) UIView *main;
@property (nonatomic, strong) UIView *inner;
-(id)initWithPop;
-(void) show;
-(void) hide;
-(void) resize; 
@end

