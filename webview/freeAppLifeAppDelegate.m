//
//  freeAppLifeAppDelegate.m
//  webview
//
//  Created by Adrian D'Urso on 1/11/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "freeAppLifeAppDelegate.h"
#import "API.h"
#import "Flurry.h"
#import <Parse/Parse.h>

@implementation freeAppLifeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [Parse setApplicationId:@"VZjp1eLHVpNpvqN5QOTZo24HoWn3BnIzKBTORGiM"
                  clientKey:@"4xGF0AROHkzm9DYSydmj1cSapsRaFY3mygIEgzu7"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
//	application.applicationIconBadgeNumber = 0;
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if(launchOptions!=nil){
        NSDictionary *msg = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        [self handleMsg:msg];
//        NSString *msg = [NSString stringWithFormat:@"%@", launchOptions];
//        [self createAlert:msg];
    }
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"MDMSSYYJ9VFQBQB2KW8H"];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [self handleMsg:userInfo];
    [PFPush handlePush:userInfo];
}

- (void) handleMsg:(NSDictionary *)userInfo{
    NSString *goTo = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"data"] objectForKey:@"tab"]];
    NSString *showMsg = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"data"] objectForKey:@"popup"]];
    int page = [goTo integerValue];
    int popUp = [showMsg integerValue];
    
    UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
    tab.selectedIndex = page;
    
    if(popUp){
        [self createAlert:[NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
    }
}

- (void)createAlert:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FreeAppLife" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
