//
//  rewardsViewController.h
//  webview
//
//  Created by Adrian D'Urso on 1/18/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@interface rewardsViewController : UIViewController <UIAlertViewDelegate, CustomIOS7AlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
