//
//  XMPPDataBlockDispatcher+HCATesting.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 3/2/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "XMPPDataBlockDispatcher.h"

@interface XMPPDataBlockDispatcher (HCAUnitTesting)

- (BOOL)notifyListenerIfNeedWithIQ:(XMPPIQ *)iq;

@end


