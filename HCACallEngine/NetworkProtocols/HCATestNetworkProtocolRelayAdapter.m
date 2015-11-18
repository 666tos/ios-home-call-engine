//
//  HCATestNetworkProtocolRelayAdapter.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 4/22/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "HCATestNetworkProtocolRelayAdapter.h"

@implementation HCATestNetworkProtocolRelayAdapter

- (BOOL)sendRelayRequestForObserver:(NSObject<RelayRequestResponseObserver>*)observer withObserverArgument:(NSObject*)observerArgument
{
    @synchronized(self)
    {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_current_queue(), ^
        {
            [observer handleRelayResponseWithIpAddress:@"127.0.0.1"
                                         withLocalPort:1111
                                        withRemotePort:2222
                                         withChannelID:@"HCATestNetworkProtocolRelayAdapter.channelId"
                                  withObserverArgument:observerArgument];
        });
    }
    return YES;
}

@end
