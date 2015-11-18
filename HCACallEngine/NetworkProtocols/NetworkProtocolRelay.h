//
//  NetworkProtocolRelay.h
//  iO
//
//  Created by Joost de Moel on 9/2/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

@protocol RelayRequestResponseObserver

/**
 * Notify listener that relay candidate arrived.
 */
- (void)handleRelayResponseWithIpAddress:(NSString*)ipAddress withLocalPort:(NSInteger)localPort withRemotePort:(NSInteger)remotePort withChannelID:(NSString*)channelID withObserverArgument:(NSObject*)observerArgument;

@end

@protocol RelayEventObserver

/**
 * Called when the relay channel with the given ID is killed
 */
- (void)handleRelayChannelKilled:(NSString*)channelID;

@end

@protocol NetworkProtocolRelay

- (void)registerRelayEventObserver:(NSObject<RelayEventObserver>*)observer;

/**
 * Send relay request to server.
 * Server should respond to observer with an ip and 2 ports (for sending and receiving).
 */
- (BOOL)sendRelayRequestForObserver:(NSObject<RelayRequestResponseObserver>*)observer withObserverArgument:(NSObject*)observerArgument;

- (void)removeRelayRequestObserver:(NSObject<RelayRequestResponseObserver>*)observer withObserverArgument:(NSObject*)observerArgument;

@end