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
#import <MessageUI/MessageUI.h>
#import "CustomIOS7AlertView.h"

@interface socialViewController () {
    IBOutlet UITextField *code;
    UIWebView *web;
    API *sharedInstance;
    NSDictionary *historyData;
    UIAlertView *warning;
    IBOutlet UIButton *copy_code;
    BOOL connected;
    CustomIOS7AlertView *webAlert;
    BOOL loggedIn;
    BOOL redirectedToPage;
    BOOL liked;
    IBOutlet UIImageView *giveaway_image;
    MFMessageComposeViewController *message;
    MFMailComposeViewController *emailview;
    SLComposeViewController *socialcompose;
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *smsButton;
    IBOutlet UIButton *tweetButton;
    IBOutlet UIButton *fbButton;
    IBOutlet UILabel *referrals_number;
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
    code.delegate = self;
    
    giveaway_image.layer.cornerRadius = 5.0f;
    [giveaway_image setClipsToBounds:YES];
    
    sharedInstance = [API sharedInstance];
    historyData = [sharedInstance userData];
    code.text = [historyData objectForKey:@"referral_code"];

    
    UIView *topBar = [sharedInstance getBar];
    [self.view addSubview:topBar];
    
    _pointsLabel = [sharedInstance getPoints];
    [self.view addSubview:_pointsLabel];
    
    UIButton *refresh = [[UIButton alloc]initWithFrame:CGRectMake(5, 23, 34, 19)];
    [refresh setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [refresh addTarget:sharedInstance action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:[sharedInstance notificationName] object:nil];
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [message dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [emailview dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sms:(id)sender {
    if([MFMessageComposeViewController canSendText]){
        message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        NSString *smsMessage = [NSString stringWithFormat:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Score points at: http://freeapplife.com Use my referral code \"%@\" for 50 additional points when you sign up!", [[sharedInstance userData] objectForKey:@"referral_code"]];
        [message setBody:smsMessage];
        [self presentViewController:message animated:YES completion:nil];
    }else{
        UIAlertView *smsError = [[UIAlertView alloc] initWithTitle:@"iMessage Unavailable" message:@"Please set up iMessage on your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [smsError show];
    }
}

- (IBAction)email:(id)sender {
    if([MFMailComposeViewController canSendMail]){
        emailview = [[MFMailComposeViewController alloc] init];
        emailview.mailComposeDelegate = self;
        [emailview setSubject:@"Try FreeAppLife!"];
        NSString *emailMessage = [NSString stringWithFormat:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Visit http://www.freeapplife.com and use my referral code \"%@\" when singining up to earn 50 bonus points. Save up to earn Gift Cards, electronics and more for free!", [[sharedInstance userData] objectForKey:@"referral_code"]];
        [emailview setMessageBody:emailMessage isHTML:NO];
        [self presentViewController:emailview animated:YES completion:nil];
    }else{
        UIAlertView *emailError = [[UIAlertView alloc] initWithTitle:@"Mail Unavailable" message:@"Please set up Mail on your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [emailError show];
    }
}

- (IBAction)tweet:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        socialcompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *twitterMessage = [NSString stringWithFormat:@"Join the FreeAppLife NOW to earn Paid iOS apps & Gift Cards for Free! http://freeapplife.com Use my referral code \"%@\" for +50 points!", [[sharedInstance userData] objectForKey:@"referral_code"]];
        [socialcompose setInitialText:twitterMessage];
        [self presentViewController:socialcompose animated:YES completion:nil];
    }else{
        UIAlertView *twitterError = [[UIAlertView alloc] initWithTitle:@"Twitter Unavailable" message:@"Please connect a Twitter account to your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [twitterError show];
    }
}

- (IBAction)status:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        socialcompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *facebookMessage = [NSString stringWithFormat:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Score points at: http://freeapplife.com Use my referral code \"%@\" for 50 additional points when you sign up!", [[sharedInstance userData] objectForKey:@"referral_code"]];
        [socialcompose setInitialText:facebookMessage];
        [self presentViewController:socialcompose animated:YES completion:nil];
    }else{
        UIAlertView *facebookError = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Please connect a Facebook account to your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [facebookError show];
    }
}

- (IBAction)invite:(id)sender {
    [self sendRequest];
}

- (IBAction)aboutReferral:(id)sender {
    UIAlertView *referral = [[UIAlertView alloc] initWithTitle:@"Referral Code" message:@"Your referral code has the potential to grant an unlimited number of points when referring new users to FreeAppLife. Simply send your referral code to friends and family and remind them to input the code when they first launch the app. 50% of the points generated by each new user you refer to the service will be credited to your account." delegate:self cancelButtonTitle:@"Okay, Got It!" otherButtonTitles:nil, nil];
    [referral show];
}

- (void) viewDidAppear:(BOOL)animated
{
    [sharedInstance user];
}

- (void) dataUpdated:(id)sender
{
    _pointsLabel.text = [sharedInstance currentPoints];
    [code setText:[[sharedInstance userData] objectForKey:@"referral_code"]];
    [referrals_number setText:[NSString stringWithFormat:@"You have referred %d people.", [[[sharedInstance userData] objectForKey:@"referrals_count"] intValue]]];
}

- (IBAction)copy:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [code text];
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
                        dataWithJSONObject:@{@"referral": [[sharedInstance userData] objectForKey:@"referral_code"]}
                        options:0
                        error:&error];
    if (!jsonData) {return;}
    NSString *giftStr = [[NSString alloc]
                         initWithData:jsonData
                         encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* params = [@{@"data" : giftStr} mutableCopy];
    
    // Display the requests dialog
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Join FreeAppLife!"
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             //NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 //NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     //NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     //NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == code){
        return NO;
    }else{
        return YES;
    }
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)retweet:(NSString *)tweetId
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com"
                                                    @"/1.1/statuses/retweet/%@.json", tweetId]];
                 //                 NSDictionary *params = @{@"screen_name" : @"freeapplife",
                 //                                          @"follow" : @"true"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                              URL:url
                                       parameters:nil];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts firstObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              NSDictionary *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  //                                  //NSLog(@"Timeline Response: %@\n", timelineData);
                                  //NSLog(@"user: %@", [[timelineData objectForKey:@"status"] objectForKey:@"id"]);
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  //NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              //NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 //NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}


- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}



- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
