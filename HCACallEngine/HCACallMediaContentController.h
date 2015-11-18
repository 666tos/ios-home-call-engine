//
//  HCACallActiveController.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/12/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import "SoundTypes.h"

@class JinglePhone;
@class LinphoneVoiceEngine;
@class AudioSessionManager;
@class HCACallInfo;

@class HCACallMediaContentController;

@protocol HCACallMediaContentEventListener <NSObject>

@optional

- (void)remoteVideoContentWasMuted;
- (void)remoteVideoContentWasUnmuted;

- (void)remoteAudioContentWasMuted;
- (void)remoteAudioContentWasUnmuted;

- (void)callWasHold;
- (void)callWasUnhold;

- (void)videoPreviewDidChange;

@end

@protocol HCACallMediaContentControllerDelegate <NSObject>

@optional

- (void)mediaControllerVideoPreviewDidChange:(HCACallMediaContentController *)controller;

- (void)mediaController:(HCACallMediaContentController *)controller microphoneSetMuted:(BOOL)muted;
- (void)mediaController:(HCACallMediaContentController *)controller cameraSetMuted:(BOOL)muted;

- (void)mediaController:(HCACallMediaContentController *)controller remoteMicrophoneSetMuted:(BOOL)muted;
- (void)mediaController:(HCACallMediaContentController *)controller remoteCameraSetMuted:(BOOL)muted;

- (void)mediaController:(HCACallMediaContentController *)controller loudSpeakerSetEnabled:(BOOL)enabled;

@end

typedef void(^HCACallMediaContentControllerSettingAsyncHandler)(BOOL resultState);

@interface HCACallMediaContentController : NSObject <HCACallMediaContentEventListener>

@property (strong, nonatomic, readonly) JinglePhone *jinglePhone;
@property (strong, nonatomic, readonly) LinphoneVoiceEngine *mediaEngine;
@property (strong, nonatomic, readonly) AudioSessionManager *audioSessionManager;
@property (assign, nonatomic, readonly) NSInteger jingleCallId;
@property (strong, nonatomic, readonly) dispatch_queue_t queue;

@property (assign, nonatomic, getter=isRemoteAudioMuted, readonly) BOOL remoteAudioMuted;
@property (assign, nonatomic, getter=isРemoteVideoMuted, readonly) BOOL remoteVideoMuted;

@property (weak, nonatomic) id <HCACallMediaContentControllerDelegate> delegate;

- (instancetype)initWithJinglePhone:(JinglePhone *)jinglePhone
                        mediaEngine:(LinphoneVoiceEngine *)mediaEngine
                audioSessionManager:(AudioSessionManager *)audioSessionManager
                             callId:(NSInteger)callId
                      dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)configureMediaWithCallInfo:(HCACallInfo *)callInfo;

+ (BOOL)isMicrophonePresent;
- (int)cameraCount;

//- (void)videoViewIsVisible:(BOOL)visible;
- (CGSize)previewVideoSize;


- (void)performBlock:(dispatch_block_t)block;
- (void)performBlockAndWait:(dispatch_block_t)block;

/*
 All method bellow must be invoked in internal queue. Use can use performBlock and performBlockAndWait for this.
 */

- (void)setVideoPreviewEnabledIfApplicable:(BOOL)enabled forCall:(HCACallInfo *)callInfo;

- (BOOL)setCamerPosition:(AVCaptureDevicePosition)cameraPosition;
- (AVCaptureDevicePosition)cameraPosition;

- (BOOL)setCameraMuted:(BOOL)cameraMuted;
- (BOOL)isCameraMuted;

- (BOOL)setMicrophoneMuted:(BOOL)muted;
- (BOOL)isMicrophoneMuted;

- (BOOL)setLoudSpeakerEnabled:(BOOL)enabled;
- (BOOL)isLoudSpeakerEnabled;

- (void)updateOrientation:(UIDeviceOrientation)orientation;

- (void)setLocalVideoView:(UIView *)localVideoView;
- (void)setRemoteVideoView:(UIView *)remoteVideoView;

@end
