//
//  NSStringExtended.h
//  NGT International B.V.
//
//  Created by Ronnie on 9/19/12.
//  Copyright (c) 2012 NGT International B.V. All rights reserved.
//
//  Contains extensions to existing NSString functionality.
//


#import <Foundation/Foundation.h>


@interface NSString (Extended)

- (NSString *)URLEncodedString;
- (NSString *)MinimalURLEncodedString;
- (NSString *)URLDecodedString;

@property (nonatomic, readonly) BOOL isNotEmpty;

@end
