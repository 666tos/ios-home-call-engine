//
//  Timer.h
//  iO
//
//  Created by Joost de Moel on 9/2/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Timer;

@protocol TimerListener

	/**
     * This method will be called when timeout of 'timer' is produced.
     */
    - (void)handleTimeoutOfTimer:(Timer*)timer;
@end

@interface Timer : NSObject

- (id)initWithDelegate:(id<TimerListener>)delegate;

- (void)startWithInterval:(NSTimeInterval)interval;
- (NSTimeInterval)timePassed;
- (void)stop;
- (void)timeout;

+ (NSInteger)getMillisecondsOfTimeInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)getTimeIntervalWithMilliseconds:(NSInteger)milliseconds;

@end

