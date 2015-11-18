//
//  NSArrayExtended.h
//  NGT International B.V.
//
//  Created by Ronnie on 9/19/12.
//  Copyright (c) 2012 NGT International B.V. All rights reserved.
//
// Contains extensions to existing NSArray functionality.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extended)

@property (nonatomic, readonly) BOOL isNotEmpty;



@end

@interface NSPointerArray (Extended)

- (id)objectAtIndex:(NSUInteger)index;
- (void)addObject:(id)pointer;
- (NSUInteger)indexOfObject:(id)anObject;
- (BOOL)containsObject:(id)anObject;
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;

@end