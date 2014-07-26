//
//  goneFreeViewController.h
//  FreeAppLife
//
//  Created by Misbah Khan on 7/11/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface goneFreeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *goneFreeTable;
@property (strong, nonatomic) UILabel *pointsLabel; 
@end
