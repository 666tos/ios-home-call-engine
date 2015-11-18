//
//  AudioSessionInterruptionNotification.m
//  NGT International B.V.
//
//  Created by Mariano Arselan on 9/22/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

#import "AudioSessionInterruptionNotification.h"
#import "NSNotificationAdditions.h"

@implementation AudioSessionInterruptionNotification

static NSString *const kBackendNotificationAudioSessionInterruption = @"kBackendNotificationAudioSessionInterruption";

- (id)initWithInterruptionState:(UInt32)anInterruptionState;
{
    if (self = [super initWithName:kBackendNotificationAudioSessionInterruption object:nil userInfo:nil])
    {
        self.interruptionState = anInterruptionState;
    }
    
    return self;
}

+ (void)notifyAudioSessionInterruptionStateChanged:(UInt32)anInterruptionState
{
    AudioSessionInterruptionNotification *notification = [[AudioSessionInterruptionNotification alloc] initWithInterruptionState:anInterruptionState];

    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:notification];
    [notification release];
}

+ (NSDictionary *)internal_notificationsDictionary
{
    return @{kBackendNotificationAudioSessionInterruption : [NSValue valueWithPointer:@selector(audioSessionInterruptionStateChanged:)]};
}

+ (Protocol *)notificationObserverProtocol
{
    return @protocol(AudioSessionInterruptionObserver);
}

@end


