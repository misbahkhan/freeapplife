//
//  amazonPopUp.h
//  FreeAppLife
//
//  Created by Misbah Khan on 7/31/14.
//  Copyright (c) 2014 Adrian D'Urso. All rights reserved.
//

#import "customPopUp.h"

@interface amazonPopUp : customPopUp
@property (nonatomic, strong) NSDictionary *data;

- (id) initWithData:(NSDictionary *)data;

@end