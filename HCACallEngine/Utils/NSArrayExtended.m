//
//  NSArrayExtended.m
//  NGT International B.V.
//
//  Created by Ronnie on 9/19/12.
//  Copyright (c) 2012 NGT International B.V. All rights reserved.
//

#import "NSArrayExtended.h"

@implementation NSArray (Extended)

/**
 * Return if the array is nil or empty.
 * @return YES when the array is not nil and contains elements, otherwise NO.
 */
- (BOOL)isNotEmpty
{
    return (self.count != 0);
}


@end

@implementation NSPointerArray (Extended)

- (id)objectAtIndex:(NSUInteger)index
{
    return [self pointerAtIndex:index];
}

- (void)addObject:(id)pointer
{
    [self addPointer:(__bridge void *)(pointer)];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    for (NSUInteger i = 0; i < self.count; i++)
    {
        id object = [self objectAtIndex:i];
        
        if (object == anObject)
        {
            return i;
        }
    }
    
    return NSNotFound;
}

- (BOOL)containsObject:(id)anObject
{
    return ([self indexOfObject:anObject] != NSNotFound);
}

- (void)removeObject:(id)anObject
{
    NSUInteger index = [self indexOfObject:anObject];
    
    if (index != NSNotFound)
    {
        [self removePointerAtIndex:index];
    }
}

- (void)removeAllObjects
{
    for (NSUInteger i = self.count; i > 0; i--)
    {
        [self removePointerAtIndex:i - 1];
    }
}

@end
