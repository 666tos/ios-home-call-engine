//
//  HCATestXMPPDataBlockDispatcher.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 3/2/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "HCATestXMPPDataBlockDispatcher.h"
#import "XMPPDataBlockDispatcher+HCATesting.h"

@implementation HCATestXMPPDataBlockDispatcher

- (BOOL)notifyListenerIfNeedWithIQ:(XMPPIQ *)iq
{
    return [super notifyListenerIfNeedWithIQ:iq];
}

- (BOOL)setIDAndSendIQBlock:(XMPPIQ*)iqBlock
            withRequestType:(NSUInteger)requestType
                 ofProtocol:(XMPPProtocolBase*)protocol
       withProtocolObserver:(NSObject*)observer
       withObserverArgument:(NSObject*)observerArgument
         offlineQueuePolicy:(OfflineQueuePolicy)queuePolicy
{
    NSLog(@"%@ block will send: %@", NSStringFromClass([self class]), [iqBlock XMLStringWithOptions:DDXMLNodePrettyPrint]);
    
    if (self.iqSendingHook)
    {
        return self.iqSendingHook(iqBlock);
    }
    
    return YES;
}

@end
