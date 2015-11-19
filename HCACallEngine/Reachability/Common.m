/*
 *  Common.m
 *  Utils
 *
 *  Created by Boris Godin on 8/5/10.
 *  Copyright 2010 NGT International B.V. All rights reserved.
 *
 */

#include <stdarg.h>
#include <string.h>

#include "Common.h"

@interface IPhoneLogger()
{
    volatile unsigned long _enabledComponents; // Logger components that are enabled. Volatile is for atomic operations.
}
@end

static IPhoneLogger *logger = nil;

@implementation IPhoneLogger

+ (IPhoneLogger *)instance
{
    if (logger == nil)
    {
        logger = [[IPhoneLogger alloc] initWithComponents:(LogComponent)ENABLED_LOG_COMPONENTS, (LogComponent)0];
    }
    return logger;
}


- (id)initWithComponents:(LogComponent)first,...
{
    if (self = [super init])
    {
        va_list      args;
        va_start(args, first);
        LogComponent value = (LogComponent)first;
        do
        {

            if ((int)value == -1)
            {
                _enabledComponents = (LogComponent)-1;
                break;
            }

            [self enableLogFor:value];
            value = va_arg(args, LogComponent);

        }
        while ((int)value != 0);
        va_end(args);
    }

    return self;
}

- (void)enableLogFor:(LogComponent)component
{
    _enabledComponents |= MAKE_FLAG(component-1);
}


- (void)disableLogFor:(LogComponent)component
{
    _enabledComponents &= ~MAKE_FLAG(component-1);
}


- (BOOL)isLogEnabledFor:(LogComponent)component
{
    return ((_enabledComponents & MAKE_FLAG(component-1)) != 0);
}


- (void)log:(LogType)type withComponent:(LogComponent)component tStr:(const char *)tStr cStr:(const char *)cStr fStr:(const char *)fStr withString:(NSString *)str
{
    if (
#ifndef DEBUG
        self.enableLogging && type >= INFO
#else
        (type >= WARNING) || (_enabledComponents & MAKE_FLAG(component-1)) != 0
#endif
        )
    {
        if (component == DEFAULT)
        {
            cStr = "";
        }
        if (type == DBG)
        {
            tStr = "";
        }

#ifdef LOG_TO_CONSOLE
        NSLog(@"%s%s%s. %@", tStr, cStr, fStr, str);
#endif
    }
}


@end
