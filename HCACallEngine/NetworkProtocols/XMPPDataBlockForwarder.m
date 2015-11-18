//
//  XMPPDataBlockForwarder.m
//  iO
//
//  Created by Oleksiy Radyvanyuk on 26/03/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "XMPPDataBlockForwarder.h"
#import "SafeMutableDictionary.h"
#import "Common.h"
#import "XMPPStrings.h"

@interface XMPPDataBlockForwarder ()

/**
 * Listeners to forwarded XMPP IQ stanzas of type 'set' of 'get'
 * KEYS: namespace for IQ stanzas to match (NSString)
 * OBJECTS: NSMutableArray of NSObject<XMPPForwardedIqQueryListener>
 */
@property (nonatomic, retain) SafeMutableDictionary *iqQueryListeners;

@end

@implementation XMPPDataBlockForwarder

- (id)init
{
    if ((self = [super init]))
    {
        _iqQueryListeners = [[SafeMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    self.iqQueryListeners = nil;
}

- (void)addForwardedStanzaListener:(NSObject<XMPPForwardedStanzaListener> *)listener forStanzasOfType:(NSString *)type
{
    // TBD in next releases
    WLOG(DEFAULT, "Unsupported: cannot add forwarded stanza listener %@ for namespace %@", listener, type);
}

- (void)addForwardedIqQueryListener:(NSObject<XMPPForwardedIqQueryListener> *)listener forStanzasWithNamespace:(NSString *)stanzaNamespace
{
    if (nil != stanzaNamespace)
    {
        NSMutableArray *array = [self.iqQueryListeners objectForKey:stanzaNamespace];
        if (array == nil)
        {
            array = [NSMutableArray arrayWithCapacity:1];
            [self.iqQueryListeners setObject:array forKey:stanzaNamespace];
        }

        [array addObject:listener];
    }
}

- (void)handleForwardedIQQueryDataBlock:(DDXMLElement *)element ofType:(XMPPIQType)type wrappedInElement:(XMPPDataBlock *)wrapper
{
    // Received an IQ query from the server
    // See if there's any listeners that want to receive this IQ query

    for (XMPPDataBlock *child in [element children])
    {
        NSString *namespace = [child xmlns];
        
        NSArray *listeners = [self.iqQueryListeners objectForKey:namespace];
        if ([listeners count] > 0)
        {
            for (NSObject<XMPPForwardedIqQueryListener> *listener in listeners)
            {
                if ([listener handleForwardedXMPPIqQueryBlock:element ofType:type withNamespace:namespace ofChildNode:child])
                {
                    return;
                }
            }
        }
        
        NSRange range = [namespace rangeOfString:@"#"];
        if (range.location != NSNotFound)
        {
            NSString *namespaceWithoutSubname = [namespace substringToIndex:range.location];
            
            if ([namespaceWithoutSubname length] > 0)
            {
                listeners = [self.iqQueryListeners objectForKey:namespaceWithoutSubname];
                if ([listeners count] > 0)
                {
                    for (NSObject<XMPPForwardedIqQueryListener> *listener in listeners)
                    {
                        if ([listener handleForwardedXMPPIqQueryBlock:element ofType:type withNamespace:namespaceWithoutSubname ofChildNode:child])
                        {
                            return;
                        }
                    }
                }
            }
        }
    }
}

- (void)handleForwardedIQDataBlock:(XMPPDataBlock *)element wrappedInElement:(XMPPDataBlock *)wrapper
{
    NSString *typeStr = [element getAttribute:kAttributeType];
    NSString *iqID    = [element getAttribute:kAttributeId];

    if (typeStr != nil && iqID != nil)
    {
        XMPPIQType type = EXmppIqTypeUnknown;
        
        if ([typeStr isEqualToString:kValueError])
        {
            type = EXmppIqTypeError;
        }
        else if ([typeStr isEqualToString:kValueResult])
        {
            type = EXmppIqTypeResult;
        }
        else if ([typeStr isEqualToString:kValueSet])
        {
            type = EXmppIqTypeSet;
        }
        else if ([typeStr isEqualToString:kValueGet])
        {
            type = EXmppIqTypeGet;
        }

        if (type == EXmppIqTypeSet || type == EXmppIqTypeGet)
        {
            [self handleForwardedIQQueryDataBlock:element ofType:type wrappedInElement:wrapper];
        }
        else
        {
            // TBD in next releases
            WLOG(DEFAULT, "Unsupported: cannot forward IQ stanza of type '%@':\n%@", typeStr, wrapper);
        }
    }
}

- (void)handleForwardedNonIQDataBlock:(XMPPDataBlock *)element wrappedInElement:(XMPPDataBlock *)wrapper
{
    // TBD in next releases
    WLOG(DEFAULT, "Unsupported: cannot handle forward %@", wrapper);
}

- (void)handleForwardedDataBlock:(XMPPDataBlock *)element wrappedInElement:(XMPPDataBlock *)wrapper
{
    if ([element isEqualToType:XMPP_IQ])
    {
        [self handleForwardedIQDataBlock:element wrappedInElement:wrapper];
    }
    else
    {
        [self handleForwardedNonIQDataBlock:element wrappedInElement:wrapper];
    }
}

@end
