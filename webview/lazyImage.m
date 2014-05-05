//
//  lazyImage.m
//  FreeAppLife
//
//  Created by Misbah Khan on 4/16/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "lazyImage.h"
#import "API.h"

@implementation lazyImage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)loadURL:(NSString *)URL
{
    API *sharedInstance = [API sharedInstance];
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if([sharedInstance.imageCache objectForKey:URL] > 0){
        self.image = [UIImage imageWithData:[sharedInstance.imageCache objectForKey:URL]];
    }else{
        self.image = image;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]] queue:[NSOperationQueue mainQueue]
           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
               UIImage *image = [UIImage imageWithData:data];
               dispatch_async(dispatch_get_main_queue(), ^{
                   [sharedInstance.imageCache setObject:data forKey:URL];
                   [UIView transitionWithView:self
                                     duration:0.8f
                                      options:UIViewAnimationOptionTransitionCrossDissolve
                                   animations:^{
                                       self.image = image;
                                   }completion:NULL];
               });
           }];
    }
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
