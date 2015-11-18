/*
 *--------------------------------------------------------------------------------------------------
 * Filename: SoundPlayer.h
 *--------------------------------------------------------------------------------------------------
 *
 * Revision History:
 *
 *								Modification     Tracking
 * Author						Date             Number			Description of Changes
 * --------------------			------------     ---------		----------------------------------------
 * Roman Alarcon				2008-09-25						File Created.
 *
 *
 * Copyright  2008 NGT International B.V. All rights reserved.
 */

/**
 * General Description:
 * @author Roman Alarcon
 */

#import <Foundation/Foundation.h>
#import "SoundTypes.h"

@interface SoundPlayer : NSObject;

+ (SoundPlayer *)getInstance;

- (instancetype)initWithLoopQueue:(dispatch_queue_t)loopQueue;


- (NSString *)getFileName:(SoundID)soundID;
- (Float64)getFileLength:(SoundID)soundID;

- (void)playWithVibration:(SoundID)soundID;
- (void)playWithoutVibration:(SoundID)soundID;
- (void)playWithoutVibration:(SoundID)soundID withLoop:(BOOL)loop;
- (void)playWithoutVibration:(SoundID)soundID withLoop:(BOOL)loop loopQueue:(dispatch_queue_t)loopQueue;

- (BOOL)stop:(SoundID)soundID;

@end


