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
#import <StoreKit/StoreKit.h>

@interface freeAppLifeViewController : UIViewController <UIWebViewDelegate, UITabBarDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,CustomIOS7AlertViewDelegate,SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UILabel *pointsLabel; 
@property (weak, nonatomic) IBOutlet UISegmentedControl *videos;


@end
