//
//  freeAppLifeAppDelegate.m
//  webview
//
//  Created by Adrian D'Urso on 1/11/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "freeAppLifeAppDelegate.h"
#import "API.h"

@implementation freeAppLifeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
	application.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    if(launchOptions!=nil){
        NSString *msg = [NSString stringWithFormat:@"%@", launchOptions];
        NSLog(@"%@",msg);
        [self createAlert:msg];
    }
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
	NSLog(@"deviceToken: %@", deviceToken);
    API *sharedInstance = [API sharedInstance];
    NSString *postString2 = [NSString stringWithFormat:@"userID=%@&token=%@", [sharedInstance md5ForString:[sharedInstance serialNumber]], [NSString stringWithFormat:@"%@", deviceToken]];
    NSMutableURLRequest *request3 = [sharedInstance requestForEndpoint:@"push" andBody:postString2];
    [NSURLConnection sendAsynchronousRequest:request3 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ALERT" message:[NSString stringWithFormat:@"%@, %@", deviceToken, postString2] delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
	NSLog(@"Failed to register with error : %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", error] delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    NSLog(@"%@",msg);
    [self createAlert:msg];
}

- (void)createAlert:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
