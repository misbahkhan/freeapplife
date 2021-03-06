//
//  socialViewController.h
//  webview
//
//  Created by Misbah Khan on 2/28/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CustomIOS7AlertView.h"
#import <MessageUI/MessageUI.h>

@interface socialViewController : UIViewController<UITextFieldDelegate, FBLoginViewDelegate, UIWebViewDelegate, UIAlertViewDelegate, CustomIOS7AlertViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UILabel *pointsLabel; 

@end
