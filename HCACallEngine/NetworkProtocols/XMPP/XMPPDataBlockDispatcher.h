/*
 * Copyright 2013 NGT International B.V. All rights reserved.
 */

#import <Foundation/NSObject.h>

#import "XMPPProtocol.h"
#import "XMPPConstants.h"

#import "NSStringExtended.h"

#import "XMPPListenerProtocols.h"



@class XMPPRequestInfo;
@class XMPPProtocolBase;
@class SessionController;
@class HCXXMPPModule;

/**
 * Responsible for queuing, sending and receiving XMPP data blocks, and passing them to listeners
 */
@interface XMPPDataBlockDispatcher : HCXXMPPModule //<XMPPProtocol>

- (instancetype)initWithXMPPController:(HCXXMPPController *)xmppController listenerQueue:(dispatch_queue_t)queue;

@property (strong, nonatomic, readonly) HCXXMPPController *xmppController;

- (void)installProtocol:(XMPPProtocolBase*)protocol;

/*
 There can be only one listener in current implementation. An old listener will be replaced by a new one
 */
- (void)addIncomingIqQueryListener:(NSObject<XMPPIqQueryListener>*)listener forStanzasWithNamespace:(NSString*)stanzaNamespace;

/**
 * Registers a listener to forwarded XMPP IQ stanzas of type 'set' of 'get'
 * @param listener the listener to receive callbacks
 * @param stanzaNamespace the namespace to match in the first child node of the received IQ stanza.
 * @note forwarded stanzas with a matching namespace but added subname (like: #something) are also matched UNLESS 'stanzaNamespace'
 * itself contains a non-matching subname
 */
- (void)addForwardedIqQueryListener:(NSObject<XMPPForwardedIqQueryListener> *)listener forStanzasWithNamespace:(NSString *)stanzaNamespace;

- (BOOL)setIDAndSendIQBlock:(XMPPIQ*)iqBlock
            withRequestType:(NSUInteger)requestType
                 ofProtocol:(XMPPProtocolBase*)protocol
       withProtocolObserver:(NSObject*)observer
       withObserverArgument:(NSObject*)observerArgument
         offlineQueuePolicy:(OfflineQueuePolicy)queuePolicy;

- (BOOL)sendXMPPDataBlock:(XMPPDataBlock *)dataBlock;


@end

