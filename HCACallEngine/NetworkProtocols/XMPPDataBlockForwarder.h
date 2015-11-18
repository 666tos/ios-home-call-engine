//
//  XMPPDataBlockForwarder.h
//  iO
//
//  Created by Oleksiy Radyvanyuk on 26/03/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPListenerProtocols.h"

@protocol XMPPDataBlockForwarderProtocol

/**
 * Registers a listener to forwarded XMPP stanzas of a certain type
 * @param listener the listener to receive callbacks
 * @param type the namespace of forwarded xmpp stanzas to listen to
 */
- (void)addForwardedStanzaListener:(NSObject<XMPPForwardedStanzaListener> *)listener forStanzasOfType:(NSString *)type;

/**
 * Registers a listener to forwarded XMPP IQ stanzas of type 'set' of 'get'
 * @param listener the listener to receive callbacks
 * @param stanzaNamespace the namespace to match in the first child node of the received IQ stanza.
 * @note forwarded stanzas with a matching namespace but added subname (like: #something) are also matched UNLESS 'stanzaNamespace'
 * itself contains a non-matching subname
 */
- (void)addForwardedIqQueryListener:(NSObject<XMPPForwardedIqQueryListener> *)listener forStanzasWithNamespace:(NSString *)stanzaNamespace;

/**
 * Determines which of the registered listeners should handle the forwarded data block
 * @param element the data block that was wrapped inside the <forwarded> element
 * @param wrapper the data block that contains the <forwarded> element
 */
- (void)handleForwardedDataBlock:(XMPPDataBlock *)element wrappedInElement:(XMPPDataBlock *)wrapper;

@end


/**
 * Responsible for receiving forwarded XMPP data blocks, and passing them to listeners
 */
@interface XMPPDataBlockForwarder : NSObject <XMPPDataBlockForwarderProtocol>

@end
