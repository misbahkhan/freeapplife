//
//  rewardsViewController.m
//  webview
//
//  Created by Adrian D'Urso on 1/18/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "rewardsViewController.h"
#import "rewardCell.h"
#import <mach/port.h>
#import <mach/kern_return.h>
#import <CommonCrypto/CommonHMAC.h>
#import "API.h"
#import "CustomIOS7AlertView.h"
#import "rewardPopUp.h"

@interface rewardsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *rewardData, *categories, *images, *imageLinks, *rewards, *tables, *names, *ids;
    UITableView *currentTable, *loadingTable;
    UIRefreshControl *refreshControl;
    NSUInteger current, loading, nowLoading;
    NSUserDefaults *defaults;
    BOOL isRefreshing;
    int opened;
    UITextField *referralBox;
    UILabel *code;
    NSString *actualCode;
    API *sharedInstance;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@end

@implementation rewardsViewController

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
    sharedInstance = [API sharedInstance];
    rewardData = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] init];
    imageLinks = [[NSMutableArray alloc] init];
    categories = [[NSMutableArray alloc] init];
    rewards = [[NSMutableArray alloc] init];
    tables = [[NSMutableArray alloc] init];
    names = [[NSMutableArray alloc] init];
    [self getCategories];
    [_segmentedControl addTarget:self action:@selector(categorySelect:) forControlEvents:UIControlEventValueChanged];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(categorySelect:) forControlEvents:UIControlEventValueChanged];
//    [_tableView addSubview:refreshControl];
//    NSLog(@"%@", [self serialNumber]);
	// Do any additional setup after loading the view.
    defaults = [[NSUserDefaults alloc] init];
    
//    opened = 0;
    
    UIView *topBar = [sharedInstance getBar];
    [self.view addSubview:topBar];
    
    _pointsLabel = [sharedInstance getPoints];
    [self.view addSubview:_pointsLabel];

    UIButton *refresh = [[UIButton alloc]initWithFrame:CGRectMake(5, 23, 34, 19)];
    [refresh setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [refresh addTarget:sharedInstance action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:[sharedInstance notificationName] object:nil];
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;

    UIButton *warning = [[UIButton alloc] initWithFrame:CGRectMake(0, 90, screenWidth, 28)];
    [warning setTitle:@"Rewards are currently US-exclusive. Tap for more." forState:UIControlStateNormal];
    [warning.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:13.0f]];
    [warning setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [warning addTarget:self action:@selector(usOnlyPopup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:warning];
    
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [sharedInstance refer:[referralBox text]];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [sharedInstance user];
}

- (void) viewDidDisappear:(BOOL)animated
{
    //NSLog(@"disappeared");
}

- (void) dataUpdated:(id)sender
{
    _pointsLabel.text = [sharedInstance currentPoints];
}

- (void) categorySelect:(id)sender
{
    current = [_segmentedControl selectedSegmentIndex];
    [self getReward:[[categories objectAtIndex:current] objectForKey:@"Name"]];
    currentTable = (UITableView *)[self.view viewWithTag:10+current];
    currentTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    currentTable.separatorColor = [UIColor lightGrayColor];
    [self.view bringSubviewToFront:[self.view viewWithTag:10+current]];
    [refreshControl removeFromSuperview]; 
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [currentTable addSubview:refreshControl];
}

- (void) refresh:(id)sender
{
    current = [_segmentedControl selectedSegmentIndex];
    [self getReward:[[categories objectAtIndex:current] objectForKey:@"Name"]];
    currentTable = (UITableView *)[self.view viewWithTag:10+current];
    [self.view bringSubviewToFront:[self.view viewWithTag:10+current]];
    [currentTable reloadData]; 
    [refreshControl endRefreshing];
}

- (void) getCategories
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://freeapplife.com/api/rewardCategories"]];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            [categories addObjectsFromArray:dataArray];

            [_segmentedControl removeAllSegments];
            for(int i = 0; i<[categories count]; i++){
                [_segmentedControl insertSegmentWithTitle:[[categories objectAtIndex:i] objectForKey:@"Name"] atIndex:i animated:NO];
                [rewards addObject:[[NSMutableArray alloc] init]];
                [images addObject:[[NSMutableDictionary alloc] init]];
                [imageLinks addObject:[[NSMutableArray alloc] init]];
                [names addObject:[[categories objectAtIndex:i] objectForKey:@"Name"]];
                int heightSubtractor = 126;
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                    heightSubtractor = 146;
                }
                UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 128, screenWidth, screenHeight-heightSubtractor)];
                table.tag = 10+i;
                [self.view addSubview:table];
                table.delegate = self;
                table.dataSource = self;
                [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                [table setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
                [table setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 50, 0)];
                [table registerClass:[rewardCell class] forCellReuseIdentifier:@"rewardCell"];
                [tables addObject:table];
            }
            [_segmentedControl setSelectedSegmentIndex:0];
            _segmentedControl.hidden = NO;
            [self categorySelect:self]; 
        }
    }];
}

- (void) usOnlyPopup
{
    UIAlertView *usOnly = [[UIAlertView alloc] initWithTitle:@"Rewards" message:@"Temporarily changing your iTunes account region to the US will allow you to redeem app rewards." delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles: nil];
    [usOnly show]; 
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0f;
}

- (void)getReward:(NSString *)forCategory
{
    isRefreshing = YES;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://freeapplife.com/api/rewardsForCategory?category=%@", forCategory]]];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            int place = [names indexOfObject:forCategory];
            loading = place;
            nowLoading = place;
            [[rewards objectAtIndex:place] removeAllObjects];
            [[rewards objectAtIndex:place] addObjectsFromArray:dataArray];
            loadingTable = (UITableView *)[self.view viewWithTag:10+place];
            [loadingTable reloadData];
            [self getNewImages:place];
        }
    }];
}


- (void) getNewImages:(int)forTable{
    [[imageLinks objectAtIndex:forTable] removeAllObjects];
    if([rewards count]>0){
        for(int i = 0; i<[[rewards objectAtIndex:forTable] count]; i++){
            [[imageLinks objectAtIndex:forTable] addObject:[[[rewards objectAtIndex:forTable] objectAtIndex:i] objectForKey:@"SecretID"]];
        }
        [self getNewImageLinks:forTable];
    }
}

- (void) getNewImageLinks:(int)forTable{
    UITableView *toLoad = (UITableView *)[self.view viewWithTag:forTable+10];
    
    for(int i = 0; i<[[imageLinks objectAtIndex:forTable] count]; i++){
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
        [request setHTTPMethod:@"POST"];
        
        NSString *secretID = [[[rewards objectAtIndex:forTable] objectAtIndex:i] objectForKey:@"SecretID"];
        
        if(!([[images objectAtIndex:forTable] objectForKey:secretID] > 0)){
            NSURL *URL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://freeapplife.com/fal/png/%@.png", secretID]];
            [request setURL:URL];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if([data length] > 0){
                    UIImage *image = [UIImage imageWithData:data];
                    [sharedInstance.imageCache setObject:data forKey:secretID]; 
                    if(image){
                        [[images objectAtIndex:forTable] setObject:image forKey:secretID];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [toLoad reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        });
                    }else{
                        //NSLog(@"NO IMAGE");
                    }
                }
            }];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    rewardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rewardCell" forIndexPath:indexPath];
    int tag = [[self.view.subviews objectAtIndex:[self.view.subviews indexOfObject:tableView]] tag];
    tag-=10;
    cell.image.image = nil;
    if([[rewards objectAtIndex:tag] count]){
        NSDictionary *currentData = [[rewards objectAtIndex:tag] objectAtIndex:indexPath.row];
        cell.data = currentData;
        cell.label.text = [currentData objectForKey:@"Reward"];
        cell.points.text = [NSString stringWithFormat:@"- %@", [currentData objectForKey:@"Points"]];
        [cell.points sizeToFit];
        CGRect oldFrame = cell.points.frame;
        oldFrame.size.width = oldFrame.size.width+20;
        oldFrame.size.height = oldFrame.size.height+10;
        oldFrame.origin.x = 280-oldFrame.size.width;
        oldFrame.origin.x += 20;
        oldFrame.origin.y = 21+((59-oldFrame.size.height)/2);
        
        if(screenWidth > 320){
            oldFrame.origin.x = screenWidth-75;
        }
        
        cell.points.frame = oldFrame;

        
        if(screenWidth > 320){
            CGRect oldFrame = cell.label.frame;
            cell.label.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width + 300, oldFrame.size.height);
        }
        
//        cell.points.text = [NSString stringWithFormat:@"%@ points", [currentData objectForKey:@"Points"]];
        cell.image.image = nil;
        if([[images objectAtIndex:tag] objectForKey:[currentData objectForKey:@"SecretID"]] > 0){
            cell.image.image = [[images objectAtIndex:tag] objectForKey:[currentData objectForKey:@"SecretID"]];
        }
    }
    return cell;
}

-(void) copy:(id)sender text:(NSString *)text
{
    NSString *copyStringverse = text;
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyStringverse];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [alertView close];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    rewardCell *cell = (rewardCell *)[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    rewardPopUp *rewardView = [[rewardPopUp alloc] initWithData:cell.data];
    [rewardView show];    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = [[self.view.subviews objectAtIndex:[self.view.subviews indexOfObject:tableView]] tag];
    if([rewards count]>tag-10){
        return [[rewards objectAtIndex:tag-10]count];
    }else{
        return 0;
    }
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
