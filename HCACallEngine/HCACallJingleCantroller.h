//
//  HCACallCantroller.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/10/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

/*
 The class describes state machine to controll calling. Definition of states transition is placed to HCACallControllerStatesDescription.h.
 */

#import <Foundation/Foundation.h>
#import <HomeCenterXMPP/HomeCenterXMPP.h>

#import "HCACallMediaContentController.h"

#import "HCACallInfo.h"

@class HCACallJingleCantroller;

typedef NS_ENUM(NSInteger, HCACallState)
{
    HCACallStateUnknown = -1,
    HCACallStateIdle = 0,
    HCACallStateIncomingCall,
    HCACallStateActive,
    HCACallStateActiveHeld,
    HCACallStateOutgoingCallDialing,
    HCACallStateOutgoingCallRinging,
    HCACallStateEnded,
    HCACallStateError,
    HCACallStateAudioInterruptedByOtherApp,
};

static NSString * const kHCACallStateNamesDebug[9] =
{
    @"HCACallStateIdle",
    @"HCACallStateIncomingCall",
    @"HCACallStateActive",
    @"HCACallStateActiveHeld",
    @"HCACallStateOutgoingCallDialing",
    @"HCACallStateOutgoingCallRinging",
    @"HCACallStateEnded",
    @"HCACallStateError",
    @"HCACallStateAudioInterruptedByOtherApp",
    
};

typedef void(^HCACallInterruptionHandler)(BOOL allowToInterrupt, HCACallOptions callOptions);

@protocol HCACallCantrollerListener <NSObject>

@optional

- (void)callControllerStateWillChange:(HCACallJingleCantroller *)controller onState:(HCACallState)newState;
- (void)callControllerStateDidChange:(HCACallJingleCantroller *)controller;

- (void)callController:(HCACallJingleCantroller *)controller didReceiveIncomingCall:(HCACallInfo *)callInfo;
- (void)callController:(HCACallJingleCantroller *)controller callWasMissed:(HCACallInfo *)callInfo;

- (void)callController:(HCACallJingleCantroller *)controller contactDidStartRinging:(HCACallInfo *)callInfo;

/*
 Methods are called when user or contact accepts/rejects current call.
 */
- (void)callController:(HCACallJingleCantroller *)controller callDidAccept:(HCACallInfo *)callInfo;
- (void)callController:(HCACallJingleCantroller *)controller callDidReject:(HCACallInfo *)callInfo;

- (void)callController:(HCACallJingleCantroller *)controller callDidTerminate:(HCACallInfo *)callInfo error:(NSError *)error;

- (void)callController:(HCACallJingleCantroller *)controller mediaControllerWasCreated:(HCACallMediaContentController *)mediaContentController
               forCall:(HCACallInfo *)callInfo;


- (void)callController:(HCACallJingleCantroller *)controller callWasHeld:(HCACallInfo *)callInfo;
- (void)callController:(HCACallJingleCantroller *)controller callWasUnheld:(HCACallInfo *)callInfo;

/*
 Method is called when incoming call comes during active call. It allows delegate to make decision if a new incoming call must be accepted or rejected.
 @param handler Block that must be called ASAP. If allowToInterrupt == YES then active call will be hang up and the incoming call will be accepted with callOptions. If allowToInterrupt == NO then the incoming call will be rejected.
 */
- (void)callController:(HCACallJingleCantroller *)controller
willInterruptByIncomingCall:(HCACallInfo *)callInfo
               handler:(void(^)(BOOL allowToInterrupt, HCACallOptions callOptions))handler;

- (void)callController:(HCACallJingleCantroller *)controller interruptingCallReleased:(NSInteger)jingleCallId;

@end

@interface HCACallJingleCantroller : NSObject

+ (instancetype)defaultCallController;

- (instancetype)initWithXMPPController:(HCXXMPPController *)xmppController;

@property (assign, nonatomic, readonly) HCACallState callState;

/*
 activeCallMediaContentController responds for all media controlling during call.
 activeCallMediaContentController == nil until media session created. Provides interface to control media content of a call.
 */
@property (strong, nonatomic, readonly) HCACallMediaContentController *activeCallMediaContentController;

@property (weak, nonatomic) id <HCACallCantrollerListener> listener;

@property (strong, nonatomic, readonly) NSString *localIP;

@property (strong, nonatomic, readonly) HCACallInfo *activeCallInfo;

//Calling

- (HCACallInfo *)callContactWithJid:(NSString *)jid callOptions:(HCACallOptions)callOptions;

- (void)acceptCallWithOptions:(HCACallOptions)callOptions;
- (void)rejectCall;
- (void)hangUp;

/*
 All method calls of HCACallJingleCantroller must be wrapped in one of these methods to guarantee thread safety.
 */
- (void)performBlock:(dispatch_block_t)block;
- (void)performBlockAndWait:(dispatch_block_t)block;

@end
