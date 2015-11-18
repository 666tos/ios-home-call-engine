//
//  AudioSessionManager.h
//  NGT International B.V.
//
//  Created by Mariano Arselan on 9/22/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioSession.h>

typedef NS_ENUM(NSUInteger, AudioSessionRoute)
{
    AudioSessionRouteLoudspeaker = 0,
    AudioSessionRouteReceiver,
    AudioSessionRouteHeadphones,
    AudioSessionRouteBluetoothHeadset
};

extern NSString * const kAudioSessionManagerActiveAudioRouteKey;

@interface AudioSessionManager : NSObject <AVAudioSessionDelegate>

+ (AudioSessionManager *)sharedInstance;

- (BOOL)setSpeakerByDefault:(BOOL)enable;

- (void)enableBTdevice;

@property (nonatomic, assign, readonly) NSUInteger numberOfAudioRoutes;
@property (nonatomic, assign, readonly) AudioSessionRoute activeAudioRoute;

- (NSUInteger)numberOfAudioRoutesRefreshed:(BOOL)refreshed;
- (AudioSessionRoute)activeAudioRouteRefreshed:(BOOL)refreshed;

@property (nonatomic, assign) BOOL forceLoudspeaker;

@end
