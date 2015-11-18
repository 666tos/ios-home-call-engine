//
//  HCANetworkProtocolRelayAdapter.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/5/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "HCANetworkProtocolRelayAdapter.h"

#import <HomeCenterXMPP/HomeCenterXMPP.h>

@interface HCANetworkProtocolRelayAdapter () <XMPPJingleRelayNodesDelegate>

@property (strong, nonatomic) NSMutableDictionary *requestIdByObserverArgument;
@property (weak, nonatomic) NSObject<RelayEventObserver>* relayEventObserver;

@property (strong, nonatomic) dispatch_queue_t relayEventObserverQueue;

@end

@implementation HCANetworkProtocolRelayAdapter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.relayEventObserverQueue = dispatch_get_main_queue();
    }
    return self;
}

- (instancetype)initWithRelayEventObserverQueue:(dispatch_queue_t)relayEventObserverQueue
{
    self = [super init];
    if (self)
    {
        self.relayEventObserverQueue = relayEventObserverQueue;
    }
    return self;
}

- (void)registerRelayEventObserver:(NSObject<RelayEventObserver>*)observer
{
    [self.xmppController.jingleRelayModule removeDelegate:self delegateQueue:self.relayEventObserverQueue];
    [self.xmppController.jingleRelayModule addDelegate:self delegateQueue:self.relayEventObserverQueue];
    self.relayEventObserver = observer;
}

- (BOOL)sendRelayRequestForObserver:(NSObject<RelayRequestResponseObserver>*)observer withObserverArgument:(NSObject*)observerArgument
{
    @synchronized(self)
    {
        XMPPJingleRelayNodes *relayModule = [self.xmppController jingleRelayModule];
        
        NSString *relayRequestId = [relayModule sendUdpChannelRequestWithTimeout:1000 completionHandler:^(XMPPJingleNodeChannel *channel, NSError *error)
                                    {
                                        if (channel)
                                        {
                                            [observer handleRelayResponseWithIpAddress:channel.host withLocalPort:channel.localPort withRemotePort:channel.remotePort withChannelID:channel.channelId withObserverArgument:observerArgument];
                                        }
                                    }];
        
        id<NSCopying> observerArgumentKey = [self observerArgumentKeyWithobserverArgument:observerArgument];
        if (observerArgumentKey)
        {
            self.requestIdByObserverArgument[observerArgumentKey] = relayRequestId;
        }
    }
    return YES;
}

- (void)removeRelayRequestObserver:(NSObject<RelayRequestResponseObserver>*)observer withObserverArgument:(NSObject*)observerArgument
{
    @synchronized(self)
    {
        id<NSCopying> observerArgumentKey = [self observerArgumentKeyWithobserverArgument:observerArgument];
        NSString *relayRequestId = self.requestIdByObserverArgument[observerArgumentKey];
        [[self.xmppController jingleRelayModule] cancelRequestWithId:relayRequestId];
    }
}

#pragma mark - XMPPJingleRelayNodesDelegate

- (void)xmppRelayNodesModule:(XMPPJingleRelayNodes *)module channelWithIdWasKilled:(NSString *)channelId
{
    [self.relayEventObserver handleRelayChannelKilled:channelId];
}

#pragma mark - Utils

- (id<NSCopying>)observerArgumentKeyWithobserverArgument:(NSObject *)observerArgument
{
    id<NSCopying> observerArgumentKey = nil;
    if ([observerArgument conformsToProtocol:@protocol(NSCopying)])
    {
        observerArgumentKey = (id<NSCopying>)observerArgument;
    }
    
    return observerArgumentKey;
}

#pragma mark - Properties

- (HCXXMPPController *)xmppController
{
    if (!_xmppController)
    {
        _xmppController = [HCXXMPPController defaultXMPPController];
    }
    return _xmppController;
}

- (NSMutableDictionary *)requestIdByObserverArgument
{
    if (_requestIdByObserverArgument)
    {
        _requestIdByObserverArgument = [NSMutableDictionary new];
    }
    return _requestIdByObserverArgument;
}

@end
