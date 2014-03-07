//
//  API.h
//  webview
//
//  Created by Misbah Khan on 2/22/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UILabel *points;
@property (nonatomic, strong) UILabel *referrals; 

+ (id)sharedInstance;

- (void) user;
- (void) refer:(NSString *)person;
- (void) stuff;
- (NSString *)serialNumber;
- (NSArray *) makeForData:(NSString *)data;

@end
