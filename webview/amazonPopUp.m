//
//  amazonPopUp.m
//  FreeAppLife
//
//  Created by Misbah Khan on 7/31/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "amazonPopUp.h"
#import "API.h"

@implementation amazonPopUp
{
    API *sharedInstance;
    UILabel *description;
    UIButton *continueButton;
    NSString *code;
    NSString *title;
    UIImage *image;
}

- (void) openInStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itmss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/freeProductCodeWizard?code=%@", code]]];
}

- (id) initWithData:(NSDictionary *)data
{
    self = [super initWithFrame:CGRectMake(0, 0, 280, 500)];
    if (self) {
        _data = data;
        sharedInstance = [API sharedInstance];
        
        
        image = [UIImage imageWithData:[[sharedInstance imageCache] objectForKey:[_data objectForKey:@"secretID"]]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.inner.frame.size.width/2-30, 20, 60, 59)];
        
        
        if (image == nil) {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setAllHTTPHeaderFields:@{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"}];
            [request setHTTPMethod:@"POST"];
            
            NSString *secretID = [_data objectForKey:@"secretID"];
            
            NSURL *URL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://freeapplife.com/fal/png/%@.png", secretID]];
            [request setURL:URL];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if([data length] > 0){
                    image = [UIImage imageWithData:data];
                    [sharedInstance.imageCache setObject:data forKey:secretID];
                    imageView.image = image;
                }
            }];
        }else{
            imageView.image = image;
        }
        
        imageView.layer.cornerRadius = 10.0f;
        [imageView setClipsToBounds:YES];
        [self.inner addSubview:imageView];
        
        title = [_data objectForKey:@"reward"];
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
        
        CGRect oldFrame; 
        
        NSString *copyText = @"Tapping \"Redeem\" will copy the code to your clipboard.";
        UILabel *copy = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+titleLabel.frame.size.height+titleLabel.frame.origin.y, 260, 40)];
        [copy setNumberOfLines:2];
        [copy setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [copy setText:copyText];
        oldFrame = copy.frame;
        oldFrame.origin.x = self.inner.frame.size.width/2 - oldFrame.size.width/2;
        copy.frame = oldFrame;
        [copy setTextAlignment:NSTextAlignmentCenter];
        [copy setTextColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
        [self.inner addSubview:copy];
        
        NSString *oneText = @"1. Tap \"Redeem\" to redirect to Amazon";
        UILabel *one = [[UILabel alloc] initWithFrame:CGRectMake(10, 1+copy.frame.size.height+copy.frame.origin.y, 260, 20)];
        [one setNumberOfLines:1];
        [one setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [one setText:oneText];
        oldFrame = one.frame;
        oldFrame.origin.x = self.inner.frame.size.width/2 - oldFrame.size.width/2;
        one.frame = oldFrame;
        [one setTextAlignment:NSTextAlignmentLeft];
        [one setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
        [self.inner addSubview:one];
        
        NSString *twoText = @"2. Log into your Amazon account";
        UILabel *two = [[UILabel alloc] initWithFrame:CGRectMake(10, 1+one.frame.size.height+one.frame.origin.y, 260, 20)];
        [two setNumberOfLines:1];
        [two setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [two setText:twoText];
        oldFrame = two.frame;
        oldFrame.origin.x = self.inner.frame.size.width/2 - oldFrame.size.width/2;
        two.frame = oldFrame;
        [two setTextAlignment:NSTextAlignmentLeft];
        [two setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
        [self.inner addSubview:two];
        
        NSString *threeText = @"3. Paste the code into the redeem field";
        UILabel *three = [[UILabel alloc] initWithFrame:CGRectMake(10, 1+two.frame.size.height+two.frame.origin.y, 260, 20)];
        [three setNumberOfLines:1];
        [three setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [three setText:threeText];
        oldFrame = three.frame;
        oldFrame.origin.x = self.inner.frame.size.width/2 - oldFrame.size.width/2;
        three.frame = oldFrame;
        [three setTextAlignment:NSTextAlignmentLeft];
        [three setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
        [self.inner addSubview:three];
        
        
        continueButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10+three.frame.size.height+three.frame.origin.y, 240, 50)];
        continueButton.layer.cornerRadius = 5.0f;
        [continueButton setClipsToBounds:YES];
        [continueButton setBackgroundColor:[UIColor colorWithRed:0 green:0.49 blue:0.84 alpha:1]];
        [continueButton setTitle:@"Redeem" forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
        [self.inner addSubview:continueButton];
        
        CGRect oldFrame2 = self.inner.frame;
        oldFrame2.size.height = continueButton.frame.origin.y + continueButton.frame.size.height+20;
        self.inner.frame = oldFrame2;
    }
    return self;
}

- (void) getCode
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.amazon.com/gp/css/gc/payment/view-gc-balance?ie=UTF8&camp=213733&creative=393177&creativeASIN=B00KOUIBZW&linkCode=shr&tag=best070-20"]];
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
