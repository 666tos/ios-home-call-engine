//
//  HCACallActiveController.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/12/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "HCACallMediaContentController.h"

#import "JinglePhone.h"
#import "AudioSessionManager.h"

#import "VoiceEngine.h"
#import "LinphoneVoiceEngine.h"

#import "HCACallInfo.h"

@import HomeCenterXMPP;

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface HCACallMediaContentController ()

@property (strong, nonatomic) JinglePhone *jinglePhone;
@property (strong, nonatomic) LinphoneVoiceEngine *mediaEngine;
@property (strong, nonatomic) AudioSessionManager *audioSessionManager;
@property (assign, nonatomic) NSInteger jingleCallId;

@property (strong, nonatomic) dispatch_queue_t queue;

@property (assign, nonatomic, getter=isMicrophoneMuted, setter=setPrimitiveMicrophoneMuted:) BOOL microphoneMuted;
@property (assign, nonatomic, getter=isCameraMuted, setter=setPrimitiveCameraMuted:) BOOL cameraMuted;
@property (assign, nonatomic, getter=isLoudSpeakerEnabled, setter=setPrimitiveLoudSpeakerEnabled:) BOOL loudSpeakerEnabled;

@property (assign, nonatomic, getter=isRemoteAudioMuted) BOOL remoteAudioMuted;
@property (assign, nonatomic, getter=isРemoteVideoMuted) BOOL remoteVideoMuted;

@property (assign, nonatomic) AVCaptureDevicePosition cameraPosition;

@end

@implementation HCACallMediaContentController

- (void)dealloc
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self.audioSessionManager setSpeakerByDefault:YES];
}

- (instancetype)initWithJinglePhone:(JinglePhone *)jinglePhone
                        mediaEngine:(LinphoneVoiceEngine *)mediaEngine
                audioSessionManager:(AudioSessionManager *)audioSessionManager
                             callId:(NSInteger)callId
                      dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    self = [super init];
    if (self)
    {
        self.jingleCallId = callId;
        self.jinglePhone = jinglePhone;
        self.mediaEngine = mediaEngine;
        self.audioSessionManager = audioSessionManager;
        self.queue = dispatchQueue;
    }
    return self;
}

- (void)configureMediaWithCallInfo:(HCACallInfo *)callInfo
{
    BOOL videoEnabled = !(callInfo.callOptions & HCACallOptionVideoDisabled);
    
    [self setCameraMuted:!videoEnabled];
    [self toggleLoudSpeakerIfNeed];
    
    [self.audioSessionManager enableBTdevice];
}

- (void)setVideoPreviewEnabledIfApplicable:(BOOL)enabled forCall:(HCACallInfo *)callInfo
{
    if (!(callInfo.callOptions & HCACallOptionVideoDisabled) || !enabled)
    {
        [self.mediaEngine toggleVideoPreview:enabled withPreviewMode:ME_PREVIEW_VIDEO_CALL];
    }
}

#pragma mark - Proximity monitoring

- (void)toggleLoudSpeakerIfNeed
{
    BOOL disableLoudSpeaker = self.remoteVideoMuted && self.cameraMuted;
    
    [self setLoudSpeakerEnabled:!disableLoudSpeaker];
}

- (void)toggleProximityMonitoringIfNeed
{
    BOOL enableProximityMonitoring = !self.loudSpeakerEnabled;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:enableProximityMonitoring];
    });
}

#pragma mark - General device info

- (int)cameraCount
{
    return self.mediaEngine.cameraCount;
}

+ (BOOL)isMicrophonePresent
{
    BOOL available = [AVAudioSession sharedInstance].inputAvailable;
    
    DDLogDebug(@"isMicrophonePresent: %@", available ? @"YES" : @"NO");
    return available;
}

#pragma mark - Audio controlling

- (BOOL)setMicrophoneMuted:(BOOL)muted
{
    BOOL __block result = YES;
    
    if (_microphoneMuted != muted)
    {
        [HCASafeDispathcSync safeDispatchSyncInQueue:self.queue block:^
         {
             result = [self.jinglePhone muteMicrophoneOnCallWithID:self.jingleCallId withMute:muted];
             if (result)
             {
                 _microphoneMuted = muted;
                 
                 if ([self.delegate respondsToSelector:@selector(mediaController:microphoneSetMuted:)])
                 {
                     [self.delegate mediaController:self microphoneSetMuted:muted];
                 }
             }
         }];
    }
    
    return result;
}

- (BOOL)setLoudSpeakerEnabled:(BOOL)enabled
{
    BOOL __block result = YES;
    
    if (_loudSpeakerEnabled != enabled)
    {
        [HCASafeDispathcSync safeDispatchSyncInQueue:self.queue block:^{
            
            //TODO: Implemet error of setting
            self.audioSessionManager.forceLoudspeaker = enabled;
            _loudSpeakerEnabled = self.audioSessionManager.forceLoudspeaker;
            
            result = (enabled == _loudSpeakerEnabled);
            
            [self toggleProximityMonitoringIfNeed];
            
            if (result && [self.delegate  respondsToSelector:@selector(mediaController:loudSpeakerSetEnabled:)])
            {
                [self.delegate mediaController:self loudSpeakerSetEnabled:enabled];
            }
        }];
    }
    
    return result;
}

- (void)setRemoteAudioMuted:(BOOL)remoteAudioMuted
{
    _remoteAudioMuted = remoteAudioMuted;
    
    if ([self.delegate respondsToSelector:@selector(mediaController:remoteMicrophoneSetMuted:)])
    {
        [self.delegate mediaController:self remoteMicrophoneSetMuted:remoteAudioMuted];
    }
}

#pragma mark - Video controlling

- (BOOL)setCameraMuted:(BOOL)cameraMuted
{
    BOOL __block result = YES;
    
    if (_cameraMuted != cameraMuted)
    {
        [HCASafeDispathcSync safeDispatchSyncInQueue:self.queue block:^
         {
             result = [self.jinglePhone muteVideoOnCallWithID:self.jingleCallId withMute:cameraMuted];
             if (result)
             {
                 _cameraMuted = cameraMuted;
                 
                 [self toggleLoudSpeakerIfNeed];
                 
                 if ([self.delegate respondsToSelector:@selector(mediaController:cameraSetMuted:)])
                 {
                     [self.delegate mediaController:self cameraSetMuted:cameraMuted];
                 }
             }
         }];
    }
    
    return result;
}

- (void)setRemoteVideoMuted:(BOOL)remoteVideoMuted
{
    _remoteVideoMuted = remoteVideoMuted;
    
    if ([self.delegate respondsToSelector:@selector(mediaController:remoteCameraSetMuted:)])
    {
        [self.delegate mediaController:self remoteCameraSetMuted:remoteVideoMuted];
    }
}

- (BOOL)setCamerPosition:(AVCaptureDevicePosition)cameraPosition
{
    BOOL __block result = YES;
    
    if (cameraPosition != _cameraPosition)
    {
        //TODO: Fix deadlock here!!!
        [HCASafeDispathcSync safeDispatchSyncInQueue:self.queue block:^
         {
             _cameraPosition = cameraPosition;
             
             switch (cameraPosition)
             {
                 case AVCaptureDevicePositionFront:
                     [self.mediaEngine useFrontCamera];
                     break;
                     
                 case AVCaptureDevicePositionBack:
                     [self.mediaEngine useBackCamera];
                     break;
                     
                 default:
                     break;
             }
         }];
    }
    
    return result;
}

- (CGSize)previewVideoSize
{
    return [self.mediaEngine previewVideoSize];
}

- (void)updateOrientation:(UIDeviceOrientation)orientation
{
    //TODO: Do casting beatween orientations or change -[LinphoneVoiceEngine orientationUpdate] method
    [self.mediaEngine orientationUpdate:orientation];
}

- (void)setRemoteVideoView:(UIView *)remoteVideoView
{
    [self.mediaEngine setVideoRemoteView:remoteVideoView];
}

- (void)setLocalVideoView:(UIView *)localVideoView
{
    [self.mediaEngine setVideoLocalView:localVideoView];
}


#pragma mark - HCACallMediaContentEventListener

- (void)videoPreviewDidChange
{
    if ([self.delegate respondsToSelector:@selector(mediaControllerVideoPreviewDidChange:)])
    {
        [self.delegate mediaControllerVideoPreviewDidChange:self];
    }
}


- (void)remoteVideoContentWasMuted
{
    self.remoteVideoMuted = YES;
}

- (void)remoteVideoContentWasUnmuted
{
    self.remoteVideoMuted = NO;
}

- (void)remoteAudioContentWasMuted
{
    self.remoteAudioMuted = YES;
}

- (void)remoteAudioContentWasUnmuted
{
    self.remoteAudioMuted = NO;
}

- (void)callWasHold
{
    
}

- (void)callWasUnhold
{
    
}

#pragma mark - Block performing

- (void)performBlock:(dispatch_block_t)block
{
    dispatch_async(self.queue, block);
}

- (void)performBlockAndWait:(dispatch_block_t)block
{
    [HCASafeDispathcSync safeDispatchSyncInQueue:self.queue block:block];
}

@end
