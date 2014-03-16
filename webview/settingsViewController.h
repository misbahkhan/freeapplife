//
//  settingsViewController.h
//  webview
//
//  Created by Misbah Khan on 1/28/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@interface settingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CustomIOS7AlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UILabel *pointsLabel; 
@end
