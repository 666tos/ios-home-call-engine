//
//  HCACallControllerStatesDescription.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/11/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#ifndef HomeCenter_HCACallControllerStatesDescription_h
#define HomeCenter_HCACallControllerStatesDescription_h

typedef NS_ENUM(NSInteger, HCACallEvent)
{
    HCACallEventUnknown = -1,
    HCACallEventUserDialing = 0,
    HCACallEventUserAccepted,
    HCACallEventUserRejected,
    HCACallEventUserHungUp,
    HCACallEventContactDialing,
    HCACallEventContactStartRinging,
    HCACallEventContactAccepted,
    HCACallEventContactRejected,
    HCACallEventContactHungUp,
    
    HCACallEventAudioInterruptionStarted,
    HCACallEventAudioInterruptionFinished,
    
    HCACallEventHoldCall,
    HCACallEventUnholdCall,
    
    HCACallEventTerminateWithError,
    HCACallEventResetToIdle,
    
    
};

//TODO: Implement states description using selectors.
typedef struct
{
    HCACallState state;
    const char *selectorName;
} HCACallStateTransition;

//#pragma GCC diagnostic push
//#pragma GCC diagnostic ignored "-Wwrite-strings"

static HCACallStateTransition const _stateTransitions[9][15] =
{
    //HCACallStateIdle
    {
        {HCACallStateOutgoingCallDialing, "startOutgoingDialing:"},         //HCACallEventUserDialing
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUserAccepted
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUserRejected
        {HCACallStateIdle, "handleResetToIdle:"},                                   //HCACallEventUserHungUp
        {HCACallStateIncomingCall, "handleIncomingCall:"},          //HCACallEventContactDialing
        {HCACallStateError, "handleErrorState:"},                                        //HCACallEventContactStartRinging
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventContactAccepted
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventContactRejected
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventContactHungUp
        
        {HCACallStateAudioInterruptedByOtherApp, "handleAudioInterruptionStarted:"},    //HCACallEventAudioInterruptionStarted
        {HCACallStateIdle, NULL},                                                       //HCACallEventAudioInterruptionFinished
        
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventHoldCall
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUnholdCall
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"},                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateIncomingCall
    {
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUserDialing
        {HCACallStateActive, "acceptIncomingCall:"},                                 //HCACallEventUserAccepted
        {HCACallStateEnded, "rejectIncomingCall:"},                                  //HCACallEventUserRejected
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUserHungUp
        {HCACallStateIncomingCall, "handleCallCollision:"},                        //HCACallEventContactDialing
        {HCACallStateError, "handleErrorState:"},                                        //HCACallEventContactStartRinging
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventContactAccepted
        {HCACallStateEnded, "handleIncomingCallEndedByContactBeforeAnsver:"},          //HCACallEventContactRejected
        {HCACallStateEnded, "handleIncomingCallEndedByContactBeforeAnsver:"},          //HCACallEventContactHungUp
        
        {HCACallStateAudioInterruptedByOtherApp, "rejectIncomingCall:"},               //HCACallEventAudioInterruptionStarted
        {HCACallStateIncomingCall, NULL},                                              //HCACallEventAudioInterruptionFinished
        
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventHoldCall
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUnholdCall
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"}                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateActive
    {
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUserDialing
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUserAccepted
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUserRejected
        {HCACallStateEnded, "handleCallEndedByUser:"},                                       //HCACallEventUserHungUp
        {HCACallStateActive, "handleIncomingCallDuringActive:"},                //HCACallEventContactDialing
        {HCACallStateError, "handleErrorState:"},                                        //HCACallEventContactStartRinging
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventContactAccepted
        {HCACallStateEnded, "handleCallEndedByContact:"},                                       //HCACallEventContactRejected
        {HCACallStateEnded, "handleCallEndedByContact:"},                                  //HCACallEventContactHungUp
        
        
        {HCACallStateActive, "handleActiveCallAudioInterruptionStarted:"},                //HCACallEventAudioInterruptionStarted
        {HCACallStateActive, NULL},                                                       //HCACallEventAudioInterruptionFinished
        
        {HCACallStateActiveHeld, "handleCallHold:"},                             //HCACallEventHoldCall
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventUnholdCall
        {HCACallStateError, "handleErrorState:"},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"}                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateActiveHeld
    {
        {HCACallStateError, "handleErrorState:"},                                      //HCACallEventUserDialing
        {HCACallStateError, "handleErrorState:"},                                      //HCACallEventUserAccepted
        {HCACallStateError, "handleErrorState:"},                                      //HCACallEventUserRejected
        {HCACallStateEnded, "handleCallEndedByUser:"},                                      //HCACallEventUserHungUp
        {HCACallStateActiveHeld, "handleIncomingCallDuringActive:"},                //HCACallEventContactDialing
        {HCACallStateError, "handleErrorState:"},                                        //HCACallEventContactStartRinging
        {HCACallStateError, "handleErrorState:"},                                      //HCACallEventContactAccepted
        {HCACallStateError, "handleErrorState:"},                                      //HCACallEventContactRejected
        {HCACallStateEnded, "handleCallEndedByContact:"},                                      //HCACallEventContactHungUp
        
        {HCACallStateActiveHeld, NULL},                                         //HCACallEventAudioInterruptionStarted
        {HCACallStateActiveHeld, "handleActiveCallAudioInterruptionFinished:"},             //HCACallEventAudioInterruptionFinished
        
        {HCACallStateActiveHeld, NULL},                                      //HCACallEventHoldCall
        {HCACallStateActive, "handleCallUnHold:"},                                     //HCACallEventUnholdCall
        {HCACallStateError, "handleErrorState:"},                                      //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"}                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateOutgoingCallDialing
    {
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUserDialing
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUserAccepted
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUserRejected
        {HCACallStateEnded, "handleCallEndedByUser:"},                                  //HCACallEventUserHungUp
        {HCACallStateActiveHeld, "handleCallCollision:"},                               //HCACallEventContactDialing
        {HCACallStateOutgoingCallRinging, "handleOutgoingCallStartRinging:"},                  //HCACallEventContactStartRinging
        {HCACallStateActive, "handleOutgoingCallError:"},                                         //HCACallEventContactAccepted
        {HCACallStateEnded, "handleCallEndedByContact:"},                                  //HCACallEventContactRejected
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventContactHungUp
        
        {HCACallStateAudioInterruptedByOtherApp, "handleAudioInterruptionStarted:"},                         //HCACallEventAudioInterruptionStarted
        {HCACallStateOutgoingCallDialing, NULL},                                                       //HCACallEventAudioInterruptionFinished
        
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventHoldCall
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUnholdCall
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"}                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateOutgoingCallRinging
    {
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUserDialing
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUserAccepted
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUserRejected
        {HCACallStateEnded, "handleCallEndedByUser:"},                                  //HCACallEventUserHungUp
        {HCACallStateActiveHeld, "handleCallCollision:"},                       //HCACallEventContactDialing
        {HCACallStateOutgoingCallRinging, NULL},                                    //HCACallEventContactStartRinging
        {HCACallStateActive, "handleCallAccepted:"},                                         //HCACallEventContactAccepted
        {HCACallStateEnded, "handleCallEndedByContact:"},                                  //HCACallEventContactRejected
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventContactHungUp
        
        {HCACallStateAudioInterruptedByOtherApp, "handleAudioInterruptionStarted:"},                         //HCACallEventAudioInterruptionStarted
        {HCACallStateOutgoingCallRinging, NULL},                                                       //HCACallEventAudioInterruptionFinished
        
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventHoldCall
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventUnholdCall
        {HCACallStateError, "handleOutgoingCallError:"},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"}                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateEnded
    {
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventUserDialing
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventUserAccepted
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventUserRejected
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventUserHungUp
        {HCACallStateEnded, "handleIncomingCallDuringActive:"},                       //HCACallEventContactDialing
        {HCACallStateError, "defaultTransitionHandler:"},                                        //HCACallEventContactStartRinging
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventContactAccepted
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventContactRejected
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventContactHungUp
        
        {HCACallStateAudioInterruptedByOtherApp, "handleAudioInterruptionStarted:"},                         //HCACallEventAudioInterruptionStarted
        {HCACallStateEnded, NULL},                                                       //HCACallEventAudioInterruptionFinished
        
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventHoldCall
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventUnholdCall
        {HCACallStateEnded, "defaultTransitionHandler:"},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"}                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateError
    {
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventUserDialing
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventUserAccepted
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventUserRejected
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventUserHungUp
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventContactDialing
        {HCACallStateError, "defaultTransitionHandler:"},                                        //HCACallEventContactStartRinging
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventContactAccepted
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventContactRejected
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventContactHungUp
        
        {HCACallStateAudioInterruptedByOtherApp, "handleAudioInterruptionStarted:"},                         //HCACallEventAudioInterruptionStarted
        {HCACallStateError, NULL},                                                       //HCACallEventAudioInterruptionFinished
        
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventHoldCall
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventUnholdCall
        {HCACallStateError, "defaultTransitionHandler:"},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"}                                       //HCACallEventResetToIdle
    },
    
    //HCACallStateAudioInterruptedByOtherApp
    {
        {HCACallStateAudioInterruptedByOtherApp, NULL},                               //HCACallEventUserDialing
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                       //HCACallEventUserAccepted
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                       //HCACallEventUserRejected
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                   //HCACallEventUserHungUp
        {HCACallStateAudioInterruptedByOtherApp, "handleIncomingCallDuringActive:"},          //HCACallEventContactDialing
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                        //HCACallEventContactStartRinging
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                       //HCACallEventContactAccepted
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                       //HCACallEventContactRejected
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                      //HCACallEventContactHungUp
        
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                       //HCACallEventAudioInterruptionStarted
        {HCACallStateIdle, "handleAudioInterruptionFinished:"},                                       //HCACallEventAudioInterruptionFinished
        
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                       //HCACallEventHoldCall
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                      //HCACallEventUnholdCall
        {HCACallStateAudioInterruptedByOtherApp, NULL},                                       //HCACallEventTerminateWithError
        {HCACallStateIdle, "handleResetToIdle:"},                                       //HCACallEventResetToIdle
    },
    
};

//#pragma GCC diagnostic pop

static NSString * const kHCACallEventNamesDebug[15] =
{
    @"HCACallEventUserDialing",
    @"HCACallEventUserAccepted",
    @"HCACallEventUserRejected",
    @"HCACallEventUserHungUp",
    @"HCACallEventContactDialing",
    @"HCACallEventContactStartRinging",
    @"HCACallEventContactAccepted",
    @"HCACallEventContactRejected",
    @"HCACallEventContactHungUp",
    
    @"HCACallEventAudioInterruptionStarted",
    @"HCACallEventAudioInterruptionFinished",
    
    @"HCACallEventHoldCall",
    @"HCACallEventUnholdCall",
    
    @"HCACallEventTerminateWithError",
    @"HCACallEventResetToIdle",
    
};

#endif
