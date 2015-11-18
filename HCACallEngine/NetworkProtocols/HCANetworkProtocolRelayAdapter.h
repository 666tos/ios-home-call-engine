//
//  HCANetworkProtocolRelayAdapter.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/5/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetworkProtocolRelay.h"

@class HCXXMPPController;

@interface HCANetworkProtocolRelayAdapter : NSObject <NetworkProtocolRelay>

/*
 You can set xmpp controller that will be used to send stanzas. This can be useful for unit-testing. By default [HCXXMPPController defaultXMPPController] is used.
 */
@property (strong, nonatomic) HCXXMPPController *xmppController;

@property (strong, nonatomic, readonly) dispatch_queue_t relayEventObserverQueue;

- (instancetype)initWithRelayEventObserverQueue:(dispatch_queue_t)relayEventObserverQueue;

@end
