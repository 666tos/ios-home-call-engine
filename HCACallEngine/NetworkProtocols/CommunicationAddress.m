//
//  CommunicationAddress.m
//  NGT International B.V.
//
//  Created by Joost de Moel on 11/26/12.
//  Copyright (c) 2012 NGT International. All rights reserved.
//

#import "CommunicationAddress.h"
#import "NSStringExtended.h"
#import "JabberID.h"
//#import "Domain.h"
#import "XMPPJidParser.h"
#import "Common.h"

@interface CommunicationAddress()
{
    ContactID *  _contactID;
    
    NSString *   _routeAddress;
    NSString *   _resource;
    
}

- (BOOL)isString:(NSString*)string1 equalToString:(NSString*)string2;

@end

@implementation CommunicationAddress

@synthesize contactID               = _contactID;
@synthesize routeAddress            = _routeAddress;
@synthesize resource                = _resource;

NSString *kFacebookIDKey    = @"kFacebookIDKey";
NSString *kBareJidKey       = @"kBareJidKey";
NSString *kResourceKey      = @"kResourceKey";

/********************************************************************************************/
/* Initialization                                                                           */
/********************************************************************************************/

#pragma mark - Initialization

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        _contactID      = [[ContactID alloc] initFromDictionary:dictionary];
        _routeAddress   = [[dictionary valueForKey:kBareJidKey] copy];
        _resource       = [[dictionary valueForKey:kResourceKey] copy];
    }
    
    return self;
}

/**
 * @param bareJid the
 * @param resource can be nil
 */
- (id)initWithContactID:(ContactID*)contactID withAddress:(NSString*)routeAddress withResource:(NSString*)resource
{
    if (self = [super init])
    {
        _contactID          = contactID;
        _routeAddress       = [routeAddress copy];
        
        if (resource)
        {
            _resource       = [resource copy];
        }
    }
    
    return self;    
}

-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (_contactID)
    {
        NSDictionary* contactIDdict = [_contactID toDictionary];
        
        for (NSString* key in contactIDdict)
        {
            [dict setValue:contactIDdict[key] forKey:key];
            
        }
    }
    
    if (_routeAddress)
    {
        [dict setValue:_routeAddress forKey:kBareJidKey];
    }
    
    if (_resource)
    {
        [dict setValue:_resource forKey:kResourceKey];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}


/**
 * @returns an exact copy of the current object without resource
 */
- (CommunicationAddress*)copyWithoutResource
{
    return [[CommunicationAddress alloc] initWithContactID:_contactID withAddress:_routeAddress withResource:nil];
}


/**
 * Construct a CommunicationAddress object based on the given fromJid and altFromJid
 *
 * Note: 'fromJid' is a 'routing jid' (something we receive from or send to). What we should do is lookup the UCID corresponding to the routing jid,
 *       but we DON'T do that yet. For now, we consider the fromJid to be the same as the UCID jid corresponding to a phonenumber
 *
 * @param jid can be either a barejid or a fulljid
 * @param altFrom Should be like phone:<phoneNumber>. Can be nil or empty in which case a communication address with only a jid is constructed
 * @return nil if we don't support the data in this altFrom
 */
+ (CommunicationAddress*)communicationAddressWithFromJid:(NSString*)fromJid withAlternativeFrom:(NSString*)altFrom
{
    NSString * bareJid = nil;
    NSString * resource = nil;
    
    [XMPPJidParser getBareJidAndResourceFromJid:fromJid intoBareJid:&bareJid intoResource:&resource];
    
    ContactID* contactID = nil;
    
    //HomeCenter: We don't need this hack there
//    if (altFrom.isNotEmpty)
//    {
//        //
//        // Check if this altFrom contains something we can handle
//        //
//        
//        NSString * address = nil;
//        AddressType addressType;
//        
//        if ([XMPPJidParser getTypeAndAddressFromUri:altFrom intoType:&addressType intoAddress:&address])
//        {
//            if (address != nil && addressType == AddressTypePhoneNumber)
//            {
//                contactID = [[ContactID alloc] initWithNormalizedPhoneNumber:address withUcidJid:bareJid];
//            }
//        }
//        
//        if (contactID == nil)
//        {
//            // altFrom contains something we can't handle
//            ELOG(DEFAULT, "Unable to parse altFrom address: %@", altFrom);
//                
//            return nil;
//        }
//    }
//    else
//    {
        //
        // If there's no altFrom, it can be that the 'fromJid' is a phonenumber instead of a ucid (e.g. when we receive an SMS)
        //
        
//        NSString * address = nil;
//        AddressType addressType;
//        
//        if ([XMPPJidParser getTypeAndAddressFromUri:altFrom intoType:&addressType intoAddress:&address])
//        {
//            if (address != nil && addressType == AddressTypePhoneNumber)
//            {
//                contactID = [[ContactID alloc] initWithNormalizedPhoneNumber:address];
//            }
//        }
//    }
    
    
    if (contactID == nil)
    {
        contactID = [[ContactID alloc] initWithUcidJid:bareJid];
    }


    CommunicationAddress* communicationAddress = [[CommunicationAddress alloc] initWithContactID:contactID withAddress:bareJid withResource:resource];

    return communicationAddress;
}


- (NSString *)description
{
    NSMutableString *result = [NSMutableString stringWithString:@"CommunicationAddress:["];
    
    [result appendFormat:@" _contactID:%@", _contactID];
    [result appendFormat:@" _routeAddress:%@", _routeAddress];
    [result appendFormat:@" _resource:%@", _resource];
    
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
    
    return [self isEqualToCommunicationAddress:(CommunicationAddress*)anObject];
}


- (NSUInteger)hash
{
    NSMutableString* string = [[NSMutableString alloc] initWithString:@""];
    
    if (_contactID != nil)
    {
        [string appendString:_contactID.description];
    }
    if (_routeAddress != nil)
    {
        [string appendString:_routeAddress];
    }
    if (_resource != nil)
    {
        [string appendString:_resource];
    }
    
    NSUInteger hash = [string hash];
    
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
    NSString* bareJid           = nil;
    NSString* resource          = nil;
    ContactID* contactIDcopy    = nil;
    
    if (_routeAddress)
    {
        bareJid   = [_routeAddress copyWithZone:zone];
    }
    
    if (_resource)
    {
        resource  = [_resource copyWithZone:zone];
    }
    
    if (_contactID)
    {
        contactIDcopy = [_contactID copyWithZone:zone];
    }
    
    CommunicationAddress *copy = [[CommunicationAddress allocWithZone:zone] initWithContactID:contactIDcopy withAddress:bareJid withResource:resource];
    
    return copy;
}


/********************************************************************************************/
/* Other public methods                                                                     */
/********************************************************************************************/

#pragma mark - Public methods

- (BOOL)isEqualToCommunicationAddress:(CommunicationAddress*)otherAddress
{
    if (![self isEqualToCommunicationAddressIgnoringResource:otherAddress])
    {
        return NO;
    }
    
    if (![self isString:_resource equalToString:otherAddress.resource])
    {
        return NO;
    }
    
    return YES;
}


- (BOOL)isEqualToCommunicationAddressIgnoringResource:(CommunicationAddress*)otherAddress
{
    if (![self isString:_routeAddress equalToString:otherAddress.routeAddress])
    {
        return NO;
    }
    
    if (_contactID == nil)
    {
        if (otherAddress.contactID != nil)
        {
            return NO;
        }
    }
    else
    {
        if (otherAddress.contactID == nil)
        {
            return NO;
        }
        
        if (![_contactID isEqualToContactID:otherAddress.contactID])
        {
            return NO;
        }
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
