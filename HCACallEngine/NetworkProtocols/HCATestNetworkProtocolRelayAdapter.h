//
//  HCATestNetworkProtocolRelayAdapter.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 4/22/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <HCACallEngine/HCACallEngine.h>

@interface HCATestNetworkProtocolRelayAdapter : HCANetworkProtocolRelayAdapter

//Overridden methods
- (BOOL)sendRelayRequestForObserver:(NSObject<RelayRequestResponseObserver>*)observer withObserverArgument:(NSObject*)observerArgument;

@end
