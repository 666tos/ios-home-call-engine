//
//  HCACallCantroller.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/10/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "HCACallJingleCantroller.h"

#import "HCACallControllerStatesDescription.h"

#import "XMPPDataBlockDispatcher.h"
#import "JinglePhone.h"
#import "AudioSessionManager.h"

#import "VoiceEngine.h"
#import "LinphoneVoiceEngine.h"

#import "XMPPProtocolJingle.h"
#import "HCANetworkProtocolRelayAdapter.h"
#import "CellularCallController.h"

#import "HCACallMediaContentController.h"

#import "Network.h"
#import "ReachabilityMonitor.h"
#import <HomeCenterXMPP/HCXTypesAndConstants.h>

#import "SoundPlayer.h"


#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

static NSTimeInterval kHCACallDefaultDialingTimeout = 180;
static NSTimeInterval kHCACallResetToIdleTimeout = 1;

@interface HCACallJingleCantroller () <JinglePhoneListener, XMPPStreamDelegate>
{
    
}

@property (nonatomic) dispatch_queue_t controllerQueue;

@property (nonatomic) HCACallState callState;

@property (strong, nonatomic) HCXXMPPController *xmppController;

@property (strong, nonatomic) XMPPDataBlockDispatcher *blockDispatcherAdapter;
@property (strong, nonatomic) JinglePhone *jinglePhone;
@property (strong, nonatomic) XMPPProtocolJingle *jingleProtocol;
@property (strong, nonatomic) HCANetworkProtocolRelayAdapter *relayProtocol;

@property (strong, nonatomic) LinphoneVoiceEngine *mediaEngine;
@property (strong, atomic) HCACallMediaContentController *activeCallMediaContentController;

@property (strong, nonatomic) AudioSessionManager *audioSessionManager;

@property (strong, nonatomic) NSString *localIP;

@property (strong, nonatomic) HCACallInfo *activeCallInfo;

@property (strong, nonatomic) XMPPTimer *dialingTimer;
@property (strong, nonatomic) XMPPTimer *resetToIdleTimer;

@end

@implementation HCACallJingleCantroller

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)defaultCallController
{
    static HCACallJingleCantroller *_defaultCallController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _defaultCallController = [[self alloc] initWithXMPPController:[HCXXMPPController defaultXMPPController]];
    });
    return _defaultCallController;
}

//Initialization is similar to [JingleController initWithNetworkProtocolAccessor:] in iO project
- (instancetype)initWithXMPPController:(HCXXMPPController *)xmppController
{
    NSParameterAssert(xmppController);
    if (!xmppController)
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        [HCASafeDispathcSync safeDispatchSyncInQueue:self.controllerQueue block:^
        {
            [[ReachabilityMonitor getInstance] setHost:SERVER_HOST];
            
            self.xmppController = xmppController;
            
            self.audioSessionManager = [AudioSessionManager sharedInstance];
            
            _mediaEngine = [[[self mediaEngineClass] alloc] initWithDispathQueue:self.controllerQueue];
            
            [self updateJingleIP];
            
            _blockDispatcherAdapter = [[[self xmppBlockDispatcherClass] alloc] initWithXMPPController:xmppController listenerQueue:self.controllerQueue];
            
            _jingleProtocol = [[XMPPProtocolJingle alloc] initWithDataBlockDispatcher:self.blockDispatcherAdapter];
            
            _relayProtocol = [[[self relayProtocolClass] alloc] initWithRelayEventObserverQueue:self.controllerQueue];
            self.relayProtocol.xmppController = xmppController;
            
            _jinglePhone = [[JinglePhone alloc] initWithJingleProtocol:self.jingleProtocol
                                                                 withRelayProtocol:self.relayProtocol
                                                             withForwardedProtocol:nil
                                                                   withVoiceEngine:self.mediaEngine
                                                                       withUseSrtp:YES
                                                                      withListener:self];
            
            [self.xmppController.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
            
            
            [self.jinglePhone setFullJidCurrentUser:[self fullJidCurrentUser]];
            [self.jinglePhone configureCodecs];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(audioSessionInterruptionNotificationReceived:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:nil];
        }];
    }
    
    return self;
}

#pragma mark - Unit testing support

- (Class)mediaEngineClass
{
    return [LinphoneVoiceEngine class];
}

- (Class)xmppBlockDispatcherClass
{
    return [XMPPDataBlockDispatcher class];
}

- (Class)relayProtocolClass
{
    return [HCANetworkProtocolRelayAdapter class];
}

- (NSString *)fullJidCurrentUser
{
    return [self.xmppController.xmppStream.myJID full];
}

#pragma mark - State machine
/*
 Input method for state machine.
 @param event 
 @param transitionContext An object that will be passed to state transition method if exists.
 */
- (void)handleCallEvent:(HCACallEvent)event transitionContext:(id)transitionContext
{
    [HCASafeDispathcSync safeDispatchSyncInQueue:self.controllerQueue block:^
    {
        HCACallState previousCallState = self.callState;
        
        BOOL isEventValid = event >= HCACallEventUserDialing && event <= HCACallEventResetToIdle;
        
        NSAssert(isEventValid, @"Unknown call event: %ld", (long)event);
        
        if (isEventValid)
        {
            HCACallStateTransition transition = _stateTransitions[self.callState][event];
            
            DDLogDebug(@"JINGLE_CONTROLLER: Transition from state: %@ to state: %@ by event: %@", kHCACallStateNamesDebug[previousCallState], kHCACallStateNamesDebug[transition.state], kHCACallEventNamesDebug[event]);
            
            [self willChangeValueForKey:@"callState"];
            if ([self.listener respondsToSelector:@selector(callControllerStateWillChange:onState:)])
            {
                [self.listener callControllerStateWillChange:self onState:transition.state];
            }
            
            self.callState = transition.state;
            if (transition.selectorName != NULL)
            {
                SEL selector = NSSelectorFromString([NSString stringWithUTF8String:transition.selectorName]);
                DDLogDebug(@"JINGLE_CONTROLLER: Transition handler: %@", NSStringFromSelector(selector));
                
                if (selector)
                {
                    if ([self respondsToSelector:selector])
                    {
                        [self performSelector:selector withObject:transitionContext];
                    }
                    else
                    {
                        NSAssert(NO, @"JINGLE_CONTROLLER: Wrong transition selector: %@, previous call state %@, new call state: %@", NSStringFromSelector(selector), kHCACallStateNamesDebug[previousCallState], kHCACallStateNamesDebug[self.callState]);
                        
                        DDLogError(@"JINGLE_CONTROLLER: Wrong transition selector: %@, previous call state %@, new call state: %@", NSStringFromSelector(selector), kHCACallStateNamesDebug[previousCallState], kHCACallStateNamesDebug[self.callState]);
                    }
                }
            }
            
            [self didChangeValueForKey:@"callState"];
            if ([self.listener respondsToSelector:@selector(callControllerStateDidChange:)])
            {
                [self.listener callControllerStateDidChange:self];
            }
        }
    }];
}

#pragma mark - State transition handlers

- (void)defaultTransitionHandler:(id)context
{
    //Do nothing
}

- (void)handleErrorState:(id)context
{
    [self terminateCall:self.activeCallInfo terminationReason:JingleTerminationTypeGeneralError withSound:YES];
}

- (void)startOutgoingDialing:(HCACallInfo *)callInfo
{
    self.activeCallInfo = callInfo;
    
    [self updateJingleIP];
    
    JingleSessionType callType = ([callInfo isWindowCall]) ? JingleSessionTypeWindow : JingleSessionTypeDefault;
    
    callInfo.jingleCallID = [self.jinglePhone callUserWithJid:[callInfo contactBareJid]
                                   withCurrentUserPhoneNumber:nil
                                                  withGateway:[callInfo jingleGetway]
                                                 withCallType:callType];
    
    NSAssert(callInfo.jingleCallID != kInvalidCallID, @"Invalid call id");
    
    [self setupCallMediaContentControllerForCall:callInfo];
    [self.activeCallMediaContentController setVideoPreviewEnabledIfApplicable:YES forCall:callInfo];
    
    [self startDialingTime];
    
}

- (void)handleOutgoingCallStartRinging:(HCACallInfo *)callInfo
{
    if (!([callInfo isWindowCall]))
    {
        [self.mediaEngine startRingtoneWithSoundID:LINPHONE_RINGING withInterval:RINGTONE_LOOP_AT_EOF];
    }
    
    [self.activeCallMediaContentController configureMediaWithCallInfo:callInfo];
}

- (void)handleCallAccepted:(HCACallInfo *)callInfo
{
    [self stopDialingTimer];
    
    callInfo.startCallingDate = [NSDate date];
    
    [self.activeCallMediaContentController configureMediaWithCallInfo:callInfo];
    
    if ([self.listener respondsToSelector:@selector(callController:callDidAccept:)])
    {
        [self.listener callController:self callDidAccept:callInfo];
    }
}

- (void)handleCallRejected:(HCACallInfo *)callInfo
{
    [self stopDialingTimer];
    
    if ([self.listener respondsToSelector:@selector(callController:callDidReject:)])
    {
        [self.listener callController:self callDidReject:callInfo];
    }
    
    BOOL playSound = ![callInfo isWindowCall];
    [self terminateCall:self.activeCallInfo terminationReason:JingleTerminationTypeBusy withSound:playSound];
}

- (void)handleCallEndedByContact:(NSNumber *)terminationReasonNumber
{
    JingleTerminationReason terminationReason = ([terminationReasonNumber isKindOfClass:[NSNumber class]]) ? [terminationReasonNumber intValue] : JingleTerminationTypeUnknown;
    
    [self terminateCall:self.activeCallInfo terminationReason:terminationReason withSound:YES];
}

- (void)handleIncomingCallEndedByContactBeforeAnsver:(NSNumber *)terminationReasonNumber
{
    JingleTerminationReason terminationReason = ([terminationReasonNumber isKindOfClass:[NSNumber class]]) ? [terminationReasonNumber intValue] : JingleTerminationTypeUnknown;
    
    if ([self.listener respondsToSelector:@selector(callController:callWasMissed:)])
    {
        [self.listener callController:self callWasMissed:self.activeCallInfo];
    }
    
    [self terminateCall:self.activeCallInfo terminationReason:terminationReason withSound:NO];
}

- (void)handleCallEndedByUser:(NSNumber *)terminationReasonNumber
{
    JingleTerminationReason terminationReason = ([terminationReasonNumber isKindOfClass:[NSNumber class]]) ? [terminationReasonNumber intValue] : JingleTerminationTypeUnknown;
    
    [self terminateCall:self.activeCallInfo terminationReason:terminationReason withSound:YES];
}

- (void)handleOutgoingCallError:(id)transitionContext
{
    JingleTerminationReason terminationReason = JingleTerminationTypeUnknown;
    
    [self terminateCall:self.activeCallInfo terminationReason:terminationReason withSound:YES];
}

- (void)handleIncomingCall:(HCACallInfo *)callInfo
{
    NSAssert(self.activeCallInfo == nil, @"There must not be active call here");
    NSParameterAssert(callInfo);
    NSAssert([callInfo.sessionID length] > 0, @"Session ID must not be empty");
    
    [self.activeCallMediaContentController setCamerPosition:AVCaptureDevicePositionFront];
    
    self.activeCallInfo = callInfo;
    
    [[SoundPlayer getInstance] playWithoutVibration:INCOMING_CALL_SOUND withLoop:YES loopQueue:self.controllerQueue];
    
    if ([self.listener respondsToSelector:@selector(callController:didReceiveIncomingCall:)])
    {
        [self.listener callController:self didReceiveIncomingCall:callInfo];
    }
}

- (void)acceptIncomingCall:(NSNumber *)callOptionsNumber
{
    NSAssert([self.activeCallInfo isJingleCallIDValid], @"Invalid active call jingle call ID");
 
    [[SoundPlayer getInstance] stop:INCOMING_CALL_SOUND];
    
    HCACallOptions callOptions = [callOptionsNumber integerValue];
    
    if ([self.activeCallInfo isJingleCallIDValid])
    {
        if(![self performCallAcceptingWithCallInfo:self.activeCallInfo withOptions:callOptions])
        {
            dispatch_async(self.controllerQueue, ^
            {
                [self handleCallEvent:(HCACallEventTerminateWithError) transitionContext:nil];
            });
        }
    }
}

- (void)rejectIncomingCall:(id)transitionContext
{
    NSAssert([self.activeCallInfo isJingleCallIDValid], @"Invalid active call jingle call ID");
    
    if ([self.activeCallInfo isJingleCallIDValid])
    {
        if ([self.listener respondsToSelector:@selector(callController:callDidReject:)])
        {
            [self.listener callController:self callDidReject:self.activeCallInfo];
        }
        
        [self terminateCall:self.activeCallInfo terminationReason:JingleTerminationTypeBusy withSound:NO];
    }
}

- (void)handleIncomingCallDuringActive:(HCACallInfo *)incomingCallInfo
{
    if ([self.listener respondsToSelector:@selector(callController:willInterruptByIncomingCall:handler:)])
    {
        HCACallInfo *activeCallInfo = self.activeCallInfo;
        __weak typeof(self) weakSelf = self;
        HCACallInterruptionHandler handler = ^(BOOL allowToInterrupt, HCACallOptions callOptions)
        {
            [weakSelf handleInterruptionActiveCall:activeCallInfo byIncomingCall:incomingCallInfo allowToInterrupt:allowToInterrupt acceptingCallOptions:callOptions];
        };
        
        [self.listener callController:self willInterruptByIncomingCall:incomingCallInfo handler:handler];
    }
    else
    {
       [self terminateCall:incomingCallInfo terminationReason:(JingleTerminationTypeBusy) withSound:NO];
    }
}

- (void)handleAudioInterruptionStarted:(id)context
{
    //Decline any not started yet call if there is.
    if ([self.activeCallInfo isJingleCallIDValid])
    {
        [self terminateCall:self.activeCallInfo terminationReason:JingleTerminationTypeDecline withSound:NO];
    }
}

- (void)handleAudioInterruptionFinished:(id)context
{
    
}

- (void)handleActiveCallAudioInterruptionStarted:(id)context
{
    if ([self.activeCallInfo isJingleCallIDValid])
    {
        BOOL result = [self.jinglePhone holdCallWithID:self.activeCallInfo.jingleCallID];
        if (result && [self.jinglePhone isCallOnHold:self.activeCallInfo.jingleCallID])
        {
            dispatch_async(self.controllerQueue, ^
            {
                [self handleCallEvent:HCACallEventHoldCall transitionContext:@(self.activeCallInfo.jingleCallID)];
            });
        }
    }
}

- (void)handleActiveCallAudioInterruptionFinished:(id)context
{
    if ([self.activeCallInfo isJingleCallIDValid])
    {
        BOOL result = [self.jinglePhone unHoldCallWithID:self.activeCallInfo.jingleCallID];
        if (result && ![self.jinglePhone isCallOnHold:self.activeCallInfo.jingleCallID])
        {
            dispatch_async(self.controllerQueue, ^
            {
                [self handleCallEvent:HCACallEventUnholdCall transitionContext:@(self.activeCallInfo.jingleCallID)];
            });
        }
    }
}

- (void)handleCallHold:(id)context
{
    if ([self.listener respondsToSelector:@selector(callController:callWasHeld:)])
    {
        [self.listener callController:self callWasHeld:self.activeCallInfo];
    }
}

- (void)handleCallUnHold:(id)context
{
    if ([self.listener respondsToSelector:@selector(callController:callWasUnheld:)])
    {
        [self.listener callController:self callWasUnheld:self.activeCallInfo];
    }
}

- (void)handleCallCollision:(HCACallInfo *)anotherCallInfo
{
    JingleTerminationReason terminationReason = JingleTerminationTypeBusy;
    [self terminateCall:anotherCallInfo terminationReason:terminationReason withSound:NO];
}

- (void)handleResetToIdle:(id)transitionContext
{
    [self.resetToIdleTimer cancel];
    
    if ([self.activeCallInfo isJingleCallIDValid])
    {
        [self terminateCall:self.activeCallInfo terminationReason:JingleTerminationTypeUnknown withSound:YES];
        self.activeCallInfo = nil;
    }
    
    [self.activeCallMediaContentController setLoudSpeakerEnabled:NO];
}

#pragma mark - Other incoming calls processing

- (void)handleInterruptionActiveCall:(HCACallInfo *)activeCallInfo
                     byIncomingCall:(HCACallInfo *)incomingCallInfo
                    allowToInterrupt:(BOOL)allowToInterrupt
                acceptingCallOptions:(HCACallOptions)acceptingCallOptions
{
    
    dispatch_async(self.controllerQueue, ^
    {
        if (allowToInterrupt)
        {
            if (self.activeCallInfo.jingleCallID == activeCallInfo.jingleCallID)
            {
                //Hang up previous call
                JingleTerminationReason terminationReason = JingleTerminationTypeDecline;
                
                [self terminateCall:activeCallInfo terminationReason:terminationReason withSound:NO];
                [self handleCallEvent:HCACallEventResetToIdle transitionContext:nil];
                
                //Accept new incoming call
                [self handleCallEvent:HCACallEventContactDialing transitionContext:incomingCallInfo];
                [self handleCallEvent:HCACallEventUserAccepted transitionContext:@(acceptingCallOptions)];
            }
            
        }
        else
        {
            JingleTerminationReason terminationReason = JingleTerminationTypeBusy;
            [self terminateCall:incomingCallInfo terminationReason:terminationReason withSound:NO];
        }
    });
}

#pragma mark - Utils


- (void)updateJingleIP
{
    TNetworkType _networkType;
    self.localIP = [Network getLocalIPWithType:&_networkType];
    
    if (_jinglePhone != nil)
    {
        [_jinglePhone setLocalIpAddress:_localIP];
    }
}

- (void)startDialingTime
{
    [self.dialingTimer cancel];
    
    __weak typeof(self) weakSelf = self;
    
    _dialingTimer = [[XMPPTimer alloc] initWithQueue:self.controllerQueue eventHandler:^
    {
        [weakSelf hangUpWithJingleTerminationReason:JingleTerminationTypeTimeout];
    }];
    
    [self.dialingTimer startWithTimeout:kHCACallDefaultDialingTimeout interval:-1];
}

- (void)stopDialingTimer
{
    [self.dialingTimer cancel];
}

- (void)setupCallMediaContentControllerForCall:(HCACallInfo *)callInfo
{
    NSParameterAssert(self.activeCallInfo);
    
    _activeCallMediaContentController = [[HCACallMediaContentController alloc] initWithJinglePhone:self.jinglePhone
                                                                                       mediaEngine:self.mediaEngine
                                                                               audioSessionManager:self.audioSessionManager
                                                                                            callId:self.activeCallInfo.jingleCallID
                                                                                     dispatchQueue:self.controllerQueue];
    
    [self.activeCallMediaContentController configureMediaWithCallInfo:callInfo];
    
    if ([self.listener respondsToSelector:@selector(callController:mediaControllerWasCreated:forCall:)])
    {
        [self.listener callController:self mediaControllerWasCreated:self.activeCallMediaContentController forCall:callInfo];
    }
}

- (void)cleanCallMediaContentController
{
    [self.activeCallMediaContentController setLocalVideoView:nil];
    [self.activeCallMediaContentController setRemoteVideoView:nil];
    self.activeCallMediaContentController = nil;
}

- (void)scheduleResetToIdleTimer:(NSTimeInterval)timeout
{
    [self.resetToIdleTimer cancel];
 
    __weak typeof(self) weakSelf = self;
    _resetToIdleTimer = [[XMPPTimer alloc] initWithQueue:self.controllerQueue eventHandler:^
    {
        [weakSelf handleCallEvent:(HCACallEventResetToIdle) transitionContext:nil];
    }];
    [self.resetToIdleTimer startWithTimeout:timeout interval:-1];
}

- (void)stopResetToIdleTimer
{
    [self.resetToIdleTimer cancel];
    self.resetToIdleTimer = nil;
}

#pragma mark - Properties

- (dispatch_queue_t)controllerQueue
{
    if (!_controllerQueue)
    {
        _controllerQueue = dispatch_queue_create("HCACallEngine.HCACallController", DISPATCH_QUEUE_SERIAL);
    }
    return _controllerQueue;
}

- (void)setListener:(id<HCACallCantrollerListener>)listener
{
    _listener = listener;
}


#pragma mark - Call managment

- (HCACallInfo *)callContactWithJid:(NSString *)jid callOptions:(HCACallOptions)callOptions
{
    HCACallInfo *callInfo = [[HCACallInfo alloc] initWithContactJid:jid callInitiationType:(HCACallInitiationTypeOutgoing) callOptions:callOptions];
    
    [self handleCallEvent:(HCACallEventUserDialing) transitionContext:callInfo];
    return callInfo;
}

- (void)hangUp
{
    [self hangUpWithJingleTerminationReason:JingleTerminationTypeDecline];
}

- (void)hangUpWithJingleTerminationReason:(JingleTerminationReason)terminationReason
{
    [self handleCallEvent:(HCACallEventUserHungUp) transitionContext:@(terminationReason)];//TODO: Think about types of hanging up
}

- (void)acceptCallWithOptions:(HCACallOptions)callOptions
{
    [self handleCallEvent:HCACallEventUserAccepted transitionContext:@(callOptions)];
}

- (void)rejectCall
{
    [self handleCallEvent:HCACallEventUserRejected transitionContext:nil];
}

- (BOOL)performCallAcceptingWithCallInfo:(HCACallInfo *)callInfo withOptions:(HCACallOptions)callOptions
{
    BOOL result = NO;
    
    if ([callInfo isJingleCallIDValid])
    {
        callInfo.callOptions |= callOptions;
        
        BOOL audioSrtpEnabled;
        BOOL videoSrtpEnabled;
        
        [self updateJingleIP];
        
        callInfo.startCallingDate = [NSDate date];
        
        if([self.jinglePhone acceptCallWithID:callInfo.jingleCallID withAudioSrtpEnabled:&audioSrtpEnabled withVideoSrtpEnabled:&videoSrtpEnabled withForceAudio:NO])
        {
            callInfo.videoSrtpEnabled = videoSrtpEnabled;
            callInfo.videoSrtpEnabled = audioSrtpEnabled;
            
            [self setupCallMediaContentControllerForCall:callInfo];
            
            if ([self.listener respondsToSelector:@selector(callController:callDidAccept:)])
            {
                [self.listener callController:self callDidAccept:callInfo];
            }
            
            result = YES;
        }
    }
    
    return result;
}

- (void)terminateCall:(HCACallInfo *)callInfo terminationReason:(JingleTerminationReason)terminationReason withSound:(BOOL)needToPlaySound
{
    if (self.activeCallInfo.jingleCallID == callInfo.jingleCallID)
    {
        [[SoundPlayer getInstance] stop:INCOMING_CALL_SOUND];
        [self.mediaEngine stopRingtone];
        
        NSTimeInterval idleTimeout = (needToPlaySound)
        ? [self playSoundForCallTerminationReason:terminationReason outgoing:(callInfo.callInitiationType == HCACallInitiationTypeOutgoing)]
        : kHCACallResetToIdleTimeout;
        
        callInfo.terminationReason = terminationReason;
        
        if ([self.listener respondsToSelector:@selector(callController:callDidTerminate:error:)])
        {
            [self.listener callController:self callDidTerminate:callInfo error:nil];
        }
        
        self.activeCallInfo = nil;
        
        [self.activeCallMediaContentController setVideoPreviewEnabledIfApplicable:NO forCall:callInfo];
        
        [self cleanCallMediaContentController];
        
        [self.mediaEngine stopIoUnit];
        
        [self scheduleResetToIdleTimer:idleTimeout];
    }
    
    [self.jinglePhone releaseCallWithID:callInfo.jingleCallID withType:terminationReason];
}

/*
 Starts playing proper sound and returns duration of the sound
 */
- (NSTimeInterval)playSoundForCallTerminationReason:(JingleTerminationReason)terminationReason outgoing:(BOOL)isCallOutgoing
{
    SoundID soundId = NO_SOUND;
    
    switch (terminationReason)
    {
        case JingleTerminationTypeBusy:
            soundId = (isCallOutgoing) ? LINPHONE_CALL_BUSY : LINPHONE_CALL_HANGUP;
            break;
            
            
        case JingleTerminationTypeConnectivityError:
        case JingleTerminationTypeGeneralError:
        case JingleTerminationTypeForbidden:
        case JingleTerminationTypeSecurityError:
        case JingleTerminationTypeMediaError:
        case JingleTerminationTypeUnknown:
            soundId = LINPHONE_CALL_ERROR;
            break;
            
        case JingleTerminationTypeTimeout:
        case JingleTerminationTypeDecline:
            soundId = LINPHONE_CALL_HANGUP;
            break;
            
        case JingleTerminationTypeNoError:
            soundId = NO_SOUND;
            break;
            
        default:
            break;
    }
    
    Float64 fileLength = [[SoundPlayer getInstance] getFileLength:soundId];
    
//    [[SoundPlayer getInstance] playWithoutVibration:soundId withLoop:NO];
    
    [self.mediaEngine startRingtoneWithSoundID:soundId withInterval:RINGTONE_NO_LOOP];
    
    DDLogDebug(@"--- %@ %@ %ld sound id: %lu, duration: %f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (long)terminationReason, (unsigned long)soundId, fileLength);
    
    return fileLength;
}

#pragma mark - JinglePhoneListener

- (void)handleIncomingCallWithInfo:(JingleIncomingCallInfo *)incomingCallInfo
{
    DDLogDebug(@"--- %@ handleIncomingCallWithID: %ld withSessionID: %ld withCommunicationAddress: %@ withGateway: %ld withServerTimestamp: %@", NSStringFromClass([self class]), (long)incomingCallInfo.callID, (long)incomingCallInfo.sessionID, incomingCallInfo.communicationAddress.routeAddress, (long)incomingCallInfo.gateway, incomingCallInfo.serverTimestamp);
    
    NSAssert(incomingCallInfo.gateway == JingleGatewayRelayedVideo, @"Gateway must be gateway == JingleGatewayRelayedVideo, other types are not supported yet");
    
    HCACallOptions callOptions = HCACallOptionsDefault;
    if (incomingCallInfo.sessionType == JingleSessionTypeWindow)
    {
        callOptions |= HCACallOptionWindow;
    }
    
    HCACallInfo *callInfo = [[HCACallInfo alloc] initWithContactJid:incomingCallInfo.communicationAddress.contactID.ucidJid
                                                 callInitiationType:(HCACallInitiationTypeIncoming)
                                                        callOptions:callOptions];
    
    callInfo.sessionID = incomingCallInfo.sessionID;
    callInfo.jingleCallID = incomingCallInfo.callID;
    callInfo.serverTimeStamp = incomingCallInfo.serverTimestamp;
    
    [self handleCallEvent:HCACallEventContactDialing transitionContext:callInfo];
}

/**
 * Called when an outgoing call was acknowledged by the server
 * @param callID ID of the call
 * @param serverTimestamp Timestamp of the server. nil if we have no server timestamp
 */
- (void)handleOutgoingCallAcknowledgedWithID:(NSInteger)callID withSessionID:(NSString*)sessionID withServerTimestamp:(NSDate*)serverTimestamp
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

/**
 * When setting up an outgoing call, this callback is called to notify
 * the listener that the phone is ringing on the other side
 * @param callID Call ID
 */
- (void)handleCallAlertedWithID:(NSInteger)callID
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self handleCallEvent:HCACallEventContactStartRinging transitionContext:self.activeCallInfo];
}

/**
 * Called to notify the listener that early media is currently playing
 * This can happen when placing an outgoing call and the server plays a message for instance before the actual call starts.
 * Note that this callback could be called twice (or more), if we get multiple early media's
 * @param callID Call ID
 */
- (void)handleReceivingEarlyMediaForCallWithID:(NSInteger)callID
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

/**
 * When setting up an outgoing call, this callback is called to notify
 * the listener that the phone is picked up on the other side
 * @param callID Call ID
 * @param serverTimestamp nil if we have to server timestamp
 * @param srtpEnabled If YES, the RTP stream is encrypted with SRTP both ways
 */
- (void)handleCallAnsweredWithID:(NSInteger)callID withServerTimestamp:(NSDate*)serverTimestamp withAudioSrtpEnabled:(BOOL)audioSrtpEnabled withVideoSrtpEnabled:(BOOL)videoSrtpEnabled withVideoEnabled:(BOOL)videoEnabled
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    HCACallInfo *acceptedCallInfo = (self.activeCallInfo.jingleCallID == callID)
    ? self.activeCallInfo
    : [[HCACallInfo alloc] initWithContactJid:nil callInitiationType:HCACallInitiationTypeOutgoing callOptions:HCACallOptionsDefault];
    
    HCACallOptions callOptions = (videoEnabled) ? HCACallOptionsDefault : HCACallOptionVideoDisabled;
    acceptedCallInfo.callOptions |= callOptions;
    
    acceptedCallInfo.videoSrtpEnabled = videoSrtpEnabled;
    acceptedCallInfo.audioSrtpEnabled = audioSrtpEnabled;
    
    [self handleCallEvent:(HCACallEventContactAccepted) transitionContext:acceptedCallInfo];
}

/**
 * Fired when a call is released
 * @param callID Call ID
 * @param reason enumerated type indicating the reasons of the call termination
 * @param serverTimestamp nil if we have to server timestamp
 */
- (void)handleCallReleasedWithID:(NSInteger)callID withReason:(JingleTerminationReason)reason withServerTimestamp:(NSDate*)serverTimestamp
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    //TODO: Think about different call ids
    if (self.activeCallInfo.jingleCallID == callID)
    {
        HCACallEvent event = HCACallEventUnknown;
        NSNumber *transitionContext = @(reason);
        
        switch (reason)
        {
            case JingleTerminationTypeConnectivityError:
            case JingleTerminationTypeMediaError:
            case JingleTerminationTypeForbidden:
            case JingleTerminationTypeSecurityError:
            case JingleTerminationTypeUnknown:
            case JingleTerminationTypeGeneralError:
            case JingleTerminationTypeTimeout:
                
                event = HCACallEventTerminateWithError;
                break;
                
            case JingleTerminationTypeBusy:
            case JingleTerminationTypeDecline:
                
                event = HCACallEventContactRejected;
                break;
                
            case JingleTerminationTypeNoError:
                
                event = HCACallEventContactHungUp;
                break;
                
            default:
                break;
        }
        
        [self handleCallEvent:event transitionContext:transitionContext];
    }
    else
    {
//        NSLog(@"--- %@ - %@, callID != self.activeCallInfo.jingleCallID %ld != %ld", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (long)callID, (long)self.activeCallInfo.jingleCallID);
        
        if ([self.listener respondsToSelector:@selector(callController:interruptingCallReleased:)])
        {
            [self.listener callController:self interruptingCallReleased:callID];
        }
    }
    
}

/**
 * Fired when a video preview is changed
 * @param callID Call ID
 */
- (void)handlePreviewChanged
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self.activeCallMediaContentController videoPreviewDidChange];
}

/**
 * Fired when video quality is degraded
 * @param callID Call ID
 */
- (void)handleVideoQualityDegradedOnCallWithID:(NSInteger)callID
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

/**
 * A call had it's transport updated (we're sending to a different RTP destination now)
 * @param callID Call ID
 */
- (void)handleCallTransportUpdated:(NSInteger)callID
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

/**
 * Process a missed call (= a jingle terminate without any corresponding initiate)
 * @param serverTimestamp nil if we have to server timestamp
 * @return YES if the missed call was properly processed
 */
- (BOOL)handleMissedCallFromAddress:(CommunicationAddress*)address withSessionID:(NSString*)sessionID withServerTimestamp:(NSDate*)serverTimestamp withGateway:(JingleGateway)gateway
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if ([self.listener respondsToSelector:@selector(callController:callWasMissed:)])
    {
        
        HCACallInfo *callInfo = [[HCACallInfo alloc] initWithContactJid:address.contactID.ucidJid
                                                     callInitiationType:(HCACallInitiationTypeIncoming)
                                                            callOptions:(HCACallOptionsDefault)];
        
        [self.listener callController:self callWasMissed:callInfo];
    }
    
    return YES;
}

/**
 * A call was put on hold by other side
 * @param callID Call ID
 */
- (void)handleCallHoldWithID:(NSInteger)callID
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self handleCallEvent:HCACallEventHoldCall transitionContext:@(callID)];
}

/**
 * A call was removed from hold by other side
 * @param callID Call ID
 */
- (void)handleCallUnHoldWithID:(NSInteger)callID
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self handleCallEvent:HCACallEventUnholdCall transitionContext:@(callID)];
}


/**
 * Content was muted by other side
 * @param callID Call ID
 */
- (void)handleCallContentMuteWithID:(NSInteger)callID forType:(JingleSessionInfoContentType)type
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSAssert(self.activeCallMediaContentController.jingleCallId == callID, @"Wrong call id");
    
    if (self.activeCallMediaContentController.jingleCallId == callID)
    {
        switch (type)
        {
            case JingleSessionInfoContentAudio:
                if ([self.activeCallMediaContentController respondsToSelector:@selector(remoteAudioContentWasMuted)])
                {
                    [self.activeCallMediaContentController remoteAudioContentWasMuted];
                }
                break;
                
            case JingleSessionInfoContentVideo:
                if ([self.activeCallMediaContentController respondsToSelector:@selector(remoteVideoContentWasMuted)])
                {
                    [self.activeCallMediaContentController remoteVideoContentWasMuted];
                }
                break;
                
            default:
                break;
        }
    }
}

/**
 * Content was unmuted by other side
 * @param callID Call ID
 */
- (void)handleCallContentUnmuteWithID:(NSInteger)callID forType:(JingleSessionInfoContentType)type
{
    NSLog(@"--- %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSAssert(self.activeCallMediaContentController.jingleCallId == callID, @"Wrong call id");
    
    if (self.activeCallMediaContentController.jingleCallId == callID)
    {
        switch (type)
        {
            case JingleSessionInfoContentAudio:
                
                if ([self.activeCallMediaContentController respondsToSelector:@selector(remoteAudioContentWasUnmuted)])
                {
                    [self.activeCallMediaContentController remoteAudioContentWasUnmuted];
                }
                break;
                
            case JingleSessionInfoContentVideo:
                
                if ([self.activeCallMediaContentController respondsToSelector:@selector(remoteVideoContentWasUnmuted)])
                {
                    [self.activeCallMediaContentController remoteVideoContentWasUnmuted];
                }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidChangeMyJID:(XMPPStream *)xmppStream
{
    [self.jinglePhone setFullJidCurrentUser:[self fullJidCurrentUser]];
}


#pragma mark - Audio Session Interruptions

- (void)audioSessionInterruptionNotificationReceived:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionInterruptionType interuptionType = [userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
//    AVAudioSessionInterruptionOptions interruptionOption = [userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
    
    switch (interuptionType)
    {
        case AVAudioSessionInterruptionTypeBegan:
            [self handleCallEvent:(HCACallEventAudioInterruptionStarted) transitionContext:nil];
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
            [self handleCallEvent:(HCACallEventAudioInterruptionFinished) transitionContext:nil];
            break;
            
        default:
            break;
    }
}


#pragma mark - Block performing

- (void)performBlock:(dispatch_block_t)block
{
    dispatch_async(self.controllerQueue, block);
}

- (void)performBlockAndWait:(dispatch_block_t)block
{
    [HCASafeDispathcSync safeDispatchSyncInQueue:self.controllerQueue block:block];
}

@end
