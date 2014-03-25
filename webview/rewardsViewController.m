//
//  rewardsViewController.m
//  webview
//
//  Created by Adrian D'Urso on 1/18/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "rewardsViewController.h"
#import "rewardCell.h"
#import "popup.h"
#import <mach/port.h>
#import <mach/kern_return.h>
#import <CommonCrypto/CommonHMAC.h>
#import "API.h"
#import "CustomIOS7AlertView.h"

@interface rewardsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *rewardData, *categories, *images, *imageLinks, *rewards, *tables, *names;
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
    NSLog(@"disappeared");
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://freeapplife.com/api/rewardCategories"]];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            [categories addObjectsFromArray:dataArray];

            [_segmentedControl removeAllSegments];
            
            for(int i = 0; i<[categories count]; i++){
                [_segmentedControl insertSegmentWithTitle:[[categories objectAtIndex:i] objectForKey:@"Name"] atIndex:i animated:NO];
                [rewards addObject:[[NSMutableArray alloc] init]];
                [images addObject:[[NSMutableArray alloc] init]];
                [imageLinks addObject:[[NSMutableArray alloc] init]];
                [names addObject:[[categories objectAtIndex:i] objectForKey:@"Name"]];
                UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 128, 320, 440)];
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
            UILabel *warning = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 320, 28)];
            [warning setText:@"Rewards are currently US-exclusive."];
            [warning setTextAlignment:NSTextAlignmentCenter];
            [self.view addSubview:warning];
            [_segmentedControl setSelectedSegmentIndex:0];
            _segmentedControl.hidden = NO;
            [self categorySelect:self]; 
        }
    }];

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0f;
}

- (void)getReward:(NSString *)forCategory
{
    isRefreshing = YES;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://freeapplife.com/api/rewardsForCategory?category=%@", forCategory]]];
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
            [self getImages:place];
        }
    }];
}

- (void) getImages:(int)forTable{
    [[imageLinks objectAtIndex:forTable] removeAllObjects];
    if([rewards count]>0){
        for(int i = 0; i<[[rewards objectAtIndex:forTable] count]; i++){
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://freeapplife.com/fal/png/%@.png",[[[rewards objectAtIndex:forTable] objectAtIndex:i] objectForKey:@"SecretID"]]];
            [[imageLinks objectAtIndex:forTable] addObject:imageURL];
        }
        [self getImageLinks:0 table:forTable];
    }
}

- (void) getImageLinks:(int)number table:(int)forTable{
    if([[images objectAtIndex:forTable] count]<[[imageLinks objectAtIndex:forTable] count]){
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[imageLinks objectAtIndex:forTable] objectAtIndex:number]];
        [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
        [request setHTTPMethod:@"POST"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if([data length] > 0){
                UIImage *image = [UIImage imageWithData:data];
                if(image){
                    [[images objectAtIndex:forTable] addObject:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UITableView *toLoad = (UITableView *)[self.view viewWithTag:forTable+10];
                        if(number<[[imageLinks objectAtIndex:forTable] count]){
                            [toLoad reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:number inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        }
                        if(number<[[imageLinks objectAtIndex:forTable] count]-1){
                            [self getImageLinks:number+1 table:forTable];
                            [refreshControl endRefreshing];
                        }else{

                        }
                    });
                }else{
                    NSLog(@"NO IMAGE");
                }
            }
        }];
    }else{
//        UITableView *toLoad = (UITableView *)[self.view viewWithTag:forTable+10];
//        [toLoad reloadData];
    }
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

- (NSArray *) makeForData:(NSString *)data
{
    NSData *ipD = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://freeapplife.com/beta/ip"]];
    NSString *ip = [[NSString alloc] initWithData:ipD encoding:NSUTF8StringEncoding];
    ip = [ip stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *origSN = [sharedInstance serialNumber];
    NSDate *date = [NSDate date];
    NSString *epoch = [NSString stringWithFormat:@"%lli", [@(floor([date timeIntervalSince1970])) longLongValue]];
    NSString *final = [ip stringByAppendingString:origSN];
    final = [final stringByAppendingString:epoch];
    final = [self sha1:final];
    
    NSData* secretData = [final dataUsingEncoding:NSUTF8StringEncoding];
    NSData* stringData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *signatureData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, stringData.bytes, stringData.length, signatureData.mutableBytes);
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    NSString *someString = [[signatureData description] stringByTrimmingCharactersInSet:charsToRemove];
    someString = [someString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"origSN: %@", origSN);
//    NSLog(@"epoch: %@", epoch);
//    NSLog(@"signatureData %@", someString);
    return @[someString, epoch];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
    return view;
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
        cell.label.text = [NSString stringWithFormat:@"%@\n%@ points",[currentData objectForKey:@"Reward"], [currentData objectForKey:@"Points"]];
//        cell.points.text = [NSString stringWithFormat:@"%@ points", [currentData objectForKey:@"Points"]];
        cell.image.image = nil;
        if([[images objectAtIndex:tag] count] > indexPath.row){
            cell.image.image = [[images objectAtIndex:tag] objectAtIndex:indexPath.row];
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
//    int tag = [[self.view.subviews objectAtIndex:[self.view.subviews indexOfObject:tableView]] tag];
        rewardCell *cell = (rewardCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSString *title = [cell.data objectForKey:@"Reward"];
        NSString *description = [cell.data objectForKey:@"Description"];
        NSString *rewardID = [cell.data objectForKey:@"SecretID"];
        NSString *points = [cell.data objectForKey:@"Points"];
    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://freeapplife.com/api/rewardstock?rewardID=%@", rewardID]]];
        
        [request setHTTPMethod:@"POST"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if([data length] > 0){
                NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

                NSLog(@"%@", dataArray);
                
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 59)];
                    imageView.image = cell.image.image;
                    imageView.layer.cornerRadius = 10.0f;
                    [imageView setClipsToBounds:YES];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 20, 160, 20)];
                    [titleLabel setText:title];
                    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
                    [titleLabel setNumberOfLines:1];
                    //    [titleLabel sizeToFit];
                    CGRect titleFrame = titleLabel.frame;
                    titleLabel.frame = titleFrame;
                
                
                    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 150)];
                    [cellView setBackgroundColor:[UIColor clearColor]];
                    [cellView addSubview:imageView];
                    code = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 240, 50)];
                    [code setNumberOfLines:2];
                
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 190, 120)];
                    label.text = [NSString stringWithFormat:@"%@\n%@ points", description, points];
                    [label setNumberOfLines:2];
                    [label sizeToFit];
                
                    [cellView addSubview:label];
                    [cellView addSubview:code];
                    [cellView addSubview:titleLabel];
                
                    int stock = [[json objectForKey:@"stock"] intValue];
                    
//                    CXAlertView *alert = [[CXAlertView alloc] initWithTitle:title contentView:cellView cancelButtonTitle:@"Cancel"];
                    CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
                    [alert setDelegate:self];
                    [alert setContainerView:cellView];
                
                    if(stock > 0){
                        [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Claim Reward", nil]];
                        [alert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
                            if(buttonIndex == 1){
                                UIButton *button = (UIButton *)[[[[alertView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
                                if([button.titleLabel.text isEqualToString:@"Okay"]){
                                    [alertView close];
                                }
                                if(![button.titleLabel.text isEqualToString:@"Open in App Store"]){
                                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://freeapplife.com/api/redeem"]];
                                     [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
                                     [request setHTTPMethod:@"POST"];
                                     NSString *postString = [NSString stringWithFormat:@"userID=%@&rewardID=%@", [sharedInstance serialNumber], rewardID];
                                     [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                                     [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

                                         // This will Fetch the status code from NSHTTPURLResponse object
                                         int responseStatusCode = [httpResponse statusCode];

                                         //Just to make sure, it works or not
                                         NSLog(@"Status Code :: %d", responseStatusCode);
                                         if([data length] > 0){
                                             NSError* error;
                                             NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                             //NSLog(@"%@", response);
                                             NSLog(@"redeem: %@", json);
                                             if(responseStatusCode == 200 && [[_segmentedControl titleForSegmentAtIndex:[_segmentedControl selectedSegmentIndex]] isEqualToString:@"Apps"]){
                                                 actualCode = [json objectForKey:@"code"];
                                                 [code setText:[NSString stringWithFormat:@"Code: %@", [json objectForKey:@"code"]]];
                                                 UIButton *button = (UIButton *)[[[[alertView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
                                                 if(![button.titleLabel.text isEqualToString:@"Open in App Store"]){
                                                     [button setTitle:@"Open in App Store" forState:UIControlStateNormal];
                                                 }
                                             }
                                             if(responseStatusCode == 200 && [[_segmentedControl titleForSegmentAtIndex:[_segmentedControl selectedSegmentIndex]] isEqualToString:@"Giftcards"]){
                                                 actualCode = [json objectForKey:@"code"];
                                                 [code setText:[NSString stringWithFormat:@"%@", [json objectForKey:@"code"]]];
                                                 UIButton *button = (UIButton *)[[[[alertView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
                                                 if(![button.titleLabel.text isEqualToString:@"Okay"]){
                                                     [button setTitle:@"Okay" forState:UIControlStateNormal];
                                                 }
                                             }
                                             if(responseStatusCode == 400){
                                                 [code setText:[json objectForKey:@"issue"]];
                                                 [code setTextAlignment:NSTextAlignmentCenter];
                                             }
                                             [sharedInstance user];
                                         }
                                     }];
                                }else{
                                    NSLog(@"actualCode: %@", actualCode);
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itmss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/freeProductCodeWizard?code=%@", actualCode]]];
                                }
                            }else{
                           
                            }
                         }];
//                        [alert addButtoanWithTitle:@"Claim Reward" type:CXAlertViewButtonTypeCustom handler:
//                         ^(CXAlertView *alertView, CXAlertButtonItem *button) {
//                             NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://freeapplife.com/api/redeem"]];
//                             [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
//                             [request setHTTPMethod:@"POST"];
//                             NSString *postString = [NSString stringWithFormat:@"userID=%@&rewardID=%@", [sharedInstance serialNumber], rewardID];
//                             [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
//                             [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                                 NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//                                 
//                                 // This will Fetch the status code from NSHTTPURLResponse object
//                                 int responseStatusCode = [httpResponse statusCode];
//                                 
//                                 //Just to make sure, it works or not
//                                 NSLog(@"Status Code :: %d", responseStatusCode);
//                                 if([data length] > 0){
//                                     NSError* error;
//                                     NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                                     //NSLog(@"%@", response);
//                                     NSLog(@"redeem: %@", json);
//                                     if(responseStatusCode == 200){
//                                         [code setText:[NSString stringWithFormat:@"Code: %@", [json objectForKey:@"code"]]];
//                                         [code sizeToFit];
//                                     }
//                                     if(responseStatusCode == 400){
//                                         [code setText:[json objectForKey:@"issue"]];
//                                     }
//                                     [sharedInstance user];
//                                 }
//                             }];
//                         }
//                         ];
//                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 190, 120)];
//                        label.text = [NSString stringWithFormat:@"%@\n%@ points", description, points];
//                        [label setNumberOfLines:2];
//                        [label sizeToFit];
//                        [cellView addSubview:label];
                    }else{
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 190, 120)];
                        label.text = @"Out of stock.";
                        [label sizeToFit];
                        [cellView addSubview:label];
                        [alert setContainerView:cellView];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [alert show];
                    });
            }
        }];
    
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
