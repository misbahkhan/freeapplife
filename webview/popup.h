//
//  popup.h
//  webview
//
//  Created by Misbah Khan on 2/6/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface popup : UIView

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *description;
- (void) show;
- (void) hide;

@end
