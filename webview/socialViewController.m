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
    IBOutlet UITextField *email;
    IBOutlet UITextField *code;
    UIWebView *web;
    API *sharedInstance;
    NSDictionary *historyData;
    UIAlertView *warning;
    IBOutlet UILabel *tweet_label;
    IBOutlet UIButton *tweet_button;
    IBOutlet UIImageView *email_button;
    IBOutlet UILabel *like_label;
    IBOutlet UIButton *like_button;
    IBOutlet UIButton *copy_code;
    BOOL connected;
    CustomIOS7AlertView *webAlert;
    BOOL loggedIn;
    BOOL redirectedToPage;
    BOOL liked;
    IBOutlet UIButton *goButton;
    IBOutlet UILabel *entries;
    IBOutlet UIImageView *giveaway_image;
    MFMessageComposeViewController *message;
    MFMailComposeViewController *emailview;
    SLComposeViewController *socialcompose;
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *smsButton;
    IBOutlet UIButton *tweetButton;
    IBOutlet UIButton *fbButton;
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
    
    email.delegate = self;
    code.delegate = self;
    
    giveaway_image.layer.cornerRadius = 5.0f;
    [giveaway_image setClipsToBounds:YES];
    
    sharedInstance = [API sharedInstance];
    historyData = [sharedInstance userData];
    code.text = [historyData objectForKey:@"referral_code"];
    //NSLog(@"%@", [historyData objectForKey:@"referral_code"]);
	// Do any additional setup after loading the view.
    
    
    NSURL* url = [NSURL URLWithString:@"https://developers.facebook.com/ios"];
    //    [FBDialogs presentShareDialogWithLink:url
    //                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
    //                                      if(error) {
    //                                          //NSLog(@"Error: %@", error.description);
    //                                      } else {
    //                                          //NSLog(@"Success!");
    //                                      }
    //                                  }];
    webAlert = [[CustomIOS7AlertView alloc] init];
    
    web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, 375)];
    //    [[web scrollView] setScrollEnabled:NO];
    web.delegate = self;
    [web.scrollView.layer setCornerRadius:10.0f];
    [web.scrollView clipsToBounds];
    [web.layer setCornerRadius:10.0f];
    [web clipsToBounds];
    //    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.facebook.com"]]];
    [webAlert setContainerView:web];
    //    [self.view addSubview:web];
    //    web.hidden = YES;
    
    UIView *topBar = [sharedInstance getBar];
    [self.view addSubview:topBar];
    
    _pointsLabel = [sharedInstance getPoints];
    [self.view addSubview:_pointsLabel];
    
    UIButton *refresh = [[UIButton alloc]initWithFrame:CGRectMake(5, 23, 34, 19)];
    [refresh setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [refresh addTarget:sharedInstance action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:[sharedInstance notificationName] object:nil];
    
    connected = FALSE;
    loggedIn = FALSE;
    redirectedToPage = FALSE;
    liked = FALSE;
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
        [message setBody:@"Download FreeAppLife NOW!"];
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
        [emailview setSubject:@"Get paid to try apps!"];
        [emailview setMessageBody:@"Download FreeAppLifeNow!" isHTML:NO];
        [self presentViewController:emailview animated:YES completion:nil];
    }else{
        UIAlertView *emailError = [[UIAlertView alloc] initWithTitle:@"Mail Unavailable" message:@"Please set up Mail on your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [emailError show];
    }
}

- (IBAction)tweet:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        socialcompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [socialcompose setInitialText:@"Download FreeAppLife Now!"];
        [self presentViewController:socialcompose animated:YES completion:nil];
    }else{
        UIAlertView *twitterError = [[UIAlertView alloc] initWithTitle:@"Twitter Unavailable" message:@"Please connect a Twitter account to your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [twitterError show];
    }
}

- (IBAction)status:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        socialcompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *facebookMessage = [NSString stringWithFormat:@"Download FreeAppLife Now! Use referral code: %@", [[sharedInstance userData] objectForKey:@"referral_code"]];
        [socialcompose setInitialText:facebookMessage];
        [self presentViewController:socialcompose animated:YES completion:nil];
    }else{
        UIAlertView *facebookError = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Please connect a Facebook account to your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [facebookError show];
    }
}

- (IBAction)aboutReferral:(id)sender {
    UIAlertView *referral = [[UIAlertView alloc] initWithTitle:@"Referral Code" message:@"Use your referral code to earn unlimited points by introducing your friends to FreeAppLife. Have them enter your code when prompted, during the signup process. Four Hundred points will be added to your account everytime someone you refer downloads sponsored applications and reaches 400 points." delegate:self cancelButtonTitle:@"Okay, Got It!" otherButtonTitles:nil, nil];
//    [referral show];
    [self sendRequest];
}

- (void)showEmail
{
    [email setHidden:NO];
    [email_button setHidden:NO];
}

- (void)hideEmail
{
    [email resignFirstResponder];
    [email setHidden:YES];
    [goButton setHidden:YES];
    [email_button setHidden:YES];
}

- (void)showTweet
{
    [tweet_button setHidden:NO];
    [tweet_label setHidden:NO];
}

- (void)hideTweet
{
    [tweet_button setHidden:YES];
    [tweet_label setHidden:YES];
}

- (void)showLike
{
    [like_button setHidden:NO];
    [like_label setHidden:NO];
}

- (void)hideLike
{
    [like_button setHidden:YES];
    [like_label setHidden:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [sharedInstance user];
}

- (void) dataUpdated:(id)sender
{
    _pointsLabel.text = [sharedInstance currentPoints];
    //    if([[[sharedInstance userData] objectForKey:@"points"] intValue]>400){
    
    entries.text = [NSString stringWithFormat:@"%@",[sharedInstance giveaway]];
    
    [code setText:[[sharedInstance userData] objectForKey:@"referral_code"]];
    //    }else{
    //        [code setText:@"Unlock at 400 pts"];
    //    }
    if(!([[[sharedInstance userData] objectForKey:@"twitter"] isEqualToString:@"DONE"])){
        [self showTweet];
    }
    
    if(!([[[sharedInstance userData] objectForKey:@"facebook"] isEqualToString:@"DONE"])){
        [self showLike];
    }else{
        [self hideLike];
    }
    
    if([[[sharedInstance userData] objectForKey:@"email"] length]<1){
        [self showEmail];
    }
}

- (IBAction)like:(id)sender {
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.facebook.com"]]];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(loggedIn == FALSE){
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"home.php" options:NSRegularExpressionCaseInsensitive error:&error];
        NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"s-static.ak" options:NSRegularExpressionCaseInsensitive error:&error];
        if (error){}
        NSUInteger regexNums = [regex numberOfMatchesInString:[[request URL] absoluteString] options:0 range:NSMakeRange(0, [[[request URL] absoluteString] length])];
        NSUInteger regexNums2 = [regex2 numberOfMatchesInString:[[request URL] absoluteString] options:0 range:NSMakeRange(0, [[[request URL] absoluteString] length])];
        if(regexNums > 0 || regexNums2 > 0){
            [webAlert close];
            [self hideLike];
            loggedIn = TRUE;
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://facebook.com/freeapplife"]]];
            redirectedToPage = TRUE;
        }
    }
    return YES;
}


- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if (loggedIn != TRUE) {
        [webAlert show];
    }
    
    if(redirectedToPage == TRUE){
        [webView
         stringByEvaluatingJavaScriptFromString:
         @"var isLiking = document.getElementsByClassName(\"_4g34\")[2].children[0].children[1].innerHTML; if(isLiking=='Like'){document.getElementsByClassName(\"_4g34\")[2].children[0].click()}"];
        NSString *postString = [NSString stringWithFormat:@"userID=%@&social=facebook", [sharedInstance md5ForString: [sharedInstance serialNumber]]];
        NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"social" andBody:postString];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){}];
        liked = TRUE;
    }
    
    if (liked == TRUE) {}
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
                        dataWithJSONObject:@{
                                             @"social_karma": @"5",
                                             @"badge_of_awesomeness": @"1"}
                        options:0
                        error:&error];
    if (!jsonData) {
        //NSLog(@"JSON error: %@", error);
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

- (IBAction)submitEmail:(id)sender {
    if([[email text] length] > 0){
        if ([[email text] rangeOfString:@"@"].location != NSNotFound) {
            if ([[email text] rangeOfString:@"."].location != NSNotFound) {
                NSString *postString = [NSString stringWithFormat:@"userID=%@&email=%@", [sharedInstance md5ForString: [sharedInstance serialNumber]], [email text]];
                NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"email" andBody:postString];
                
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if([data length] > 0){
                        //NSLog(@"%@", response);
                        NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        //NSLog(@"%@", strData);
                        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                        if([json objectForKey:@"status"]){
                            [self hideEmail];
                        }
                    }
                }];
            }else{
                //NSLog(@"nope");
            }
        }
    }
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == email){
        goButton.hidden = NO;
    }
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == email){
        goButton.hidden = YES; 
    }
    [textField resignFirstResponder];
    return YES;
}


- (void)fetchTimelineForUser:(NSString *)username
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
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/friendships/create.json"];
                 NSDictionary *params = @{@"screen_name" : @"freeapplife",
                                          @"follow" : @"true"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                              URL:url
                                       parameters:params];
                 
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
                                  [self retweet:@"443123073655398400"];
                                  
                                  NSString *postString = [NSString stringWithFormat:@"userID=%@&social=twitter", [sharedInstance md5ForString: [sharedInstance serialNumber]]];
                                  //NSLog(@"%@", [sharedInstance md5ForString:[sharedInstance serialNumber]]);
                                  NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"social" andBody:postString];
                                  
                                  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                      if([data length] > 0){
                                          //NSLog(@"%@", response);
                                          NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                          //NSLog(@"%@", strData);
                                          NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                          if([json objectForKey:@"status"]){
                                              [self hideTweet];
                                          }
                                      }
                                  }];
                                  [sharedInstance tweet:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Score points at: https://freeapplife.com  #FAL #FreeAppLife"]; 
                                  //NSLog(@"%@", [[timelineData objectForKey:@"status"] objectForKey:@"id"]);
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  //NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              //NSLog(@"The response status code is %d",urlResponse.statusCode);
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
    if(alertView == warning){
        [self getTwitterAccountInformation];
    }
}

- (IBAction)fetch:(id)sender {
    //NSLog(@"fetch");
    //    [self fetchTime:@"freeapplife"];
    //    [self fetchTimelineForUser:@"themisbahkhan"];
    warning = [[UIAlertView alloc] initWithTitle:@"Allow Access" message:@"To earn the points for connecting Twitter, please allow access to accounts." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [warning show];
}

- (void)getTwitterAccountInformation
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            //NSLog(@"granted");
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                //NSLog(@"%@",twitterAccount.username);
                //NSLog(@"%@",twitterAccount.accountType);
                //                [self fetchTime:@"freeapplife"];
                [self fetchTimelineForUser:twitterAccount.username];
            }else{
                //NSLog(@"else");
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *connectTwitter = [[UIAlertView alloc] initWithTitle:@"Connect a Twitter Account" message:@"Plesase connect a Twitter account to your device first. To earn the credits go into Settings > Twitter and enter your credentials and sign in." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                    [connectTwitter show];
                });
            }
        }else{
            //NSLog(@"failed");
        }
    }];
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
