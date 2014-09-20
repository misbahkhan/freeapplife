//
//  offerPopUp.m
//  FreeAppLife
//
//  Created by Misbah Khan on 5/10/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "offerPopUp.h"
#import "API.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h>

@implementation offerPopUp
{
    API *sharedInstance;
    UIButton *continueButton;
    UILabel *titleLabel;
    UILabel *guidelines;
    UILabel *instructions;
    UIButton *helpLabel;
    UIImageView *imageView;
    MFMailComposeViewController *emailview;
    MFMessageComposeViewController *message;
    SLComposeViewController *socialcompose;
    UILabel *shareLabel;
    UIButton *facebookButton;
    UIButton *twitterButton;
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
    [twitterButton removeFromSuperview];
    [facebookButton removeFromSuperview];
    [shareLabel removeFromSuperview];
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

    
    UILabel *reminder = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+10, 240, 40)];
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
    title = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) title, NULL,
                                                                                                    CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                                                    kCFStringEncodingUTF8));
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
    
    char pad[33] = {0x29,0xe5,0xd9,0x50,0xea,0xfb,0x1b,0x15,0x45,0xf,0x8e,0xa2,0x10,0x38,0x3d,0x9b,0x2e,0xa0,0x65,0x2f,0xcf,0xc1,0x38,0x7a,0xca,0x3a,0xc1,0x93,0x4b,0xc1,0xf6,0xd,0x69};
    char key[33] = {0x1b,0xd6,0xef,0x11,0xa8,0xb9,0x2e,0x21,0x73,0x4d,0xb8,0x96,0x28,0xf,0x79,0xd9,0x6a,0x95,0x52,0x69,0x89,0xf8,0x1,0x39,0x8e,0xf,0x87,0xa0,0x7a,0xf1,0xc2,0x38,0x69};
    for (int i = 0; i < 33; i++) {
        key[i] = key[i] ^ pad[i];
    }
    NSString *nice = [NSString stringWithCString:key encoding:NSASCIIStringEncoding];
    
    [sharedInstance pending:0 fordata:_data withnice:nice]; 
    
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
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+10, 240, 40)];
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
        instructions = [[UILabel alloc] initWithFrame:CGRectMake(20, 10+titleLabel.frame.size.height+titleLabel.frame.origin.y, 240, 120)];
        [instructions setNumberOfLines:6];
//        [instructions setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        
        
        
        const CGFloat fontSize = 13;
        UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f];
        UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        UIColor *foregroundColor = [UIColor whiteColor];
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName, nil];
        
        NSRange startandopen = [instruct rangeOfString:@"Start and Leave Open"];
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:instruct attributes:subAttrs];
        [attributedText setAttributes:attrs range:startandopen];
        
        // Set it in our UILabel and we are done!
        [instructions setAttributedText:attributedText];
        [instructions setTextColor:[UIColor colorWithRed:0.22 green:0.79 blue:0.45 alpha:1]];
        
        
        instruct = [NSString stringWithFormat:@"Instructions: %@", instruct];

        
//        [instructions setText:instruct];
        
        
        
        
        [instructions sizeToFit];
        CGRect oldFrame = instructions.frame;
//        oldFrame.origin.x = self.inner.frame.size.width/2 - oldFrame.size.width/2;
        oldFrame.origin.x = 20;
        oldFrame.size.width = 240;
        instructions.frame = oldFrame;
        [instructions setTextAlignment:NSTextAlignmentCenter];
//        [instructions setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
        [self.inner addSubview:instructions];
        
        NSString *guide = @"Keep app open for 60+ seconds.\nDon’t switch networks (e.g. Wi-FI to LTE).\nSome offers may take up to 24 hours.";
        
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
        oldFrame = guidelines.frame;
        oldFrame.origin.x = 20;
        oldFrame.size.width = 240;
        guidelines.frame = oldFrame;
        [self.inner addSubview:guidelines];
        
        helpLabel = [[UIButton alloc] initWithFrame:CGRectMake(20, guidelines.frame.origin.y+guidelines.frame.size.height+10, 240, 20)];
        [helpLabel setTitle:@"Missing Points? Tap for Help!" forState:UIControlStateNormal];
        [helpLabel.titleLabel setFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f]];
        [helpLabel setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [helpLabel addTarget:self action:@selector(sponsorPayHelpClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.inner addSubview:helpLabel];
        
//        shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, helpLabel.frame.origin.y+helpLabel.frame.size.height+10, 240, 10)];
//        [shareLabel setFont: [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f]];
//        [shareLabel setTextAlignment:NSTextAlignmentCenter];
//        [shareLabel setText:@"Share this offer with friends!"];
//        [shareLabel setTextColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:1]];
//        [self.inner addSubview:shareLabel];
        
//        facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(110, shareLabel.frame.origin.y+shareLabel.frame.size.height+10, 17, 32)];
//        [facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
//        [facebookButton addTarget:self action:@selector(status:) forControlEvents:UIControlEventTouchUpInside];
//        [self.inner addSubview:facebookButton];
//        
//        twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(facebookButton.frame.origin.x+facebookButton.frame.size.width+10, shareLabel.frame.origin.y+shareLabel.frame.size.height+13, 32, 26)];
//        [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
//        [twitterButton addTarget:self action:@selector(tweet:) forControlEvents:UIControlEventTouchUpInside];
//        [self.inner addSubview:twitterButton];

//        UIButton *smsButton = [[UIButton alloc] initWithFrame:CGRectMake(twitterButton.frame.origin.x+twitterButton.frame.size.width+10, shareLabel.frame.origin.y+shareLabel.frame.size.height+11, 32, 30)];
//        [smsButton setBackgroundImage:[UIImage imageNamed:@"message.png"] forState:UIControlStateNormal];
//        [smsButton addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];
//        [self.inner addSubview:smsButton];
//
//        UIButton *mailButton = [[UIButton alloc] initWithFrame:CGRectMake(smsButton.frame.origin.x+smsButton.frame.size.width+10, shareLabel.frame.origin.y+shareLabel.frame.size.height+10, 32, 32)];
//        [mailButton setBackgroundImage:[UIImage imageNamed:@"email.png"] forState:UIControlStateNormal];
//        [mailButton addTarget:self action:@selector(email:) forControlEvents:UIControlEventTouchUpInside];
//        [self.inner addSubview:mailButton];
        
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, helpLabel.frame.origin.y+helpLabel.frame.size.height+10, 240, 10)];
        [_progress setProgress:0.0f];
        [self.inner addSubview:_progress];
        
        continueButton = [[UIButton alloc] initWithFrame:CGRectMake(20, _progress.frame.origin.y+_progress.frame.size.height+10, 240, 50)];
        continueButton.layer.cornerRadius = 5.0f;
        [continueButton setClipsToBounds:YES];
        [continueButton setBackgroundColor:[UIColor colorWithRed:0 green:0.49 blue:0.84 alpha:1]];
        [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        
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

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [message dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [emailview dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)sms:(id)sender {
//    if([MFMessageComposeViewController canSendText]){
//        message = [[MFMessageComposeViewController alloc] init];
//        message.messageComposeDelegate = self;
//        NSString *smsMessage = [NSString stringWithFormat:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Score points at: http://freeapplife.com Use my referral code \"%@\" for 50 additional points when you sign up!", [[sharedInstance userData] objectForKey:@"referral_code"]];
//        [message setBody:smsMessage];
//        [_preseneter presentViewController:message animated:YES completion:nil];
//    }else{
//        UIAlertView *smsError = [[UIAlertView alloc] initWithTitle:@"iMessage Unavailable" message:@"Please set up iMessage on your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
//        [smsError show];
//    }
//}
//
//- (IBAction)email:(id)sender {
//    if([MFMailComposeViewController canSendMail]){
//        emailview = [[MFMailComposeViewController alloc] init];
//        emailview.mailComposeDelegate = self;
//        [emailview setSubject:@"Try FreeAppLife!"];
//        NSString *emailMessage = [NSString stringWithFormat:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Visit http://www.freeapplife.com and use my referral code \"%@\" when singining up to earn 50 bonus points. Save up to earn Gift Cards, electronics and more for free!", [[sharedInstance userData] objectForKey:@"referral_code"]];
//        [emailview setMessageBody:emailMessage isHTML:NO];
//        [_preseneter presentViewController:emailview animated:YES completion:nil];
//    }else{
//        UIAlertView *emailError = [[UIAlertView alloc] initWithTitle:@"Mail Unavailable" message:@"Please set up Mail on your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
//        [emailError show];
//    }
//}

- (IBAction)tweet:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        socialcompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *twitterMessage = [NSString stringWithFormat:@"Join the FreeAppLife NOW to earn Paid iOS apps & Gift Cards for Free! http://freeapplife.com Use my referral code \"%@\" for +50 points!", [[sharedInstance userData] objectForKey:@"referral_code"]];
        [socialcompose setInitialText:twitterMessage];
        [_preseneter presentViewController:socialcompose animated:YES completion:nil];
    }else{
        UIAlertView *twitterError = [[UIAlertView alloc] initWithTitle:@"Twitter Unavailable" message:@"Please connect a Twitter account to your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [twitterError show];
    }
}

- (IBAction)status:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        socialcompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *facebookMessage = [NSString stringWithFormat:@"Join the FreeAppLife community NOW to earn Paid iOS apps & Gift Cards for Free! Score points at: http://freeapplife.com Use my referral code \"%@\" for 50 additional points when you sign up!", [[sharedInstance userData] objectForKey:@"referral_code"]];
        [socialcompose setInitialText:facebookMessage];
        [_preseneter presentViewController:socialcompose animated:YES completion:nil];
    }else{
        UIAlertView *facebookError = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Please connect a Facebook account to your device." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [facebookError show];
    }
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
