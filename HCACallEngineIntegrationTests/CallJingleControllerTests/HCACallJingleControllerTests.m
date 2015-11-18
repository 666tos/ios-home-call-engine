//
//  HCACallJingleControllerTests.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 3/2/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//
#import "HCACallJingleControllerTests.h"

@implementation HCACallJingleControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Properties

- (HCACallJingleCantroller *)callController
{
    if (!_callController)
    {
//        TestVoiceEngine
        HCACallJingleCantroller *callController = [HCACallJingleCantroller alloc];
        HCACallJingleCantroller *callControllerMock = OCMPartialMock(callController);
        
        [OCMStub([callControllerMock mediaEngineClass]) andReturn:[TestVoiceEngine class]];
        [OCMStub([callControllerMock xmppBlockDispatcherClass]) andReturn:[HCATestXMPPDataBlockDispatcher class]];
        [OCMStub([callControllerMock relayProtocolClass]) andReturn:[HCATestNetworkProtocolRelayAdapter class]];
        
        [OCMStub([callControllerMock fullJidCurrentUser]) andReturn:@"unit_test@homecenter.com/test"];
        
        _callController = [callControllerMock initWithXMPPController:self.xmppController];
        _callController.listener = self;
        
        __weak typeof(self) weakSelf = self;
        [(HCATestXMPPDataBlockDispatcher *)_callController.blockDispatcherAdapter setIqSendingHook:^BOOL(XMPPIQ *iq)
        {
            return [weakSelf jingleIqWillBeSent:iq];
        }];
    }
    return _callController;
}

- (HCXXMPPController *)xmppController
{
    if (!_xmppController)
    {
        _xmppController = [HCXXMPPController defaultXMPPController];
    }
    return _xmppController;
}

#pragma mark - Mocks 



#pragma mark - HCACallCantrollerListener

- (void)callControllerStateWillChange:(HCACallJingleCantroller *)controller onState:(HCACallState)newState
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callControllerStateDidChange:(HCACallJingleCantroller *)controller
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller didReceiveIncomingCall:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller callWasMissed:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller contactDidStartRinging:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller callDidAccept:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller callDidReject:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller callDidTerminate:(HCACallInfo *)callInfo error:(NSError *)error
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller mediaControllerWasCreated:(HCACallMediaContentController *)mediaContentController
               forCall:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}


- (void)callController:(HCACallJingleCantroller *)controller callWasHeld:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callController:(HCACallJingleCantroller *)controller callWasUnheld:(HCACallInfo *)callInfo
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

#pragma mark - IQ sending

- (BOOL)jingleIqWillBeSent:(XMPPIQ *)iq
{
    return YES;
}

@end
