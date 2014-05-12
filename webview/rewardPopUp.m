//
//  rewardPopUp.m
//  FreeAppLife
//
//  Created by Misbah Khan on 5/10/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "rewardPopUp.h"
#import "API.h"

@implementation rewardPopUp
{
    API *sharedInstance;
    UILabel *description;
    UIActivityIndicatorView *activity;
    UIButton *continueButton;
    NSString *code;
}

- (void) getCode
{
    [continueButton setUserInteractionEnabled:NO];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://freeapplife.com/api/redeem"]];
    [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"userID=%@&rewardID=%@", [sharedInstance serialNumber], [_data objectForKey:@"SecretID"]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        int responseStatusCode = [httpResponse statusCode];
        if([data length] > 0){
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            [continueButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [description setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
            if(responseStatusCode == 400){
                [description setText:[json objectForKey:@"issue"]];
                [description setTextAlignment:NSTextAlignmentCenter];
                [description sizeToFit];
                [continueButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
                [continueButton setTitle:@"Okay" forState:UIControlStateNormal];
            }else if(responseStatusCode == 200){
                code = [json objectForKey:@"code"];
                [description setText:[NSString stringWithFormat:@"%@", [json objectForKey:@"code"]]];
                if([[_data objectForKey:@"Category"] isEqualToString:@"Apps"]){
                    [continueButton addTarget:self action:@selector(openInStore) forControlEvents:UIControlEventTouchUpInside];
                    [continueButton setTitle:@"Open in App Store" forState:UIControlStateNormal];
                }else{
                    [continueButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
                    [continueButton setTitle:@"Okay" forState:UIControlStateNormal];
                }
            }else{
                [description setText:@"Something went wrong, try again later."];
                [continueButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
                [continueButton setTitle:@"Okay" forState:UIControlStateNormal];
            }
            
            [continueButton setUserInteractionEnabled:YES];
            [sharedInstance user];
            
            //            NSString *titleForTweet;
            //            if ([title length] > 15) {
            //                titleForTweet = [NSString stringWithFormat:@"%@...", [title substringToIndex:15]];
            //            }else{
            //                titleForTweet = title;
            //            }
            //            NSString *tweet = [NSString stringWithFormat:@"I just redeemed %@ for Free using @FreeAppLife. Join now to earn Paid Apps and Gift Cards for Free! http://freeapplife.com", titleForTweet];
            //            [sharedInstance tweet:tweet];
        }
    }];
    
}

- (void) openInStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itmss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/freeProductCodeWizard?code=%@", code]]];
}

- (void) checkStock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://freeapplife.com/api/rewardstock?rewardID=%@", [_data objectForKey:@"SecretID"]]]];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [activity stopAnimating];
        if([data length] > 0){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if([[json objectForKey:@"stock"] intValue] > 0){
                [self.inner addSubview:continueButton];
            }else{
                UILabel *outOfStock = [[UILabel alloc] initWithFrame:CGRectMake(20, activity.frame.origin.y, 240, 50)];
                [outOfStock setText:@"Sorry, reward is currently out of stock. :("];
                [outOfStock setFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f]];
                [outOfStock setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                [self.inner addSubview:outOfStock];
            }
        }
    }];
}

- (id) initWithData:(NSDictionary *)data
{
    self = [super initWithFrame:CGRectMake(0, 0, 280, 500)];
    if (self) {
        _data = data;
        sharedInstance = [API sharedInstance];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.inner.frame.size.width/2-30, 20, 60, 59)];
        imageView.image = [UIImage imageWithData:[[sharedInstance imageCache] objectForKey:[_data objectForKey:@"SecretID"]]];
        imageView.layer.cornerRadius = 10.0f;
        [imageView setClipsToBounds:YES];
        [self.inner addSubview:imageView];
        
        NSString *title = [_data objectForKey:@"Reward"];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+10, 260, 40)];
        [titleLabel setNumberOfLines:3];
        [titleLabel setText:title];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [titleLabel setTextColor:[UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1]];
        [titleLabel sizeToFit];
        CGRect titleFrame = titleLabel.frame;
        titleFrame.origin.x = self.inner.frame.size.width/2-titleFrame.size.width/2;
        titleLabel.frame = titleFrame;
        [self.inner addSubview:titleLabel];
        
        NSString *descriptionText = [_data objectForKey:@"Description"];
        description = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+titleLabel.frame.size.height+titleLabel.frame.origin.y, 260, 40)];
        [description setNumberOfLines:2];
        [description setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [description setText:descriptionText];
//        [description sizeToFit];
        CGRect oldFrame = description.frame;
        oldFrame.origin.x = self.inner.frame.size.width/2 - oldFrame.size.width/2;
        description.frame = oldFrame;
        [description setTextAlignment:NSTextAlignmentCenter];
        [description setTextColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
        [self.inner addSubview:description];
        
        activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.inner.frame.size.width/2 - 25, 10+description.frame.size.height+description.frame.origin.y, 50, 50)];
        [self.inner addSubview:activity];
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [activity startAnimating];
        
        continueButton = [[UIButton alloc] initWithFrame:CGRectMake(20, activity.frame.origin.y, 240, 50)];
        continueButton.layer.cornerRadius = 5.0f;
        [continueButton setClipsToBounds:YES];
        [continueButton setBackgroundColor:[UIColor colorWithRed:0 green:0.49 blue:0.84 alpha:1]];
        [continueButton setTitle:@"Claim Reward" forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect oldFrame2 = self.inner.frame;
        oldFrame2.size.height = activity.frame.origin.y + activity.frame.size.height+20;
        self.inner.frame = oldFrame2;
        [self checkStock];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
