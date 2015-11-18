//
//  CommunicationAddress.h
//  NGT International B.V.
//
//  Created by Joost de Moel on 11/26/12.
//  Copyright (c) 2012 NGT International. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContactID.h"

/**
 * Represents a communication address, an address for communication with a certain contact
 * 
 * A phone number may have or may not have a UCID jid associated. This information is contained in the 'contactID' property.
 * When starting communication with a contact however, we use 'routing jids' which can be different to the UCID jids.
 * These 'routing jids' are contained in the 'routeAddress' property of this class.
 *
 * An address can be a barejid, a fulljid or just a phonenumber in case we start a cellular call for example.
 *
 * CommunicationAddress objects can be used as key in dictionaries.
 * Two CommunicationAddress objects are only equal if ALL of their properties are equal
 */
@interface CommunicationAddress : NSObject<NSCopying>

@property (nonatomic, readonly) ContactID * contactID;      // identifies the contact to which is address belongs

@property (nonatomic, readonly) NSString *  routeAddress;   // address of communication. Usually a (bare)jid, but can also be just a phonenumber
@property (nonatomic, readonly) NSString *  resource;       // resource if 'routeAddress' is a jid. Can be nil if we don't know the full jid

// Initialization
- (id)initWithContactID:(ContactID*)contactID withAddress:(NSString*)routeAddress withResource:(NSString*)resource;
- (id)initFromDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)toDictionary;

- (CommunicationAddress*)copyWithoutResource;

+ (CommunicationAddress*)communicationAddressWithFromJid:(NSString*)jid withAlternativeFrom:(NSString*)altFromJid;

// Overwritten NSObject methods
- (BOOL)isEqual:(id)anObject;
- (NSUInteger)hash;

// Other public methods
- (BOOL)isEqualToCommunicationAddress:(CommunicationAddress*)otherAddress;
- (BOOL)isEqualToCommunicationAddressIgnoringResource:(CommunicationAddress*)otherAddress;

@end
