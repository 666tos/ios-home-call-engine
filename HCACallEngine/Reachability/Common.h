/*
 *  Common.h
 *  Utils
 *
 *  Created by Boris Godin on 7/30/10.
 *  Copyright 2010 NGT International B.V. All rights reserved.
 *
 */


/// Log enabling/disabling for components.
typedef enum
{
    DEFAULT = 1,
    NET,
    JINGLE,
    P2P,
    XMPP,
    UI,
    DB,
    LOGIN,
    AVATAR,
    VIDEO,
    SESSION,
    ABOOK,
    BACKGROUNDMODE,
    LINPHONE,
    INAPPPURCHASE,
    // You can add more log components, before LOG_COMPONENTS_COUNT.
    LOG_COMPONENTS_COUNT
} LogComponent;

#import <Foundation/Foundation.h>
#import "MacrosUtils.h"
//// Extended classes
//#import "NSStringExtended.h"
//#import "NSArrayExtended.h"
//#import "NSDictionaryExtended.h"
//#import "NSDataExtended.h"


// Note that this file will be included only in DEBUG mode.
#ifdef DEBUG
#   include "UserLogConfig.h"
#endif

#define MAKE_FLAG(enum_value)      (1<<(enum_value))



// Gets the name of a classes propery at compile time
// This is for cases where a propery name is needed, to be able to ensure at compile time that a certain propery exists,
// like:        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:KeyName(ConversationItem, timestamp) ascending:YES];
// instead of:  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
#define KeyName(class, key)      ([(class *)nil key] ? @#key : @#key)

//
// Logging options
// ----------------
//
// in RELEASE builds:
//    logging should be enabled via the dial pad (enter "enableconsolenow"). The 'DLOG' statement does nothing in release builds
//
// In DEBUG builds:
//    WLOG, ELOG and FLOG always give output in DEBUG builds.
//    DLOG and LOG only do something if the corresponding COMPONENT is enabled. You can do that in 'UserLogConfig.h'
//
// DLOG      For debugging.
// LOG       For normal, non-error logging that we want to have in release builds as well (if enabled)
// WLOG      For warnings
// ELOG      For recoverable errors
// FLOG      For unrecoverable errors



// Logs with type >= INFO are enabled for RELEASE mode.
// Don't use this enum directly, but use defines FLOG, ELOG, WLOG, LOG, DLOG.
typedef enum
{
    DBG,          ///< Debug info, used in debug mode only.
    INFO,         ///< Normal info, with more priority than DEBUG message.
    WARNING,      ///< WARNING: like unknown stanza received.
    ERROR,        ///< Recoverable errors, like when when call cannot be established.
    FATAL,        ///< Unrecoverable error, like when alloc returns NULL.
} LogType;


#define setFrame(obj,frame) DASSERT(obj); DASSERT(!CGRectIsNull(frame)); [obj setFrame:frame];

#define _LOG_(type, component, ...)    [[IPhoneLogger instance] log:type withComponent:component tStr : (# type ", ")cStr : (# component ": ")fStr : __FUNCTION__ withString :[NSString stringWithFormat:@__VA_ARGS__]]
#define LOG_TO_CONSOLE


#ifdef NO_LOG
#   define LOG(...)
#   define FLOG(...)
#   define ELOG(...)
#   define WLOG(...)
#   define IS_LOGGING_ENABLED             NO
#else
#   define LOG(...)                       _LOG_(INFO, __VA_ARGS__)
#   define FLOG(...)                      _LOG_(FATAL, __VA_ARGS__)
#   define ELOG(...)                      _LOG_(ERROR, __VA_ARGS__)
#   define WLOG(...)                      _LOG_(WARNING, __VA_ARGS__)
#ifdef DEBUG
#   define IS_LOGGING_ENABLED             YES
#else
#   define IS_LOGGING_ENABLED             ([IPhoneLogger instance].enableLogging)
#endif
#endif // NO_LOG

#ifdef DEBUG
#   include <assert.h>
#   define DASSERT(e)                     assert(e)
#   define LOG_ENABLE(component)          [[IPhoneLogger instance] enableLogFor:component]
#   define LOG_DISABLE(component)         [[IPhoneLogger instance] disableLogFor:component]
#   define LOG_IS_ENABLED(component)      [[IPhoneLogger instance] isLogEnabledFor:component]
#   ifdef NO_LOG
#      define DLOG(...)
#   else
#      define DLOG(...)                      _LOG_(DBG, __VA_ARGS__)
#   endif // NO_LOG
#else // RELEASE configuration.
#   define DASSERT(e)
#   define DLOG(component, ...)
#   define LOG_ENABLE(component)
#   define LOG_DISABLE(component)
#   define LOG_IS_ENABLED(component)
#   define ENABLED_LOG_COMPONENTS         -1
#endif


/**
 * Release the memory pointed to by __POINTER and set __POINTER to nil.
 */

#if __has_feature(objc_arc)
#   define SAFE_RELEASE(__POINTER) {}
#else
#   define SAFE_RELEASE(__POINTER) { if (__POINTER) {[__POINTER release]; __POINTER = nil; } \
}
#endif



/**
 * Do not use this class directly. Instead use defines.
 */
@interface IPhoneLogger : NSObject

/**
 * Get static instance of logger. Do not release.
 */
+ (IPhoneLogger *)instance;

 /**
  * Log with type, component, type string, component string, function name and following NSString str.
  */
- (void)log:(LogType)type withComponent:(LogComponent)component tStr:(const char *)tStr cStr:(const char *)cStr fStr:(const char *)fStr withString:(NSString *)str;

/**
 * Intended for use in release builds, to enable logging (of level 'INFO' and higher only)
 */
@property (nonatomic) BOOL  enableLogging;

@end

#ifdef DEBUG

@interface IPhoneLogger(DebugFunctionality)

/**
 * Enable log for component.
 */
- (void)enableLogFor:(LogComponent)component;

/**
 * Disable log for component.
 */
- (void)disableLogFor:(LogComponent)component;

/**
 * Return YES if log is enabled for component.
 */
- (BOOL)isLogEnabledFor:(LogComponent)component;

@end

#endif
