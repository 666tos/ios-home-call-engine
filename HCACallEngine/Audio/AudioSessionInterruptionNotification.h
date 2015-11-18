//
//  AudioSessionInterruptionNotification.h
//  NGT International B.V.
//
//  Created by Mariano Arselan on 9/22/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

#import "iOBaseNofitication.h"


@class AudioSessionInterruptionNotification;

@protocol AudioSessionInterruptionObserver
- (void)audioSessionInterruptionStateChanged:(AudioSessionInterruptionNotification *)notification;
@end

@interface AudioSessionInterruptionNotification : iOBaseNofitication

@property (nonatomic) UInt32 interruptionState;

+ (void)notifyAudioSessionInterruptionStateChanged:(UInt32)anInterruptionState;

@end

@interface AudioSessionInterruptionNotification(Override)

+ (void)addObserver:(id<AudioSessionInterruptionObserver>)observer;
+ (void)removeObserver:(id<AudioSessionInterruptionObserver>)observer;

@end


