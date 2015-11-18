//
//  AudioSessionManager.m
//  NGT International B.V.
//
//  Created by Mariano Arselan on 9/22/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

#import "AudioSessionManager.h"

#import <HomeCenterXMPP/DDLog.h>
#import <HomeCenterXMPP/DDASLLogger.h>

#import <AudioToolbox/AudioToolbox.h>

//#import "AudioSessionInterruptionNotification.h"
#import "common.h"
//#import "Utilities.h"
#import "CompilerUtils.h"
//#import "iOBackendAPI.h"
#import "DeviceUtils.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

// Using the deprecated API for now. We can't use the new ones yet. Will need a linphone update and some refactoring
#define USE_DEPRECATED_APIS     1

NSString *const kAudioSessionManagerActiveAudioRouteKey = @"activeAudioRoute";

@interface AudioSessionManager ()

@property (nonatomic, assign, readwrite) AudioSessionRoute activeAudioRoute;

@end


@implementation AudioSessionManager

static AudioSessionManager *_sharedInstance = nil;

/********************************************************************************************/
/* Initialization                                                                           */
/********************************************************************************************/

#pragma mark - Initialization

//not thread safe
+ (AudioSessionManager *)sharedInstance
{
    if (!_sharedInstance)
    {
        _sharedInstance = [[AudioSessionManager alloc] init];
    }
    return _sharedInstance;
}


- (id)init
{
    if (self = [super init])
    {
        DLOG(JINGLE, "INIT AudioSessionManager");
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        
        // Listen for interruptions (hold scenario)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
        
        // Set it right from the start
        // TODO: if we disable playing ringtones on linphone AQ engine, we can probably remove this statement
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        if (error)
        {
            ELOG(JINGLE, "cannot set category on AVAudioSession [%@]", error);
        }
        
        error = nil;
        [audioSession setActive:NO error: &error];
        
        if (error)
        {
            ELOG(JINGLE, "cannot deactivate AVAudioSession [%@]", error);
        }
        
        // enable bluetooth
        [self enableBTdevice];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

/********************************************************************************************/
/* Public methods                                                                           */
/********************************************************************************************/

#pragma mark - Public methods

- (BOOL)setSpeakerByDefault:(BOOL)setToSpeaker
{
#ifdef USE_DEPRECATED_APIS
    COMPILER_UTILS_SUPPRESS_DEPRECATION(
    {
        UInt32 enableSpeaker = setToSpeaker;
        OSStatus status = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(enableSpeaker), &enableSpeaker);
        
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        
        DLOG(JINGLE, "Set default route to speaker (%@), result=%ld [%@], error: %@", setToSpeaker ? @"YES" : @"NO", (long)status, [self.class OSStatusToStr:status], error);
        return (status == kAudioSessionNoError);
    });
#else
    return [self setAudioCategoryOption:AVAudioSessionCategoryOptionDefaultToSpeaker set:setToSpeaker];
#endif
}

/********************************************************************************************/
/* AudioSessionPropertyListener                                                             */
/********************************************************************************************/

#pragma mark - AudioSessionPropertyListener

- (AudioSessionRoute)routeForOutputPort:(AVAudioSessionPortDescription *)portDescription
{
    DLOG(JINGLE, "portDescription %@ name %@ type %@", portDescription, portDescription.portName, portDescription.portType);
    
    NSArray *bluetoothPorts =  @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothHFP /*, AVAudioSessionPortBluetoothLE, AVAudioSessionPortCarAudio*/]; // NIPH-2840;
    AudioSessionRoute route = AudioSessionRouteHeadphones; //Line-out, headphones and HDMI
    
    if ([bluetoothPorts containsObject:portDescription.portType])
    {
        route = AudioSessionRouteBluetoothHeadset;
    }
    else if ([portDescription.portType isEqualToString:AVAudioSessionPortBuiltInReceiver])
    {
        route = AudioSessionRouteReceiver;
    }
    else if ([portDescription.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker])
    {
        route = AudioSessionRouteLoudspeaker;
    }

    return route;
}

- (AudioSessionRoute)routeForInputPort:(AVAudioSessionPortDescription *)portDescription
{
    NSArray *bluetoothPorts =  @[AVAudioSessionPortBluetoothHFP /*, AVAudioSessionPortCarAudio */]; // NIPH-2840
    AudioSessionRoute route = AudioSessionRouteHeadphones; //Line-out, headphones and HDMI
    
    if ([bluetoothPorts containsObject:portDescription.portType])
    {
        route = AudioSessionRouteBluetoothHeadset;
    }
    else if ([portDescription.portType isEqualToString:AVAudioSessionPortBuiltInMic])
    {
        route = AudioSessionRouteReceiver;
    }
    
    return route;
}

- (void)updateActiveAudioRoute
{
    AVAudioSessionRouteDescription *routeDescription = [[AVAudioSession sharedInstance] currentRoute];
    AVAudioSessionPortDescription *portDescription = routeDescription.outputs.lastObject;
    
    DLOG(JINGLE, "Current audio route is [%@]", portDescription.portType);
    
    self.activeAudioRoute = [self routeForOutputPort:portDescription];
}

- (void)updateNumberOfAudioRoutes
{
    NSInteger numberOfAvailableInputs = [[AVAudioSession sharedInstance] availableInputs].count;
    
    if (RUNNING_ON_IPAD || RUNNING_ON_IPOD_TOUCH)
    {
        //For iPod and iPad:
        //1 input - loudspeaker
        //2 inputs - loudspeaker and headphones or bluetooth
        //3 inputs - loudspeaker, headphones and bluetooth
        
        _numberOfAudioRoutes = numberOfAvailableInputs;
    }
    else
    {
        //For iPhone:
        //1 input - loudspeaker and receiver
        //2 inputs - loudspeaker, receiver and headphones or bluetooth
        //3 inputs - loudspeaker, receiver, headphones and bluetooth
        
        _numberOfAudioRoutes = 2;
        
        for (AVAudioSessionPortDescription *portDesc in [[AVAudioSession sharedInstance] availableInputs])
        {
            AudioSessionRoute route = [self routeForInputPort:portDesc];
            
            if (route == AudioSessionRouteBluetoothHeadset)
            {
                _numberOfAudioRoutes++;
            }
        }
    }
}

- (NSUInteger)numberOfAudioRoutesRefreshed:(BOOL)refreshed
{
    if (refreshed)
    {
        [self updateNumberOfAudioRoutes];
    }
    
    return _numberOfAudioRoutes;
}

- (AudioSessionRoute)activeAudioRouteRefreshed:(BOOL)refreshed
{
    if (refreshed)
    {
        [self updateActiveAudioRoute];
    }
    
    return _activeAudioRoute;
}


#pragma mark -
#pragma mark AVAudioSessionRouteChangeNotification, replaces AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange...) starting in IOS6 (used in hold)

- (void)handleRouteChange:(NSNotification*)notification
{
    DLOG(JINGLE, "Route change!");
    
    AVAudioSessionRouteChangeReason reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] intValue];
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonUnknown:
            DLOG(JINGLE, "Reason: AVAudioSessionRouteChangeReasonUnknown");
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            DLOG(JINGLE, "Reason: AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            DLOG(JINGLE, "Reason: AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            DLOG(JINGLE, "Reason: AVAudioSessionRouteChangeReasonCategoryChange");
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
            DLOG(JINGLE, "Reason: AVAudioSessionRouteChangeReasonOverride");
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            DLOG(JINGLE, "Reason: AVAudioSessionRouteChangeReasonWakeFromSleep");
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            DLOG(JINGLE, "Reason: AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            break;
            
        default:
            DLOG(JINGLE, "Reason: UNKNOWN");
            break;
    }
    
    
    
    [self updateNumberOfAudioRoutes];
    [self updateActiveAudioRoute];
    
//    // As part of NIPH-1873 I noticed that on the second and later calls the bluetooth headset audio reverts back to internal mic
//    // It seems to be forgotten once Linphone destroys the AudioSession so we re-enable it here for AudioSession scenario only (event sounds work fine)
    
    BOOL shouldEnableBT = (self.activeAudioRoute != AudioSessionRouteBluetoothHeadset);
    
    //Since there is only 1 possible route by default on iPad,
    //we should try to enable BT even when (activeAudioRoute == AudioSessionRouteLoudspeaker)
    if (!RUNNING_ON_IPAD)
    {
        shouldEnableBT = (self.activeAudioRoute != AudioSessionRouteLoudspeaker);
    }
    
    if (shouldEnableBT)
    {
        [self enableBTdevice];
    }
    
    // Fix up loudspeaker on iphone
    if (!RUNNING_ON_IPAD)
    {
        if ((self.forceLoudspeaker) && (_activeAudioRoute != AudioSessionRouteLoudspeaker) && (_activeAudioRoute != AudioSessionRouteHeadphones))
        {
            DLOG(JINGLE, "Re-forcing loudspeaker");
            AVAudioSession* session = [AVAudioSession sharedInstance];
            NSError* error;
            
            BOOL success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                                      error:&error];
            
            if (!success)
            {
                ELOG(JINGLE, "AVAudioSession error overrideOutputAudioPort: %@",error);
            }
        }
    }
}

- (void)setForceLoudspeaker:(BOOL)forceLoudspeaker
{
    DLOG(JINGLE, "Forcing loudspeaker: %d", forceLoudspeaker);

    if (_forceLoudspeaker != forceLoudspeaker)
    {
        BOOL success = YES;
        
        if (_activeAudioRoute == AudioSessionRouteHeadphones)
        {
            DLOG(JINGLE, "Remembering loudspeaker activation but ignoring for now because currently on headphones");
            return;
        }
        
        [self setSpeakerByDefault:NO];
        
#ifdef USE_DEPRECATED_APIS
        COMPILER_UTILS_SUPPRESS_DEPRECATION(
        {
            UInt32 audioRouteOverride = forceLoudspeaker ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
            OSStatus status = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
            
            if (status)
            {
                ELOG(JINGLE, "Failed to force loudspeaker to %@ [%ld] [%@]", forceLoudspeaker ? @"YES" : @"NO", (long)status, [self.class OSStatusToStr:status]);
                success = NO;
            }
        });
#else
        AVAudioSessionPortOverride override = forceLoudspeaker ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        
        NSError * error;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        success = [audioSession overrideOutputAudioPort:override error:&error];
        if (!success)
        {
            ELOG(JINGLE, "Failed to force loudspeaker to %@. Error: %@", forceLoudspeaker ? @"YES" : @"NO", [error localizedDescription]);
        }
#endif
        
        if (success)
        {
            _forceLoudspeaker = forceLoudspeaker;
        }
    }
}

#pragma mark -
#pragma mark AVAudioSessionInterruptionNotification, replaces AVAudioSessionDelegate starting in IOS6 (used in hold)

- (void)handleInterruption:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    AVAudioSessionInterruptionType interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan)
    {
        DLOG(JINGLE, "signalling beginInterruption");
#warning Fix it!
//        [AudioSessionInterruptionNotification notifyAudioSessionInterruptionStateChanged:AVAudioSessionInterruptionTypeBegan];
    }
    else if (interuptionType == AVAudioSessionInterruptionTypeEnded)
    {
        DLOG(JINGLE, "signalling endInterruption");
#warning Fix it!
//        [AudioSessionInterruptionNotification notifyAudioSessionInterruptionStateChanged:AVAudioSessionInterruptionTypeEnded];
    }
}

#pragma mark - Bluetooth support

// This is the NGTI version, linphone bluetooth code wasn't working properly for me
// We enable bluetooth only once and then leave it up to the OS
- (void)enableBTdevice
{
    if(![[NSThread currentThread] isMainThread])
    {
        [self performSelectorOnMainThread:@selector(enableBTdevice) withObject:nil waitUntilDone:NO];
    }
    else
    {
#ifdef USE_DEPRECATED_APIS
        COMPILER_UTILS_SUPPRESS_DEPRECATION(
        {
            UInt32 allowBluetoothInput = 1;
            OSStatus stat = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, sizeof (allowBluetoothInput), &allowBluetoothInput);
            
            if (stat)
            {
                ELOG(JINGLE, "Failed to enable bluetooth [%ld] [%@]", (long)stat, [self.class OSStatusToStr:stat]);
            }
        });
#else
        [self setAudioCategoryOption:AVAudioSessionCategoryOptionAllowBluetooth set:YES];
#endif
    }
}

/********************************************************************************************/
/* Private methods                                                                          */
/********************************************************************************************/

#pragma mark - Private methods

+ (NSString *)OSStatusToStr:(OSStatus)st
{
    switch (st)
    {
        case kAudioSessionNoError: return @"AudioSessionNoError";
        case kAudioSessionNotInitialized: return @"kAudioSessionNotInitialized";
        case kAudioSessionAlreadyInitialized: return @"kAudioSessionAlreadyInitialized";
        case kAudioSessionInitializationError: return @"kAudioSessionInitializationError";
        case kAudioSessionUnsupportedPropertyError: return @"kAudioSessionUnsupportedPropertyError";
        case kAudioSessionBadPropertySizeError: return @"kAudioSessionBadPropertySizeError";
        case kAudioSessionNotActiveError: return @"kAudioSessionNotActiveError";
        case kAudioServicesNoHardwareError: return @"kAudioServicesNoHardwareError";
        case kAudioSessionNoCategorySet: return @"kAudioSessionNoCategorySet";
        case kAudioSessionIncompatibleCategory: return @"kAudioSessionIncompatibleCategory";
        case kAudioSessionUnspecifiedError: return @"kAudioSessionUnspecifiedError";
            
        default:
            return @"unknown error";
    }
}

+ (NSString *)OSCategoryOptionToStr:(AVAudioSessionCategoryOptions)option
{
    switch (option)
    {
        case AVAudioSessionCategoryOptionMixWithOthers: return @"AVAudioSessionCategoryOptionMixWithOthers";
        case AVAudioSessionCategoryOptionDuckOthers: return @"AVAudioSessionCategoryOptionDuckOthers";
        case AVAudioSessionCategoryOptionAllowBluetooth: return @"AVAudioSessionCategoryOptionAllowBluetooth";
        case AVAudioSessionCategoryOptionDefaultToSpeaker: return @"AVAudioSessionCategoryOptionDefaultToSpeaker";
        default:
            return @"unknown option";
    }
}

/**
 * @return NO on failure. Some options might not be set in the current audio category
 */
- (BOOL)setAudioCategoryOption:(AVAudioSessionCategoryOptions)option set:(BOOL)set
{
    NSError * error;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSString * category = audioSession.category;
    AVAudioSessionCategoryOptions categoryOptions = audioSession.categoryOptions;
    
    if (set)
    {
        categoryOptions |= option;
    }
    else
    {
        categoryOptions &= ~option;
    }
    
    BOOL success = [audioSession setCategory:category withOptions:categoryOptions error:&error];
    if (!success)
    {
        ELOG(JINGLE, "Failed set audio category option %@ to %@. Error: %@", [self.class OSCategoryOptionToStr:option], set ? @"YES" : @"NO", [error localizedDescription]);
        return NO;
    }
    else
    {
        DLOG(JINGLE, "Enable set audio category option %@ to %@", [self.class OSCategoryOptionToStr:option], set ? @"YES" : @"NO");
    }
    
    return YES;
}

@end
