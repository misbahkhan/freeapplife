//
//  API.h
//  webview
//
//  Created by Misbah Khan on 2/22/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) UIImageView *topBar;
@property (nonatomic, strong) UILabel *points;
@property (nonatomic, strong) UILabel *referrals; 
@property (nonatomic, strong) NSString *notificationName;
@property (nonatomic, strong) NSString *sponsorPayHelp;
@property (nonatomic, strong) NSString *appURL;
@property (nonatomic, strong) NSData *token;

+ (id)sharedInstance;

- (void) user;
- (void) clear; 
- (void) refer:(NSString *)person;
- (void) stuff;
- (void) tweet:(NSString *)message; 
- (UILabel *) getPoints;
- (NSString *) currentPoints;
- (NSString *) giveaway; 
- (NSString *) md5ForString:(NSString *)string;
- (UIView *) getBar;
- (NSMutableURLRequest *) requestForEndpoint:(NSString *)endPoint andBody:(NSString *)postString;
- (NSString *)userID; 
- (NSString *)serialNumber;
- (NSArray *) makeForData:(NSString *)data;

@end
