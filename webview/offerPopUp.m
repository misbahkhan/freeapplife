//
//  offerPopUp.m
//  FreeAppLife
//
//  Created by Misbah Khan on 5/10/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "offerPopUp.h"
#import "API.h"

@implementation offerPopUp
{
    API *sharedInstance;
    UIButton *continueButton;
    UILabel *titleLabel;
    UILabel *guidelines;
    UILabel *instructions;
    UIButton *helpLabel;
    UIImageView *imageView;
}

- (void) hide
{
    [_web stopLoading];
    [super hide];
}

- (void) pause
{
    self.main.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.main.layer.opacity = 0.0f;
					 }completion:^(BOOL finished) {}
	 ];
}

- (void) afterMessage
{
    [helpLabel removeFromSuperview];
    [guidelines removeFromSuperview];
    [_progress removeFromSuperview];
    [instructions removeFromSuperview];
    [titleLabel removeFromSuperview];
//    NSString *title = [NSString stringWithFormat:@"Thanks for installing %@", [_data objectForKey:@"name"]];
//    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+10, 260, 40)];
//    [titleLabel setNumberOfLines:3];
//    [titleLabel setText:title];
//    [titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
//    [titleLabel setTextColor:[UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1]];
//    [titleLabel sizeToFit];
//    CGRect titleFrame = titleLabel.frame;
//    titleFrame.origin.x = self.inner.frame.size.width/2-titleFrame.size.width/2;
//    titleLabel.frame = titleFrame;

    
    UILabel *reminder = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+10, 260, 40)];
    [reminder setNumberOfLines:6];
    [reminder setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
    [reminder setText:@"Remember to open the app once it is downloaded."];
    [reminder sizeToFit];
    CGRect reminderFrame = reminder.frame;
    reminderFrame.origin.x = self.inner.frame.size.width/2 - reminderFrame.size.width/2;
    reminder.frame = reminderFrame;
    [reminder setTextAlignment:NSTextAlignmentCenter];
    [reminder setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
    [self.inner addSubview:reminder];
    
    
    UILabel *newInstruct = [[UILabel alloc] initWithFrame:CGRectMake(20, 10+reminder.frame.size.height+reminder.frame.origin.y, 240, 120)];
    NSString *instruct = [_data objectForKey:@"description"];
    instruct = [NSString stringWithFormat:@"Instructions: %@", instruct];
    [newInstruct setText:instruct];
    [newInstruct setNumberOfLines:6];
    [newInstruct setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
    [newInstruct sizeToFit];
    CGRect instructFrame = newInstruct.frame;
    instructFrame.origin.x = self.inner.frame.size.width/2 - instructFrame.size.width/2;
    newInstruct.frame = instructFrame;
    [newInstruct setTextAlignment:NSTextAlignmentCenter];
    [newInstruct setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
    [self.inner addSubview:newInstruct];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(20, newInstruct.frame.origin.y+newInstruct.frame.size.height+10, 240, 120)];
    
    int totalSeconds = [[_data objectForKey:@"time"] intValue];
    int hours = totalSeconds / (60 * 60);
    totalSeconds = hours > 0?(totalSeconds-(hours * (60 * 60))):totalSeconds;
    int minutes = totalSeconds / 60;
    
    NSString *formatString = @"Offer may take up to %d hours and %d minutes to award.";
    NSString *timeText = [NSString stringWithFormat:formatString, hours, minutes];
    
    if(minutes < 1){
        formatString = @"Offer may take up to %d hours to award.";
        if(hours < 2){
            formatString = @"Offer may take up to %d hour to award.";
        }
        timeText = [NSString stringWithFormat:formatString, hours];
    }
    
    if(hours < 1){
        formatString = @"Offer may take up to %d minutes to award.";
        timeText = [NSString stringWithFormat:formatString, minutes];
    }
    
    
    [time setText: timeText];
    [time setNumberOfLines:2];
    [time setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]];
    [time setTextColor:[UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1]];
    [time setTextAlignment:NSTextAlignmentCenter];
    [time sizeToFit];
    CGRect timeFrame = time.frame;
    timeFrame.origin.x = self.inner.frame.size.width/2 - timeFrame.size.width/2;
    time.frame = timeFrame;
    [self.inner addSubview:time];
    
    [continueButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [continueButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setTitle:@"Okay" forState:UIControlStateNormal];
    continueButton.frame = CGRectMake(20, time.frame.origin.y+time.frame.size.height+20, 240, 50);
    CGRect oldFrame3 = self.inner.frame;
    oldFrame3.size.height = continueButton.frame.origin.y + continueButton.frame.size.height+20;
    self.inner.frame = oldFrame3;
    [continueButton setUserInteractionEnabled:YES];
}

- (void) sponsorPayHelpClicked:(id)sender
{
    UIWebView *support = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.inner.frame.size.width, self.inner.frame.size.height)];
    support.layer.cornerRadius = 10.0f;
    [support setClipsToBounds:YES];
    [self.inner addSubview:support];
    _progress.hidden = YES;
    if ([[_data objectForKey:@"vendor"] isEqualToString:@"spay"]) {
        [support loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[sharedInstance sponsorPayHelp]]]];
    }else if([[_data objectForKey:@"vendor"] isEqualToString:@"aarki"]){
        [support loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[sharedInstance aarkiHelp]]]];
    }
}

- (void) pend
{
    NSString *title = [_data objectForKey:@"name"];
    NSString *userID = [sharedInstance userID];
    NSDate *date = [NSDate date];
    NSString *rewardID = [_data objectForKey:@"id"];
    NSString *pointValue = [_data objectForKey:@"points"];
    NSString *time = [_data objectForKey:@"time"];
    NSString *image = [_data objectForKey:@"image"];
    NSString *vendor = [_data objectForKey:@"vendor"];
    NSString *url = [_data objectForKey:@"url"];
    NSString *description = [_data objectForKey:@"description"];
    NSString *postString = [NSString stringWithFormat:@"rewardID=%@&userID=%@&name=%@&time=%lld&points=%@&time=%@&image=%@&vendor=%@&url=%@&description=%@", rewardID, userID, title, [@(floor([date timeIntervalSince1970])) longLongValue], pointValue, time, image, vendor, url, description];
    NSMutableURLRequest *request = [sharedInstance requestForEndpoint:@"pending" andBody:postString];
    NSError *error;
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
}

- (void) startLoad
{
    if(![[_data objectForKey:@"type"] isEqualToString:@"pending"]){
        [self pend];
    }
    [continueButton setUserInteractionEnabled:NO];
    [continueButton setTitle:@"Loading" forState:UIControlStateNormal];
    [_web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_data objectForKey:@"url"]]]];
}

- (id) initWithData:(NSDictionary *)data
{
    self = [super initWithFrame:CGRectMake(0, 0, 280, 500)];
    if (self) {
        _data = data;
        sharedInstance = [API sharedInstance];
        
        
        NSString *points = [NSString stringWithFormat:@"%@", [_data objectForKey:@"points"]];
        UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 175)];
        [pointsLabel setText:points];
        [pointsLabel setTextAlignment:NSTextAlignmentCenter];
        [pointsLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:250.0]];
        [pointsLabel sizeToFit];
        [pointsLabel setTextColor:[UIColor colorWithRed:0 green:0.49 blue:0.84 alpha:1]];
        CGRect pointsFrame = pointsLabel.frame;
        pointsFrame.origin.y = -75;
        pointsFrame.origin.x = self.inner.frame.size.width/2 - pointsFrame.size.width/2;
        pointsLabel.frame = pointsFrame;
        //        [self.inner setClipsToBounds:YES];
        //        [self.inner addSubview:pointsLabel];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.inner.frame.size.width/2-30, 20, 60, 59)];
        imageView.image = [UIImage imageWithData:[[sharedInstance imageCache] objectForKey:[_data objectForKey:@"image"]]];
        imageView.layer.cornerRadius = 10.0f;
        [imageView setClipsToBounds:YES];
        [self.inner addSubview:imageView];
        
        NSString *title = [_data objectForKey:@"name"];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+10, 260, 40)];
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
        
        NSString *instruct = [_data objectForKey:@"description"];
        instructions = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+titleLabel.frame.size.height+titleLabel.frame.origin.y, 260, 120)];
        [instructions setNumberOfLines:6];
        [instructions setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        instruct = [NSString stringWithFormat:@"Instructions: %@", instruct];
        [instructions setText:instruct];
        [instructions sizeToFit];
        CGRect oldFrame = instructions.frame;
        oldFrame.origin.x = self.inner.frame.size.width/2 - oldFrame.size.width/2;
        instructions.frame = oldFrame;
        [instructions setTextAlignment:NSTextAlignmentCenter];
        [instructions setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
        [self.inner addSubview:instructions];
        
        NSString *guide = @"Keep app open for 30+ seconds.\nDon’t switch networks (3G, LTE to Wi-FI).\nSome offers may take up to 24 hours.";
        
        if([[_data objectForKey:@"type"] isEqualToString:@"pending"]){
            guide = @"This offer is currently pending. It has neither finished completing nor failed. If you believe you didn't adhere to the steps outline in our Install Tutorial video, you may retry the offer for a limited period of time.";
        }
        
        guidelines = [[UILabel alloc] initWithFrame:CGRectMake(20, instructions.frame.origin.y+instructions.frame.size.height+10, 240, 120)];
        [guidelines setText:guide];
        [guidelines setNumberOfLines:5];
        [guidelines setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [guidelines setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
        [guidelines setTextAlignment:NSTextAlignmentCenter];
        [guidelines sizeToFit];
        [self.inner addSubview:guidelines];
        
        helpLabel = [[UIButton alloc] initWithFrame:CGRectMake(20, guidelines.frame.origin.y+guidelines.frame.size.height+10, 240, 20)];
        [helpLabel setTitle:@"Missing Points? Tap for Help!" forState:UIControlStateNormal];
        [helpLabel.titleLabel setFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f]];
        [helpLabel setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [helpLabel addTarget:self action:@selector(sponsorPayHelpClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.inner addSubview:helpLabel];
        
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, helpLabel.frame.origin.y+helpLabel.frame.size.height+10, 240, 10)];
        [_progress setProgress:0.0f];
        [self.inner addSubview:_progress];
        
        continueButton = [[UIButton alloc] initWithFrame:CGRectMake(20, _progress.frame.origin.y+_progress.frame.size.height+10, 240, 50)];
        continueButton.layer.cornerRadius = 5.0f;
        [continueButton setClipsToBounds:YES];
        [continueButton setBackgroundColor:[UIColor colorWithRed:0 green:0.49 blue:0.84 alpha:1]];
        [continueButton setTitle:@"Contiue" forState:UIControlStateNormal];
        
        if([[_data objectForKey:@"type"] isEqualToString:@"pending"]){
            [continueButton setTitle:@"Retry?" forState:UIControlStateNormal];
        }
        
        [continueButton addTarget:self action:@selector(startLoad) forControlEvents:UIControlEventTouchUpInside];
        [self.inner addSubview:continueButton];
        
        CGRect oldFrame2 = self.inner.frame;
        oldFrame2.size.height = continueButton.frame.origin.y + continueButton.frame.size.height+20;
        self.inner.frame = oldFrame2;
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
