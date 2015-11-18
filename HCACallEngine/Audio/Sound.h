//
//  SoundInLoop.h
//  NGT International B.V.
//
//  Created by Joost de Moel on 2/26/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SoundTypes.h"

@interface Sound : NSObject

@property (nonatomic, readonly) NSString*       filename;

/*
 @param queue The queue will be used to relaunch sound playing if asked. If queue == NULL then main queue will be used
 */
- (id)initWithID:(SoundID)soundID withFileName:(NSString*)filename loopQueue:(dispatch_queue_t)queue;

- (BOOL)playWithVibration:(BOOL)vibrate withLoop:(BOOL)loop;
- (BOOL)playWithVibration:(BOOL)vibrate withLoop:(BOOL)loop loopQueue:(dispatch_queue_t)loopQueue;
- (BOOL)stop;
@end
