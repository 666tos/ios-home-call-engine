//
//  LocalyticsEvent.m
//  iO
//
//  Created by Joost de Moel on 13/11/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "LocalyticsEvent.h"

@implementation LocalyticsEvent

- (void)dealloc
{
    self.name = nil;
    self.attributes = nil;
    self.customerValueIncrease = nil;
    
    [super dealloc];
}

@end
