//
//  menuViewController.m
//  FreeAppLife
//
//  Created by Misbah Khan on 7/2/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "menuViewController.h"
#import "TWTSideMenuViewController.h"

@interface menuViewController (){
    NSArray *menuOne, *menuTwo;
}

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;


@end

@implementation menuViewController

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
    
//
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
//
    CGRect imageViewRect = [[UIScreen mainScreen] bounds];
    imageViewRect.size.width += 589;
    self.backgroundImageView.frame = imageViewRect;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSDictionary *viewDictionary = @{ @"imageView" : self.backgroundImageView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]" options:0 metrics:nil views:viewDictionary]];
    
    menuOne = [[NSArray alloc] initWithObjects:@"Get Points", @"Videos", @"Rewards", @"Social", @"Settings", nil];
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 234, 45)];
//    [view setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.65f]];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 204, 45)];
//    [view addSubview:label];
//    if (section == 0) {
//        [label setText:@"Get Points"];
//    }else{
//        [label setText:@"Rewards"];
//    }
//    
//    return view;
//}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuOne count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menu"];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menu"];
    }
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f]];
    cell.textLabel.text = [menuOne objectAtIndex:indexPath.row];

    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
