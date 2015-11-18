//
//  HCACallJingleControllerTests.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 4/8/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#ifndef HomeCenter_HCACallJingleControllerTests_h
#define HomeCenter_HCACallJingleControllerTests_h

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <HCACallEngine/HCACallEngine.h>
#import <HomeCenterXMPP/HomeCenterXMPP.h>
#import <HCACallEngine/HCACallJingleCantroller+Internal.h>

#import <OCMock/OCMock.h>
#import "HCATestNetworkProtocolRelayAdapter.h"

@interface HCACallJingleControllerTests : XCTestCase <HCACallCantrollerListener>

@property (strong, nonatomic) HCACallJingleCantroller *callController;
@property (strong, nonatomic) HCXXMPPController *xmppController;

@property (strong, nonatomic) NSString *contactJid;

//Methods to override
- (BOOL)jingleIqWillBeSent:(XMPPIQ *)iq;

@end

#endif
