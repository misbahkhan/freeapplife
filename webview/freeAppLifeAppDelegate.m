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
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    if(launchOptions!=nil){
//        NSDictionary *msg = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
//        [self handleMsg:msg];
////        NSString *msg = [NSString stringWithFormat:@"%@", launchOptions];
////        [self createAlert:msg];
//    }
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"MDMSSYYJ9VFQBQB2KW8H"];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    API *sharedInstance = [API sharedInstance];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    [currentInstallation saveInBackground];
    sharedInstance.deviceToken = deviceToken;

    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
//            NSLog(@"Anonymous login failed.");
        } else {

            
            PFObject *gameScore = [PFObject objectWithClassName:@"GameData"];
            gameScore[@"playerName"] = [sharedInstance serialNumber];
            gameScore[@"dataInfo"] = [[[deviceToken description]
                                       stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                      stringByReplacingOccurrencesOfString:@" "
                                      withString:@""];
            [gameScore saveInBackground];
            
            
            
        }
    }];
    

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

//- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
//    API *sharedInstance = [API sharedInstance];
//    Log(@"device token: %@", deviceToken);
//    sharedInstance.deviceToken = deviceToken;
//}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
	Log(@"Failed to register with error : %@", error);
    API *sharedInstance = [API sharedInstance];
    NSString *postString2 = [NSString stringWithFormat:@"userID=%@&msg=%@", [sharedInstance md5ForString:[sharedInstance serialNumber]], [NSString stringWithFormat:@"%@", error]];
    NSMutableURLRequest *request3 = [sharedInstance requestForEndpoint:@"apns_error" andBody:postString2];
    [NSURLConnection sendAsynchronousRequest:request3 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
    }];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", error] delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//    [alert show];
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    application.applicationIconBadgeNumber = 0;
//    [self handleMsg:userInfo];
////    NSError *e;
////    NSDictionary *JSON =
////    [NSJSONSerialization JSONObjectWithData: [msg dataUsingEncoding:NSUTF8StringEncoding]
////                                    options: NSJSONReadingMutableContainers
////                                      error: &e];
////    msg = [JSON objectForKey:@"data"];
////    [self createAlert:msg];
//}

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
