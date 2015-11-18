//
//  XMPPJidParser.h
//  NGT International B.V.
//
//  Created by Joost de Moel on 12/14/12.
//  Copyright (c) 2012 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    AddressTypePhoneNumber,     // a phonenumber, like +430291912
    AddressTypeUcid,            // a UCID jid,   like helpbot@ucid.ch
    AddressTypeJid              // a jid which is NOT a UCID jid, like phonenumber@sip.ucid.ch
} AddressType;

@interface XMPPJidParser : NSObject

+ (void)getBareJidAndResourceFromJid:(NSString*)jid intoBareJid:(NSString**)outNode intoResource:(NSString**)outResource;

+ (BOOL)getTypeAndAddressFromUri:(NSString*)responder intoType:(AddressType*)outType intoAddress:(NSString**)outAddress;
+ (NSString*)constructUriWithPrefix:(AddressType)prefixType andAddress:(NSString*)address;

@end
