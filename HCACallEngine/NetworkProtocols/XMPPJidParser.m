//
//  XMPPJidParser.m
//  NGT International B.V.
//
//  Created by Joost de Moel on 12/14/12.
//  Copyright (c) 2012 NGTI. All rights reserved.
//

#import "XMPPJidParser.h"

#import "Common.h"

#define kUriPrefixPhone             @"phone"
#define kUriPrefixUcid              @"ucid"
#define kUriPrefixJid               @"jid"

@implementation XMPPJidParser


/**
 * Parses the given jid and puts the barejid in outNode and the resource in outResource
 */
+ (void)getBareJidAndResourceFromJid:(NSString*)jid intoBareJid:(NSString**)outNode intoResource:(NSString**)outResource
{
    NSRange range = [jid rangeOfString:@"/"];
    if (range.location != NSNotFound)
    {
        *outNode = [[jid substringToIndex:range.location] copy];
        
        if (range.location + 1 < jid.length)
        {
            *outResource = [[jid substringFromIndex:range.location + 1] copy];
        }
    }
    else
    {
        *outNode = [jid copy];
        *outResource = nil;
    }
}



+ (BOOL)getTypeAndAddressFromUri:(NSString*)responder intoType:(AddressType*)outType intoAddress:(NSString**)outAddress
{
    NSRange range = [responder rangeOfString:@":"];
    if (range.location != NSNotFound && range.location + 1 < responder.length)
    {
        NSString* prefix        = [responder substringToIndex:range.location];
        NSString* address       = [responder substringFromIndex:range.location + 1];
        
        if ([prefix isEqualToString:kUriPrefixPhone])
        {
            *outType = AddressTypePhoneNumber;
        }
        else if ([prefix isEqualToString:kUriPrefixUcid])
        {
            *outType = AddressTypeUcid;
        }
        else if ([prefix isEqualToString:kUriPrefixJid])
        {
            *outType = AddressTypeJid;
        }
        else
        {
            ELOG(DEFAULT, "Error: unknown uri prefix: %@", prefix);
            return NO;
        }
        
        *outAddress = address;
        return YES;
    }
    
    return NO;
}


/**
 * Constructs an URI to be used in server communication
 * @param prefixType the type of prefix, describing the context of the address
 * @param address the address to be put in the uri
 */
+ (NSString*)constructUriWithPrefix:(AddressType)prefixType andAddress:(NSString*)address
{
    NSString* prefixString = nil;
    
    switch (prefixType)
    {
        case AddressTypePhoneNumber:
            prefixString = kUriPrefixPhone;
            break;
            
        case AddressTypeUcid:
            prefixString = kUriPrefixUcid;
            break;
            
        case AddressTypeJid:
            prefixString = kUriPrefixJid;
            break;
    }
    
    return [NSString stringWithFormat:@"%@:%@", prefixString, address];
}

@end
