//
//  videoViewController.h
//  FreeAppLife
//
//  Created by Misbah Khan on 7/3/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface videoViewController : UIViewController <UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *web;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end
