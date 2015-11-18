//
//  HCACallJingleControllerDialingTests.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 4/8/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "HCACallJingleControllerTests.h"

@interface HCACallJingleControllerDialingTests : HCACallJingleControllerTests

@property (strong, nonatomic) XCTestExpectation *dialingStateExpectation;
@property (nonatomic) NSInteger jingleSessionId;

@end

@implementation HCACallJingleControllerDialingTests

- (void)testDialing
{
    self.dialingStateExpectation = [self expectationWithDescription:@"dialingStateExpectation"];
    
    self.contactJid = @"test@jid.com/test";
    [self.callController callContactWithJid:self.contactJid callOptions:HCACallOptionsDefault];
    
    [self waitForExpectationsWithTimeout:150. handler:^(NSError *error)
    {
        
    }];
}

- (void)callControllerStateWillChange:(HCACallJingleCantroller *)controller onState:(HCACallState)newState
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
}

- (void)callControllerStateDidChange:(HCACallJingleCantroller *)controller
{
    NSLog(@"---  %@", NSStringFromSelector(_cmd));
    
    if (controller.callState == HCACallStateOutgoingCallRinging)
    {
        [self.dialingStateExpectation fulfill];
    }
}



#pragma mark - Jingle IQ sending

- (BOOL)jingleIqWillBeSent:(XMPPIQ *)iq
{
    NSString *jingleAction = [[[iq elementForName:@"jingle"] attributeForName:@"action"] stringValue];
    if ([jingleAction  isEqualToString:@"session-initiate"])
    {
        self.jingleSessionId = [[[[iq elementForName:@"jingle"] attributeForName:@"sid"] stringValue] integerValue];
        [self simulateAcknowlegeReceiving];
    }
    
    return YES;
}

- (void)simulateAcknowlegeReceiving
{
    NSString *iqString = [NSString stringWithFormat:@"<iq type='set' to='%@' from='%@' id='%u'>\
     <jingle xmlns='urn:xmpp:jingle:1' action='session-info' initiator='%@' sid='%ld' responder='%@'>\
     <ringing xmlns='urn:xmpp:jingle:apps:rtp:info:1'/>\
     </jingle>\
     </iq>", self.callController.fullJidCurrentUser, self.contactJid, arc4random(), self.callController.fullJidCurrentUser, (long)self.jingleSessionId, self.contactJid];
    
    XMPPIQ *acknowlegeIq = [[XMPPIQ alloc] initWithXMLString:iqString error:nil];
    
    [(HCATestXMPPDataBlockDispatcher *)self.callController.blockDispatcherAdapter notifyListenerIfNeedWithIQ:acknowlegeIq];
}

@end
