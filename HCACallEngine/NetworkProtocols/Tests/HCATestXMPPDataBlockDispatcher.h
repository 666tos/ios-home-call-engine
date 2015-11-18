//
//  HCATestXMPPDataBlockDispatcher.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 3/2/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPDataBlockDispatcher.h"


@interface HCATestXMPPDataBlockDispatcher : XMPPDataBlockDispatcher

@property (copy, nonatomic) BOOL(^iqSendingHook)(XMPPIQ *iqBlock);

/*
 The method can be used to send stanzas to listeners if it feets
 */
- (BOOL)notifyListenerIfNeedWithIQ:(XMPPIQ *)iq;


/*
 The method overrided to empty implementation (return YES).
 */
- (BOOL)setIDAndSendIQBlock:(XMPPIQ*)iqBlock
            withRequestType:(NSUInteger)requestType
                 ofProtocol:(XMPPProtocolBase*)protocol
       withProtocolObserver:(NSObject*)observer
       withObserverArgument:(NSObject*)observerArgument
         offlineQueuePolicy:(OfflineQueuePolicy)queuePolicy;

@end


