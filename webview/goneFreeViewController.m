//
//  goneFreeViewController.m
//  FreeAppLife
//
//  Created by Misbah Khan on 7/11/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "goneFreeViewController.h"
#import "API.h"
#import "rewardCell.h"
#import <Parse/Parse.h>

@interface goneFreeViewController ()
{
    NSMutableArray *goneFreeList;
    API *sharedInstance;
    UIRefreshControl *refreshControl;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
    UIButton *featured;
    UIView *topBar;
    UIButton *refresh;
    IBOutlet UIView *topView;
    IBOutlet UISwitch *notif_toggle;
    IBOutlet UILabel *updates;
    BOOL hidden;
}

@end

@implementation goneFreeViewController

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
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(goneFreeList) forControlEvents:UIControlEventAllEvents];
    [_goneFreeTable addSubview:refreshControl];
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    topBar = [sharedInstance getBar];
    [self.view addSubview:topBar];
    
    _pointsLabel = [sharedInstance getPoints];
    [self.view addSubview:_pointsLabel];
    
    refresh = [[UIButton alloc]initWithFrame:CGRectMake(5, 23, 34, 19)];
    [refresh setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [refresh addTarget:sharedInstance action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:[sharedInstance notificationName] object:nil];
    
    [_goneFreeTable setDelegate:self];
    
    [_goneFreeTable registerClass:[rewardCell class] forCellReuseIdentifier:@"goneFreeCell"];
    
    [self featuredImage];
    [self goneFreeList]; 
}

- (void) viewDidAppear:(BOOL)animated
{
    hidden = NO;
    NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
    if([subscribedChannels containsObject:@"GoneFree"]){
        hidden = YES;
        [notif_toggle setHidden:YES];
        [updates setHidden:YES];
        [_goneFreeTable setContentInset:UIEdgeInsetsMake(100, 0, 44, 0)];
        [_goneFreeTable setScrollIndicatorInsets:UIEdgeInsetsMake(100, 0, 44, 0)];
        CGRect oldFrame = topView.frame;
        oldFrame.size.height = 100;
        [topView setFrame:oldFrame];
        [notif_toggle setOn:YES];
    }else{
        hidden = NO;
        [notif_toggle setHidden:NO];
        [updates setHidden:NO];
        [_goneFreeTable setContentInset:UIEdgeInsetsMake(150, 0, 44, 0)];
        [_goneFreeTable setScrollIndicatorInsets:UIEdgeInsetsMake(150, 0, 44, 0)];
        CGRect oldFrame = topView.frame;
        oldFrame.size.height = 150;
        [topView setFrame:oldFrame];
        [notif_toggle setOn:NO];
    }
}

- (void) dataUpdated:(id)sender
{
    _pointsLabel.text = [sharedInstance currentPoints];
}

- (IBAction)switched:(id)sender {
    if(notif_toggle.on){
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:@"GoneFree" forKey:@"channels"];
        [currentInstallation saveInBackground];
    }else{
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObject:@"GoneFree" forKey:@"channels"];
        [currentInstallation saveInBackground];
    }
}

- (void) goneFreeList {
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"goneFreeList" andBody:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int responseStatusCode = (int)[httpResponse statusCode];
            if(responseStatusCode == 200){
                goneFreeList = [[dataDictionary objectForKey:@"goneFree"] mutableCopy];
//                NSLog(@"%@", goneFreeList); 
                [self getImages];
                [_goneFreeTable reloadData];
                [refreshControl endRefreshing];
            }else{
                //                refreshing = FALSE;
            }
        }
    }];
}

- (void) featuredImage
{
    featured = [[UIButton alloc] initWithFrame:CGRectMake((topView.frame.size.width/2)-140, 5 , 280, 100)];
    [topView addSubview:featured];
    
    [self.view bringSubviewToFront:topBar];
    [self.view bringSubviewToFront:_pointsLabel];
    [self.view bringSubviewToFront:refresh];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://freeapplife.com/fal/png/free_featured.png"]];
    [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            UIImage *image = [UIImage imageWithData:data];
            [featured setBackgroundImage:image forState:UIControlStateNormal];
            [featured addTarget:self action:@selector(changeTab) forControlEvents:UIControlEventTouchUpInside];
            [featured setContentMode:UIViewContentModeScaleAspectFit];
            featured.layer.cornerRadius = 5.0f;
            [featured setClipsToBounds:YES];
        }
    }];
}

- (void) changeTab{
    if([[[sharedInstance userData] objectForKey:@"goneFreeLink"] length] > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[sharedInstance userData] objectForKey:@"goneFreeLink"]]];
    }else{
        int tab = [[[sharedInstance userData] objectForKey:@"goneFreeTab"] intValue];
        [self.tabBarController setSelectedIndex:tab];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if(![deviceType isEqualToString:@"iPad"]){
        float off = scrollView.contentOffset.y;
        
        CGRect oldFrame = topView.frame;
        int constant = -150;
        if (hidden) {
            constant = -100;
        }
        if(off < 1 && off > constant){
            oldFrame.origin.y = 44 - (abs(constant) + (int)off);
            topView.frame = oldFrame;
        }else if(off > 1){
            oldFrame.origin.y = constant;
            topView.frame = oldFrame;
        }else if(off < constant+1){
            oldFrame.origin.y = 44;
            topView.frame = oldFrame;
        }
    }
}

- (void) getImages {
    for (int i = 0; i < [goneFreeList count]; i++) {
        NSString *URL = [[goneFreeList objectAtIndex:i] objectForKey:@"icon"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
        request.URL = [NSURL URLWithString:URL];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if([data length] > 0){
                                       [sharedInstance.imageCache setObject:data forKey:URL];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [_goneFreeTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                       });
                                   }else{
                                       //NSLog(@"NO DATA");
                                   }
                               }];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [goneFreeList count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0f; 
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    rewardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goneFreeCell"];
    
    if (cell == nil) {
        cell = [[rewardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"goneFreeCell"];
    }
    
    NSDictionary *currentFree = [goneFreeList objectAtIndex:indexPath.row];
    
    cell.label.text = [currentFree objectForKey:@"title"];
    
    cell.image.image = nil;
    
    if([[sharedInstance imageCache] objectForKey:[currentFree objectForKey:@"icon"]] > 0){
        cell.image.image = [UIImage imageWithData:[[sharedInstance imageCache] objectForKey:[currentFree objectForKey:@"icon"]]];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = [[goneFreeList objectAtIndex:indexPath.row] objectForKey:@"url"];
//    NSLog(@"%@", url);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    });
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
