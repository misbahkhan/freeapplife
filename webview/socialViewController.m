//
//  socialViewController.m
//  webview
//
//  Created by Misbah Khan on 2/28/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "socialViewController.h"
#import "API.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface socialViewController (){
    IBOutlet UITextField *email;
    IBOutlet UITextField *code;
    UIWebView *web;
    API *sharedInstance;
    NSDictionary *historyData;
}

@end

@implementation socialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    email.font = [UIFont fontWithName:@"Roboto Regular" size:1.0f];
    code.font = [UIFont fontWithName:@"Roboto" size:1.0f];
    
    email.delegate = self;
    code.delegate = self;
    
    sharedInstance = [API sharedInstance];
    historyData = [sharedInstance userData];
    code.text = [historyData objectForKey:@"referral_code"];
	// Do any additional setup after loading the view.
    
    NSLog(@"%d", FBSession.activeSession.isOpen);
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone];
    loginView.delegate = self;
    CGRect loginFrame = loginView.frame;
    loginFrame.origin = CGPointMake(50, 350);
    loginView.frame = loginFrame;
    [self.view addSubview:loginView];

    
    NSURL* url = [NSURL URLWithString:@"https://developers.facebook.com/ios"];
    [FBDialogs presentShareDialogWithLink:url
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error: %@", error.description);
                                      } else {
                                          NSLog(@"Success!");
                                      }
                                  }];
    web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 250, 320, 75)];
    [[web scrollView] setScrollEnabled:NO];
    web.delegate = self;
    [self.view addSubview:web];
    
    [self sendRequest];

}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.facebook.com/plugins/like.php?href=https%3A%2F%2Fwww.facebook.com%2Ffreeapplife&width=200&layout=button&action=like&show_faces=false&share=false&height=35&appId=676776645708419"]]];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)sendRequest {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:@{
                                             @"social_karma": @"5",
                                             @"badge_of_awesomeness": @"1"}
                        options:0
                        error:&error];
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
        return;
    }
    
    NSString *giftStr = [[NSString alloc]
                         initWithData:jsonData
                         encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* params = [@{@"data" : giftStr} mutableCopy];
    
    // Display the requests dialog
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Learn how to make your iOS apps social."
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
