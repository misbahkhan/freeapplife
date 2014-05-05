//
//  cellView.h
//  FreeAppLife
//
//  Created by Misbah Khan on 4/17/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cellView : UIView

@property (nonatomic, strong) NSDictionary *data;

- (void) setData:(NSDictionary *)data;

@end
