//
//  offerPopUp.h
//  FreeAppLife
//
//  Created by Misbah Khan on 5/10/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "popup.h"

@interface offerPopUp : popUp

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) UIWebView *web;

- (id) initWithData:(NSDictionary *)data;

- (void) afterMessage;
- (void) pause;
@end
