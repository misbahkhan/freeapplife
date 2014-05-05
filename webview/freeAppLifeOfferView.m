//
//  freeAppLifeOfferView.m
//  FreeAppLife
//
//  Created by Misbah Khan on 5/5/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "freeAppLifeOfferView.h"
#import "API.h"

@implementation freeAppLifeOfferView

- (void) sponsorPayHelpClicked:(id)sender
{
    //NSLog(@"clicked %@", sponsorPayHelp);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_sharedInstance sponsorPayHelp]]];
}

- (void) pend
{
    NSString *title = [_offerData objectForKey:@"name"];
    NSString *userID = [_sharedInstance userID];
    NSDate *date = [NSDate date];
    NSString *rewardID = [_offerData objectForKey:@"id"];
    NSString *pointValue = [_offerData objectForKey:@"points"];
    NSString *guessTime = [_offerData objectForKey:@"estimate"];
    NSString *image = [_offerData objectForKey:@"image"];
    NSString *postString = [NSString stringWithFormat:@"rewardID=%@&userID=%@&name=%@&time=%lld&points=%@&guess=%@&image=%@", rewardID, userID, title, [@(floor([date timeIntervalSince1970])) longLongValue], pointValue, guessTime, image];
    NSMutableURLRequest *request = [_sharedInstance requestForEndpoint:@"pending" andBody:postString];
    NSError *error;
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
}

- (id) initWithData:(NSDictionary *)data
{
    self = [super initWithFrame:CGRectMake(0, 0, 280, 275)];
    if (self) {
        _offerData = data;
        _sharedInstance = [API sharedInstance];

        NSString *title = [_offerData objectForKey:@"name"];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 20, 160, 20)];
        [titleLabel setText:title];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [titleLabel setNumberOfLines:1];
        CGRect titleFrame = titleLabel.frame;
        titleLabel.frame = titleFrame;
        [self addSubview:titleLabel];

        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 59)];
        imageView.image = [UIImage imageWithData:[[_sharedInstance imageCache] objectForKey:[_offerData objectForKey:@"image"]]];
        imageView.layer.cornerRadius = 10.0f;
        [imageView setClipsToBounds:YES];
        [self addSubview:imageView];
        
        if([[_offerData objectForKey:@"vendor"] isEqualToString:@"spay"]){
            UIButton *helpLabel = [[UIButton alloc] initWithFrame:CGRectMake(20, titleFrame.size.height+180, 240, 20)];
            [helpLabel setTitle:@"Missing Points? Tap for Help!" forState:UIControlStateNormal];
            [helpLabel.titleLabel setFont: [UIFont fontWithName:@"Helvetica Neue" size:13.0f]];
            [helpLabel setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [helpLabel addTarget:self action:@selector(sponsorPayHelpClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:helpLabel];
        }
        
        UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(90, titleFrame.size.height+20, 190, 120)];
        [instructions setNumberOfLines:3];
        NSString *instruct;
        
        instruct = [_offerData objectForKey:@"description"];
        [instructions setNumberOfLines:6];
        [instructions setFont: [UIFont fontWithName:@"Helvetica Neue" size:11.0f]];
        
        instruct = [NSString stringWithFormat:@"Instructions: %@", instruct];
        [instructions setText:instruct];
        [instructions sizeToFit];
        [self addSubview:instructions];
        
        NSString *guide = @"Remember to open the app for a minimum of 30 seconds and do not switch networks (e.g. 3G, LTE > Wi-Fi). Some offers may take up to 24 hours to credit to your account.";
        
        UILabel *guidelines = [[UILabel alloc] initWithFrame:CGRectMake(20, titleFrame.size.height+100, 240, 120)];
        [guidelines setText:guide];
        [guidelines setNumberOfLines:5];
        [guidelines setFont: [UIFont fontWithName:@"Helvetica Neue" size:13.0f]];
        [guidelines setTextAlignment:NSTextAlignmentCenter];
        [guidelines sizeToFit];
        [self addSubview:guidelines];

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
