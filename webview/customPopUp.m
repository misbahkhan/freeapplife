//
//  customPopUp.m
//  FreeAppLife
//
//  Created by Misbah Khan on 5/11/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "customPopUp.h"

@implementation customPopUp

- (void) hide
{
    [_web stopLoading];
    [_web stringByEvaluatingJavaScriptFromString:@"ytplayer.stopVideo();"];
    [_web loadRequest:nil];
    [_web removeFromSuperview];
    [super hide];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _web = [[UIWebView alloc] initWithFrame:frame];
        [_web setAllowsInlineMediaPlayback:YES];
        [_web setMediaPlaybackRequiresUserAction:NO];
        [_web.scrollView setScrollEnabled:NO];
        [_web setUserInteractionEnabled:NO];
        [self.inner addSubview:_web];
        
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
