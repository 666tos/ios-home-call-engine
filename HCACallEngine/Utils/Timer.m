//
//  Timer.m
//  iO
//
//  Created by Joost de Moel on 9/2/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#if !__has_feature(objc_arc) 
#error "ARC is required" 
#endif

#import "Timer.h"

#import "Common.h"

@interface Timer()
{
@protected
	CFAbsoluteTime      _startTime;
}

@property (weak, nonatomic) id<TimerListener> delegate;

@end

@implementation Timer

- (id)initWithDelegate:(id<TimerListener>)delegate
{
	if (self = [super init])
    {
		self.delegate = delegate;
	}
	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)startWithInterval:(NSTimeInterval)interval
{
	DASSERT(interval > 0);
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(timeout) withObject:nil afterDelay:interval];
	_startTime = CFAbsoluteTimeGetCurrent();
}

- (NSTimeInterval)timePassed
{
	return CFAbsoluteTimeGetCurrent() - _startTime;
}

- (void)stop
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)timeout
{
	[self.delegate handleTimeoutOfTimer:self];
}

+ (NSInteger)getMillisecondsOfTimeInterval:(NSTimeInterval)interval
{
    return (NSInteger)(interval * 1000.0f);
}

+ (NSTimeInterval)getTimeIntervalWithMilliseconds:(NSInteger)milliseconds
{
    return (NSTimeInterval)(milliseconds / 1000.0f);
}
@end

