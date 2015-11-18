//
//  XMPPListenerProtocols.h
//  iO
//
//  Created by Oleksiy Radyvanyuk on 26/03/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <HomeCenterXMPP/HomeCenterXMPP.h>

#import "XMPPConstants.h"
#import "XMPPProtocolBase.h"

typedef enum
{
    EXmppIqTypeUnknown,
    EXmppIqTypeSet,
    EXmppIqTypeGet,
    EXmppIqTypeResult,
    EXmppIqTypeError
} XMPPIQType;

@class XMPPDataBLock;

/**
 * A delegate that will receive ALL incoming XMPP stanzas of a certain type for which the delegate registered itself
 */
@protocol XMPPStanzaListener

/**
 * @return YES if the delegate handled the XMPP stanza (if so it will not be sent to other listeners)
 */
- (BOOL)handleReceivedXMPPStanza:(XMPPDataBlock*)dataBlock;

@end


/**
 * A delegate that will receive ALL incoming XMPP stanzas of type 'iq' of type 'set' of 'get'
 * Replies to IQs we sent to the server are not passed here
 */
@protocol XMPPIqQueryListener

/**
 * @param iqBlock the received stanza
 * @param type the IQ type, based on the attribute of the IQ block, SHOULD be EXmppIqTypeSet or EXmppIqTypeGet
 * @param matchedNamespace the namespace that was found in this stanza, which the listener passed when calling addIncomingIqQueryListener:forStanzasWithNamespace:
 * @param childNode the child node of 'iqBlock' in which the matching namespace was found
 * @return YES if the delegate handled the XMPP message (if so it will not be sent to other listeners)
 */
- (BOOL)handleReceivedXMPPIqQueryBlock:(XMPPDataBlock*)iqBlock ofType:(XMPPIQType)type withNamespace:(NSString*)matchedNamespace ofChildNode:(XMPPDataBlock*)childNode;

@end


/**
 * A delegate that will receive ALL forwarded XMPP stanzas of a certain type for which the delegate registered itself
 */
@protocol XMPPForwardedStanzaListener

/**
 * @return YES if the delegate handled the XMPP stanza (if so it will not be sent to other listeners)
 */
- (BOOL)handleForwardedXMPPStanza:(XMPPDataBlock *)dataBlock;

@end


/**
 * A delegate that will receive ALL forwarded XMPP stanzas of type 'iq' of type 'set' of 'get'
 * Replies to IQs we sent to the server are not passed here
 */
@protocol XMPPForwardedIqQueryListener
/**
 * @param iqBlock the forwarded stanza
 * @param type the IQ type, based on the attribute of the IQ block, SHOULD be EXmppIqTypeSet or EXmppIqTypeGet
 * @param matchedNamespace the namespace that was found in this stanza, which the listener passed when calling addForwardedIqQueryListener:forStanzasWithNamespace:
 * @param childNode the child node of 'iqBlock' in which the matching namespace was found
 * @return YES if the delegate handled the XMPP message (if so it will not be sent to other listeners)
 */
- (BOOL)handleForwardedXMPPIqQueryBlock:(XMPPDataBlock *)iqBlock ofType:(XMPPIQType)type withNamespace:(NSString *)matchedNamespace ofChildNode:(XMPPDataBlock *)childNode;

@end
