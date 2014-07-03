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
#import "TWTSideMenuViewController.h"
#import "mainViewController.h"
#import "menuViewController.h"

@interface freeAppLifeAppDelegate ()

@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
@property (nonatomic, strong) menuViewController *menuViewController;
@property (nonatomic, strong) mainViewController *mainViewController;

@end


@implementation freeAppLifeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [Parse setApplicationId:@"VZjp1eLHVpNpvqN5QOTZo24HoWn3BnIzKBTORGiM"
                  clientKey:@"4xGF0AROHkzm9DYSydmj1cSapsRaFY3mygIEgzu7"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    self.menuViewController = (menuViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"menu"];
    
    
    self.mainViewController = [[mainViewController alloc] initWithNibName:nil bundle:nil];
    
    // create a new side menu
    self.sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.menuViewController mainViewController:[[UINavigationController alloc] initWithRootViewController:self.mainViewController]];
    
    // specify the shadow color to use behind the main view controller when it is scaled down.
    self.sideMenuViewController.shadowColor = [UIColor blackColor];
    
    // specify a UIOffset to offset the open position of the menu
    self.sideMenuViewController.edgeOffset = UIOffsetMake(18.0f, 0.0f);
    
    // specify a scale to zoom the interface — the scale is 0.0 (scaled to 0% of it's size) to 1.0 (not scaled at all). The example here specifies that it zooms so that the main view is 56.34% of it's size in open mode.
    self.sideMenuViewController.zoomScale = 0.5634f;
    
    // set the side menu controller as the root view controller
    self.window.rootViewController = self.sideMenuViewController;

    
    
    
    
    
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
