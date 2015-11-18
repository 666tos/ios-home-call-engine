//
//  SafeMutableDictionary.m
//  NGT International B.V.
//
//  Created by Daniel Chicco on 07/06/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

// Taken from: http://stackoverflow.com/questions/1986736/nsmutabledictionary-thread-safety
#import "SafeMutableDictionary.h"

@implementation SafeMutableDictionary

- (id)init
{
    if (self = [super init])
    {
        _lock = [[NSLock alloc] init];
        _underlyingDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_lock release];
    [_underlyingDictionary release];
    
    [super dealloc];
}

- (NSUInteger)count
{
    NSUInteger result = 0;
    
    [_lock lock];
    result = [_underlyingDictionary count];
    [_lock unlock];
    
    return result;
}

- (id)objectForKey:(id)aKey
{
    id result = nil;
    
    [_lock lock];
    result = [[_underlyingDictionary objectForKey:aKey] retain];
    [_lock unlock];
    
    return [result autorelease];
}

- (NSArray *)allKeys
{
    NSArray *result = nil;
    
    [_lock lock];
    result = [[_underlyingDictionary allKeys] retain];
    [_lock unlock];
    
    return [result autorelease];
}

- (NSArray *)allKeysForObject:(id)anObject
{
    NSArray *result = nil;
    
    [_lock lock];
    result = [[_underlyingDictionary allKeysForObject:anObject] retain];
    [_lock unlock];
    
    return [result autorelease];
}

- (NSArray *)allValues
{
    NSArray *result = nil;
    
    [_lock lock];
    result = [[_underlyingDictionary allValues] retain];
    [_lock unlock];

    return [result autorelease];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %p %@", NSStringFromClass(self.class), self, [_underlyingDictionary description]];
}

- (void)removeObjectForKey:(id)aKey
{
    [_lock lock];
    [_underlyingDictionary removeObjectForKey:aKey];
    [_lock unlock];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    [_lock lock];
    [_underlyingDictionary setObject:anObject forKey:aKey];
    [_lock unlock];
}

- (void)removeAllObjects
{
    [_lock lock];
    [_underlyingDictionary removeAllObjects];
    [_lock unlock];
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    [_lock lock];
    [_underlyingDictionary removeObjectsForKeys:keyArray];
    [_lock unlock];
}

@end
