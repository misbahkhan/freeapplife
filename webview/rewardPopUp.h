//
//  rewardPopUp.h
//  FreeAppLife
//
//  Created by Misbah Khan on 5/10/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "popup.h"

@interface rewardPopUp : popUp

@property (nonatomic, strong) NSDictionary *data; 

- (id) initWithData:(NSDictionary *)data;

@end
