//
//  freeAppLifeViewController.h
//  webview
//
//  Created by Adrian D'Urso on 1/11/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "popView.h"
#import "CustomIOS7AlertView.h"

@interface freeAppLifeViewController : UIViewController <UIWebViewDelegate, UITabBarDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,CustomIOS7AlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
