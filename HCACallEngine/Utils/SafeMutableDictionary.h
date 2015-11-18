//
//  SafeMutableDictionary.h
//  NGT International B.V.
//
//  Created by Daniel Chicco on 07/06/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SafeMutableDictionary : NSObject
{
    NSLock *             _lock;
    NSMutableDictionary *_underlyingDictionary;
}

- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSArray *)allKeys;
- (NSArray *)allKeysForObject:(id)anObject;
- (NSArray *)allValues;
- (NSString *)description;

- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id)aKey;

- (void)removeAllObjects;
- (void)removeObjectsForKeys:(NSArray *)keyArray;

@end

