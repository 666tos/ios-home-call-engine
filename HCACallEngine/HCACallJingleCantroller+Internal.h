//
//  HCACallJingleCantroller+Internal.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 4/8/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <HCACallEngine/HCACallEngine.h>
#import <HCACallEngine/HCACallControllerStatesDescription.h>

@interface HCACallJingleCantroller (Internal)

@property (strong, nonatomic, readonly) LinphoneVoiceEngine *mediaEngine;
@property (strong, nonatomic, readonly) XMPPDataBlockDispatcher *blockDispatcherAdapter;

/*
 Input method for state machine.
 @param event
 @param transitionContext An object that will be passed to state transition method if exists.
 */
- (void)handleCallEvent:(HCACallEvent)event transitionContext:(id)transitionContext;

//Methods to mock
- (Class)mediaEngineClass;
- (Class)xmppBlockDispatcherClass;
- (Class)relayProtocolClass;

- (NSString *)fullJidCurrentUser;

@end
