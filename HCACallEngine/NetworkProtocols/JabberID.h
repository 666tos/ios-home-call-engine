/*
 *--------------------------------------------------------------------------------------------------
 * Filename: JabberID.h
 *--------------------------------------------------------------------------------------------------
 *
 * Revision History:
 *
 *                             Modification     Tracking
 * Author                      Date             Number       Description of Changes
 * --------------------        ------------     ---------    ----------------------------------------
 * Roman Alarcon               2008-07-28                    File Created.
 * Roman Alarcon               2008-08-01                    Modified.
 *
 * Copyright (c) 2008 NGT International B.V. All rights reserved.
 */

/**
 * General Description:
 * This file provides the declaration of class JabberID.
 *
 * @author Roman Alarcon
 */

#import <Foundation/Foundation.h>

#import <HomeCenterXMPP/HomeCenterXMPP.h>

@interface JabberID : NSObject

- (id)init;
- (id)initWithJID:(NSString *)jid;
- (id)initWithUser:(NSString *)user domain:(NSString *)domain resource:(NSString *)resource;

- (void)dealloc;

+ (id)jabberIDWithJidString:(NSString *)jidString;
+ (NSString*)getUserFromJidString:(NSString*)jidString;
+ (NSString*)getJidWithUser:(NSString*)user withDomain:(NSString*)domain;

- (NSString *)getUser;
- (NSString *)getDomain;

- (NSString *)getResourceName;
- (void)setResource:(NSString *)resource;

- (NSString *)getJIDString;
- (NSString *)getBareJIDString;

- (NSString *)description;

@end
