//
//  ContactID.h
//  iO
//
//  Created by Joost de Moel on 4/4/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Something that identifies a contact, being a normalized phonenumber and/or a corresponding UCID jid
 * Note that we should NEVER send anything to the UCID jid. It's only used as a contact identifier.
 */
@interface ContactID : NSObject<NSCopying>

@property (nonatomic, readonly) NSString *  normalizedPhoneNumber;      // May be nil!
@property (nonatomic, readonly) NSString *  ucidJid;                    // May be nil!

// Initialization
- (id)initWithUcidJid:(NSString*)ucidJid;
- (id)initWithNormalizedPhoneNumber:(NSString*)phoneNumber;
- (id)initWithNormalizedPhoneNumber:(NSString*)phoneNumber withUcidJid:(NSString*)ucidJid;
- (id)initFromDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)toDictionary;

// Overwritten NSObject methods
- (BOOL)isEqual:(id)anObject;
- (NSUInteger)hash;

// Other public methods
- (BOOL)isEqualToContactID:(ContactID*)otherContactID;

@end
