//
//  LocalyticsEvent.h
//  iO
//
//  Created by Joost de Moel on 13/11/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalyticsEvent : NSObject

@property (nonatomic, strong) NSString *        name;
@property (nonatomic, strong) NSDictionary *    attributes;
@property (nonatomic, strong) NSNumber *        customerValueIncrease;

@end
