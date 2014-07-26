//
//  settingsViewController.m
//  webview
//
//  Created by Misbah Khan on 1/28/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "settingsViewController.h"
#import "CustomIOS7AlertView.h"
#import "API.h"
#import "rewardCell.h"
#import <Parse/Parse.h>

@interface settingsViewController ()
{
//    ACAccountStore *accountStore;
    API *sharedInstance;
    UITableView *history;
    NSMutableArray *historyData;
    UITextField *email;
    UITextField *referral;
    UITextField *password;
    IBOutlet UIButton *restore_button;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
    IBOutlet UISwitch *goneFreeSwitch;
}

@end

@implementation settingsViewController

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
//    accountStore = [[ACAccountStore alloc] init];
	// Do any additional setup after loading the view.
    sharedInstance = [API sharedInstance];
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    float y = 150;
    history = [[UITableView alloc] initWithFrame:CGRectMake(0, y, screenWidth, screenHeight-150)];
    history.delegate = self;
    history.dataSource = self;
    [history setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:history];
    
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

- (IBAction)setSwitch:(id)sender {
    if(goneFreeSwitch.on){
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:@"GoneFree" forKey:@"channels"];
        [currentInstallation saveInBackground];
    }else{
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObject:@"GoneFree" forKey:@"channels"];
        [currentInstallation saveInBackground];
    }
}

- (void) dataUpdated:(id)sender
{
    _pointsLabel.text = [sharedInstance currentPoints];
//    historyData = [[sharedInstance userData] objectForKey:@"reward_history"];
//    [history reloadData];
    
    if([[[sharedInstance userData] objectForKey:@"migrated"] intValue] == 0){
//        NSLog(@"not migrated");
        [restore_button setHidden:NO];
    }else{
        [restore_button setHidden:YES]; 
    }
}

- (void) getHistory {
    NSString *postString = [NSString stringWithFormat:@"userID=%@",[sharedInstance md5ForString:[sharedInstance serialNumber]]];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"rewardHistory" andBody:postString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        int responseStatusCode = [httpResponse statusCode];
        if(responseStatusCode == 200 && [data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            historyData = [[json objectForKey:@"history"] mutableCopy];
            [history reloadData];
        }
    }];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [historyData count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [[historyData objectAtIndex:indexPath.row] objectForKey:@"code"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rewardCell"];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"rewardCell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (-%@)", [[historyData objectAtIndex:indexPath.row] objectForKey:@"code"], [[historyData objectAtIndex:indexPath.row] objectForKey:@"points"]];
    cell.detailTextLabel.text = [[historyData objectAtIndex:indexPath.row] objectForKey:@"reward"];
//    cell.image.image = nil;
//    cell.data = [historyData objectAtIndex:indexPath.row];
    return cell;
}

- (void) viewDidAppear:(BOOL)animated
{
    [sharedInstance user];
    [self getHistory];
    NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
    if([subscribedChannels containsObject:@"GoneFree"]){
        [goneFreeSwitch setOn:YES];
    }
}


- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [alertView close];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)restore:(id)sender
{
    CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
    
    UIView *restoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 230)];
    [restoreView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *restoreViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 240, 100)];
    [restoreViewTitle setText:@"To restore your points from your previous FAL 2.0 account, type in your crednetials below!"];
    [restoreViewTitle setNumberOfLines:4];
    [restoreViewTitle setTextAlignment:NSTextAlignmentCenter];
    
    email = [[UITextField alloc] initWithFrame:CGRectMake(20, 110, 240, 32)];
    [email setBorderStyle:UITextBorderStyleRoundedRect];
    [email setDelegate:self];
    [email setPlaceholder:@"Email Address"];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(20, 152, 240, 32)];
    [password setBorderStyle:UITextBorderStyleRoundedRect];
    [password setSecureTextEntry:YES];
    [password setDelegate:self];
    [password setPlaceholder:@"Password"];
    
    [restoreView addSubview:restoreViewTitle];
    [restoreView addSubview:email];
    [restoreView addSubview:password]; 
    
    [alert setDelegate:self];
    [alert setContainerView:restoreView];
    [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Migrate", nil]];
    [alert show];
    
    [alert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        if(buttonIndex == 1){
//            NSLog(@"migrate");
//            NSLog(@"%@", [email text]);
//            NSLog(@"%@", [password text]);
            NSString *postString = [NSString stringWithFormat:@"userID=%@&email=%@&password=%@",[sharedInstance md5ForString:[sharedInstance serialNumber]], [email text], [password text]];
            NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"regainData" andBody:postString];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                NSLog(@"%@", response);
                NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(@"user: %@", strData);
                
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                int responseStatusCode = [httpResponse statusCode];
//                NSLog(@"%d", responseStatusCode);
                
                if(responseStatusCode == 204){
                    UILabel *error = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 240, 50)];
                    [error setText:@"Error, wrong credentials or already migrated."];
                    [error setTextAlignment:NSTextAlignmentCenter];
                    [error setNumberOfLines:2];
                    [restoreView addSubview:error];
                    [alertView setContainerView:restoreView];
                }
                
                if([data length] > 0){
                    if ([[json objectForKey:@"status"] isEqualToString:@"Failed"] || responseStatusCode == 204) {
                        UILabel *error = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 240, 50)];
                        [error setText:@"Error, wrong credentials or already migrated."];
                        [error setTextAlignment:NSTextAlignmentCenter];
                        [error setNumberOfLines:2];
                        [restoreView addSubview:error];
                        [alertView setContainerView:restoreView];
                    }else{
                        [alertView close];
                        [sharedInstance user];
                        [restore_button setHidden:YES];
                    }
                }

            }];
        }else{
            
        }
    }];
}

- (IBAction)troubleshoot:(id)sender {
    CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
    
    UIView *troubleshootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 290)];
    [troubleshootView setBackgroundColor:[UIColor clearColor]];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 280, 290) textContainer:nil];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setEditable:NO];
    [text setText:@"1. Leave apps open for 60+ seconds.\n2. If you already have an app installed and you're attempting to claim points for it, delete the app first and then attempt to download said app again from the Get Points section.\n3. Pull down on the sponsored wall to refresh the listings and ensure that your device has access to the latest offers.\n4. If you've installed an offer from a similar service within the past 30 days, your device may no longer be eligible for said offer - switch to a new device if possible.\n5. Wi-Fi will speed the process up.\n6. Navigate to the Settings app, tap General, followed by Profiles and delete all non-essential Profiles, as they could conflict with FreeAppLife.\n7. Refer to the pop-ups; some offers require additional steps to complete.\n8. Select offers may take an upwards of 48 hours to credit your account."];
    [troubleshootView addSubview:text];
    [alert setDelegate:self];
    [alert setContainerView:troubleshootView];
    [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"Close", nil]];
    [alert show];
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
