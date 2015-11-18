//
//  ContactID.m
//  iO
//
//  Created by Joost de Moel on 4/4/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import "ContactID.h"

#import "NSStringExtended.h"
#import "JabberID.h"
//#import "Domain.h"
#import "Common.h"

@interface ContactID()
{
    NSString*   _normalizedPhoneNumber;
    NSString*   _ucidJid;
}

- (BOOL)isString:(NSString*)string1 equalToString:(NSString*)string2;

@end



@implementation ContactID

@synthesize normalizedPhoneNumber   = _normalizedPhoneNumber;
@synthesize ucidJid                 = _ucidJid;

NSString *kContactID_NormalizedPhoneNumberKey = @"kNormalizedPhoneNumberKey";
NSString *kContactID_UcidJidKey               = @"kUcidJidKey";

/********************************************************************************************/
/* Initialization                                                                           */
/********************************************************************************************/

#pragma mark - Initialization

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        _normalizedPhoneNumber  = [[dictionary valueForKey:kContactID_NormalizedPhoneNumberKey] copy];
        _ucidJid                = [[dictionary valueForKey:kContactID_UcidJidKey] copy];
    }
    
    return self;
}

- (id)initWithUcidJid:(NSString*)ucidJid
{
    if (self = [super init])
    {
        _ucidJid                = [ucidJid copy];
    }
    
    return self;
}


- (id)initWithNormalizedPhoneNumber:(NSString*)phoneNumber
{
    if (self = [super init])
    {
        _normalizedPhoneNumber  = [phoneNumber copy];
    }
    
    return self;
}


- (id)initWithNormalizedPhoneNumber:(NSString*)phoneNumber withUcidJid:(NSString*)jid
{
    if (self = [super init])
    {
        if (phoneNumber)
        {
            _normalizedPhoneNumber  = [phoneNumber copy];
        }
        
        if (jid)
        {
            _ucidJid                = [jid copy];
        }
    }
    
    return self;
}


- (void)dealloc
{
    [_normalizedPhoneNumber release];
    [_ucidJid release];
    
    [super dealloc];
}


-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_normalizedPhoneNumber)
    {
        [dict setValue:_normalizedPhoneNumber forKey:kContactID_NormalizedPhoneNumberKey];
    }

    if (_ucidJid)
    {
        [dict setValue:_ucidJid forKey:kContactID_UcidJidKey];
    }

    return [NSDictionary dictionaryWithDictionary:dict];
}


- (NSString *)description
{
    NSMutableString *result = [NSMutableString stringWithString:@"ContactID:["];
    
    [result appendFormat:@" _normalizedPhoneNumber:%@", _normalizedPhoneNumber];
    [result appendFormat:@" _ucidJid:%@", _ucidJid];
    
    [result appendString:@"]"];
    
    return result;
}

/********************************************************************************************/
/* NSObject methods                                                                         */
/* Functions needed when using this object as key in a dictionary                           */
/********************************************************************************************/

#pragma mark - NSObject methods

- (BOOL)isEqual:(id)anObject
{
    if (![anObject isKindOfClass:[self class]])
    {
        return NO;
    }
    
    return [self isEqualToContactID:(ContactID*)anObject];
}


- (NSUInteger)hash
{
    NSMutableString* string = [[NSMutableString alloc] initWithString:@""];
    
    if (_normalizedPhoneNumber != nil)
    {
        [string appendString:_normalizedPhoneNumber];
    }
    if (_ucidJid != nil)
    {
        [string appendString:_ucidJid];
    }
    
    NSUInteger hash = [string hash];
    
    [string release];
    
    return hash;
}


/********************************************************************************************/
/* NSCopying methods                                                                        */
/********************************************************************************************/

#pragma mark - NSCopying

/**
 * Returns a new instance that’s a copy of the receiver.
 */
- (id)copyWithZone:(NSZone *)zone
{
    ContactID *copy = nil;
    
    NSString* jidCopy = nil;
    
    if (_ucidJid != nil)
    {
        jidCopy = [_ucidJid copyWithZone:zone];
    }
    
    
    if (_normalizedPhoneNumber != nil)
    {
        NSString* phoneNumberCopy = [_normalizedPhoneNumber copyWithZone:zone];
        
        copy = [[ContactID allocWithZone:zone] initWithNormalizedPhoneNumber:phoneNumberCopy withUcidJid:jidCopy];
        
        [phoneNumberCopy release];
    }
    else
    {
        copy = [[ContactID allocWithZone:zone] initWithUcidJid:jidCopy];
    }
    
    if (jidCopy)
    {
        [jidCopy release];
    }
    
    return copy;
}


/********************************************************************************************/
/* Other public methods                                                                     */
/********************************************************************************************/

#pragma mark - Public methods

- (BOOL)isEqualToContactID:(ContactID*)otherContactID
{
    if (![self isString:_ucidJid equalToString:otherContactID.ucidJid])
    {
        return NO;
    }
    
    if (![self isString:_normalizedPhoneNumber equalToString:otherContactID.normalizedPhoneNumber])
    {
        return NO;
    }
    
    return YES;
}

/********************************************************************************************/
/* Private methods                                                                          */
/********************************************************************************************/

#pragma mark - Private methods

/**
 * Compares two strings. Also returns YES if both strings are nil.
 */
- (BOOL)isString:(NSString*)string1 equalToString:(NSString*)string2
{
    if (string1 == nil)
    {
        return string2 == nil;
    }
    
    if (string2 == nil)
    {
        return NO;
    }
    
    return [string1 isEqualToString:string2];
}

@end
