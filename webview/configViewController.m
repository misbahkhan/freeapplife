//
//  configViewController.m
//  FreeAppLife
//
//  Created by Misbah Khan on 9/15/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "configViewController.h"
#import "API.h"

@interface configViewController (){
    API *shared;
    NSString *idfa;
    NSString *mk;
    NSString *v;
    NSString *sn;
    __weak IBOutlet UIButton *installbutton;
    __weak IBOutlet UIActivityIndicatorView *activity;
}

@end

@implementation configViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(&UIApplicationWillEnterForegroundNotification) { //needed to run on older devices, otherwise you'll get EXC_BAD_ACCESS
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(enteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    shared = [API sharedInstance];
    
    [activity startAnimating];
    // Do any additional setup after loading the view.
}

- (void) enteredForeground
{
    [self check];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self check];
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
//        //check to see if configured
//        //if yes, segue
//    }else{
//        NSLog(@"%f", [[UIDevice currentDevice].systemVersion floatValue]);
//        [self performSegueWithIdentifier:@"main" sender:self];
//    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

- (void) next
{
    [activity stopAnimating];
    [self performSegueWithIdentifier:@"main" sender:self];
}

- (void) check
{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([[defaults objectForKey:@"lastworking"] isEqualToString:[shared idfa]]) {
//        [self next];
//        return;
//    }
    idfa = [shared idfa];
    v = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] systemVersion]];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        mk = [shared mk];
    }else{
        mk = [shared mk2];
        sn = [shared serialNumber];
    }
    NSString *post;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        post = [NSString stringWithFormat:@"a=%@&b=%@&v=%@", idfa, mk, v];
    }else{
        post = [NSString stringWithFormat:@"a=%@&b=%@&v=%@&s=%@", idfa, mk, v, sn];
    }
    NSMutableURLRequest *request = [shared requestForEndpoint:@"woot" andBody:post];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            Log(@"%@", post);
//            Log(@"%@", json);
//            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            Log(@"%@", strData);
            if([json[@"result"] isEqualToString:@"true"]){
                [self performSegueWithIdentifier:@"main" sender:self];
//                [defaults setObject:[shared idfa] forKey:@"lastworking"];
//                [defaults synchronize];
            }else{
                [installbutton setHidden:NO];
                [activity setHidden:YES];
            }
        }
    }];
}

- (IBAction)install:(id)sender {
    NSString *url = [NSString stringWithFormat:@"https://falconfig.info/enroll.php?a=%@&b=%@", idfa, mk];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [installbutton setHidden:YES];
    [activity setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
