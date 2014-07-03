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
    
    menuOne = [[NSArray alloc] initWithObjects:@"App Offers", @"Video Offers", @"Pending Offers", @"Double Down Offers", nil];
    menuTwo = [[NSArray alloc] initWithObjects:@"App Offers", @"Video Offers", @"Gone Free", @"Electronics Rewards", nil];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 234, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 204, 50)];
    [view addSubview:label];
    if (section == 1) {
        [label setText:@"Offers"];
    }else{
        [label setText:@"Rewards"];
    }
    
    return view;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [menuOne count];
    }
    return [menuTwo count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menu"];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menu"];
    }
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    if (indexPath.section == 1) {
        cell.textLabel.text = [menuOne objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = [menuTwo objectAtIndex:indexPath.row];
    }

    
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
