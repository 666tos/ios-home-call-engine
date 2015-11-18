//
//  HCACallEngineIntegrationTests.m
//  HCACallEngineIntegrationTests
//
//  Created by Maxim Malyhin on 2/5/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "HCABaseJinglePhoneIntegrationTest.h"

@interface HCACallEngineIntegrationTests : HCABaseJinglePhoneIntegrationTest

@property (strong, nonatomic) XCTestExpectation *incomingCallExpectation;
@property (strong, nonatomic) XCTestExpectation *callAcceptedExpectation;
@property (nonatomic) NSInteger callID;

@end

@implementation HCACallEngineIntegrationTests



- (void)testCallFromClient1ToClient2
{
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Clients initialized"];
    
    [self initializeJingleClientsWithCompletionHandler:^(id result)
    {
        XCTAssertNotNil(result);
        
        if (result)
        {
            NSLog(@"Registered users: %@", result);
            
            XMPPJID *jid2 = self.jinglePhone2.xmppController.xmppStream.myJID;
        
            [self.jinglePhone1 updateJingleIP];
            [self.jinglePhone2 updateJingleIP];
            
            self.callID = [self.jinglePhone1.jinglePhone callUserWithJid:[jid2 full] withCurrentUserPhoneNumber:[jid2 full] withGateway:JingleGatewayRelayedVideo];
            
            self.incomingCallExpectation = [self expectationWithDescription:@"Incoming call from client 1"];
            self.callAcceptedExpectation = [self expectationWithDescription:@"Call accepted "];
            
            [self waitForExpectationsWithTimeout:60 handler:^(NSError *error)
            {
                NSLog(@"!!!Error: %@", error);
            }];
        }
    }];
}


#pragma mark - JinglePhoneListener
- (void)handleIncomingCallWithInfo:(JingleIncomingCallInfo *)incomingCallInfo
{
    NSLog(@"--- %@", NSStringFromSelector(_cmd));
    
    if ([[self.jinglePhone1.xmppController.xmppStream.myJID full] containsString:incomingCallInfo.communicationAddress.contactID.ucidJid])
    {
        [self.incomingCallExpectation fulfill];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           BOOL audioSrtpEnabled;
                           BOOL videoSrtpEnabled;
                           
                           BOOL success = [self.jinglePhone2.jinglePhone acceptCallWithID:incomingCallInfo.callID withAudioSrtpEnabled:&audioSrtpEnabled withVideoSrtpEnabled:&videoSrtpEnabled withForceAudio:NO];
                           
                           XCTAssert(success, @"Could not accept the call");
                       });
        
    }
}

- (void)handleCallAnsweredWithID:(NSInteger)callID withServerTimestamp:(NSDate*)serverTimestamp withAudioSrtpEnabled:(BOOL)audioSrtpEnabled withVideoSrtpEnabled:(BOOL)videoSrtpEnabled withVideoEnabled:(BOOL)videoEnabled
{
    [super handleCallAnsweredWithID:callID withServerTimestamp:serverTimestamp withAudioSrtpEnabled:audioSrtpEnabled withVideoSrtpEnabled:videoSrtpEnabled withVideoEnabled:videoEnabled];
    
    if (callID == self.callID)
    {
        [self.callAcceptedExpectation fulfill];
    }
}

@end
