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
@property (nonatomic, strong) NSMutableDictionary *pend;
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) UIImageView *topBar;
@property (nonatomic, strong) UILabel *points;
@property (nonatomic, strong) UILabel *referrals; 
@property (nonatomic, strong) NSString *notificationName;
@property (nonatomic, strong) NSString *sponsorPayHelp;
@property (nonatomic, strong) NSString *aarkiHelp;
@property (nonatomic, strong) NSString *appURL;
@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, assign) int refshown;
@property (nonatomic, assign) BOOL sponsoralert;

//@property (nonatomic, strong) NSData *token;



+ (id)sharedInstance;

- (void) user;
- (void) userpend;
- (void) clear; 
- (void) refer:(NSString *)person;
- (void) tweet:(NSString *)message;
- (void) token;
- (NSString *) idfa; 
- (NSString *) mk;
- (NSString *) mk2;
- (UILabel *) getPoints;
- (NSString *) currentPoints;
- (NSString *) giveaway; 
- (NSString *) md5ForString:(NSString *)string;
- (NSString *) shapeforstring:(NSString *)string;
- (UIView *) getBar;
- (NSMutableURLRequest *) requestForEndpoint:(NSString *)endPoint andBody:(NSString *)postString;
- (NSString *)userID; 
- (NSString *)serialNumber;
- (NSArray *) makeForData:(NSString *)data;
- (NSArray *) runningProcesses;
- (void) pending:(int)state fordata:(NSDictionary *)data withnice:(NSString *)nice;

@end
