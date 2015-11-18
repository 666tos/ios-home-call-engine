//
//  Sound.m
//  NGT International B.V.
//
//  Created by Joost de Moel on 2/26/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import "Sound.h"
#import "common.h"
//#import "iOBackendAPI.h"
//#import "Utilities.h"

#import <AVFoundation/AVFoundation.h>

#define MUTE_DETECTION_TIME       0.2f
#define MUTE_DETECTION_DELAY_TIME 1.0f

@interface Sound()
{
@private
    SoundID                     _soundID;
    NSString *                  _filename;
    NSURL *                     _fileURL;
    CFURLRef		            _soundFileURLRef;
    SystemSoundID               _soundFileObject;
    BOOL                        _vibrate;
    BOOL                        _loop;
    NSDate*                     _timeSincePlaybackStarted;
}

@property (strong, nonatomic) dispatch_queue_t loopQueue;

@end

@implementation Sound

@synthesize filename           = _filename;

/********************************************************************************************/
/* Initialization                                                                           */
/********************************************************************************************/

#pragma mark - Initialization

- (id)initWithID:(SoundID)soundID withFileName:(NSString*)filename loopQueue:(dispatch_queue_t)queue;
{
    if (self = [super init])
    {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
        
        if (!filePath)
        {
            return nil;
        }
        
        _soundID                = soundID;
        _filename               = [filename retain];
        _fileURL                = [[NSURL fileURLWithPath:filePath isDirectory:NO] retain];
        _vibrate                = NO;
        _loop                   = NO;
        _timeSincePlaybackStarted = nil;
        
        self.loopQueue = (queue) ? : dispatch_get_main_queue();
        
        // Create a system sound object representing the sound file.
        _soundFileURLRef = (CFURLRef) [_fileURL retain];
        AudioServicesCreateSystemSoundID(_soundFileURLRef, &_soundFileObject);
    }
    
    return self;
}

- (void)dealloc
{
    [_fileURL release];
    [_filename release];
    
    AudioServicesRemoveSystemSoundCompletion(_soundFileObject);
    AudioServicesDisposeSystemSoundID (_soundFileObject);
    CFRelease (_soundFileURLRef);
    
    [super dealloc];
}


/********************************************************************************************/
/* Public methods                                                                           */
/********************************************************************************************/

#pragma mark - Public methods

/**
 * Plays the sound
 * @return YES if the sound is playing, NO if it's not due to an error
 */

- (BOOL)playWithVibration:(BOOL)vibrate withLoop:(BOOL)loop
{
    @synchronized(self)
    {
        // There might be a callback active, cancel it
        AudioServicesRemoveSystemSoundCompletion(_soundFileObject);
        
        // Save vibrate request for loop
        _vibrate = vibrate;
        
        // Save loop request for loop
        _loop = loop;
        
        DLOG(DEFAULT, "Playing sound %@ (%u) with vibration %d and loop %d", _filename, (unsigned int)_soundFileObject, vibrate, _loop);
        if (_vibrate)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        // Schedule loop callback if necessary.
        if (_loop)
        {
            OSStatus result =  AudioServicesAddSystemSoundCompletion(_soundFileObject, NULL, NULL, completionCallbackBackend, (__bridge void *)self);
            
            if (result != 0)
            {
                NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:nil];
                DLOG(DEFAULT, "Playing sound %@ (%u) with vibration %d and loop %d failed with error: %@", _filename, (unsigned int)_soundFileObject, vibrate, _loop, error);
            }
        }
    
        // And play the sound
        AudioServicesPlaySystemSound (_soundFileObject);
        
        // Save this timestamp so we can detect mute switch=on
        [self savePlaybackStartedTimestamp];
        return TRUE;
    }
}

- (BOOL)playWithVibration:(BOOL)vibrate withLoop:(BOOL)loop loopQueue:(dispatch_queue_t)loopQueue
{
    self.loopQueue = loopQueue;
    return [self playWithVibration:vibrate withLoop:loop];
}

- (BOOL)stop
{
    @synchronized(self)
    {
        DLOG(DEFAULT, "Stopping sound %@ (%u)", _filename,  (unsigned int)_soundFileObject);
        
        _vibrate = NO;
        _loop = NO;
        
        // There might be a callback active, cancel it
        AudioServicesRemoveSystemSoundCompletion(_soundFileObject);
        
        // Also cancel this request
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartLoopAfterDelay) object:nil];
        
        // Reset timestamp
        [self resetPlaybackStartedTimestamp];
        
        // Ugly hack, dispose of this sound ID to stop it
        AudioServicesDisposeSystemSoundID(_soundFileObject);
        
        // Create a new sound ID for the next time we want to play this sound
        AudioServicesCreateSystemSoundID(_soundFileURLRef, &_soundFileObject);
        
        DLOG(DEFAULT, "Recreated sound %@ (%u)", _filename,  (unsigned int)_soundFileObject);
        
        return YES;
    }
}

#pragma mark - Callback functions

static void completionCallbackBackend(SystemSoundID soundID, void* myself)
{
    // Remove just to be sure
    AudioServicesRemoveSystemSoundCompletion(soundID);
    
    Sound *self = (__bridge Sound *)myself;
    dispatch_async(self.loopQueue, ^
    {
        [self playFinished:soundID];
    });
}


- (void)playFinished:(SoundID)soundID
{
    @synchronized(self)
    {
        DLOG(DEFAULT, "Finished playback of sound %@ (callback=%u, current=%u)", _filename, (unsigned int)soundID, (unsigned int)_soundFileObject);

        // Only loop when it is requested and this callback matches the current sound ID
        if ((_loop) && (soundID == _soundFileObject))
        {
            if ([self calculatePlaybackStartedDuration] < MUTE_DETECTION_TIME)
            {
                DLOG(DEFAULT, "Detected mute switch enabled, delaying next loop iteration for %0.02f seconds", MUTE_DETECTION_DELAY_TIME);
                [self performSelector:@selector(restartLoopAfterDelay) withObject:nil afterDelay:MUTE_DETECTION_DELAY_TIME];
            }
            else
            {
                [self playWithVibration:_vibrate withLoop:YES];
            }
        }
        else
        {
            DLOG(DEFAULT, "Stopping loop");
        }
    }
}

-(void)restartLoopAfterDelay
{
    @synchronized(self)
    {
        if (_loop)
        {
            [self playWithVibration:_vibrate withLoop:YES];
        }
    }
}

#pragma mark - Timestamp calculation

-(void)savePlaybackStartedTimestamp
{
    SAFE_RELEASE(_timeSincePlaybackStarted);
    _timeSincePlaybackStarted = [[NSDate date] retain];
}

-(void)resetPlaybackStartedTimestamp
{
    SAFE_RELEASE(_timeSincePlaybackStarted);
}

- (NSTimeInterval)calculatePlaybackStartedDuration
{
    if (_timeSincePlaybackStarted == nil)
    {
        return 0.0f;
    }
    
    NSDate *       nowDate = [[NSDate alloc] init];
    NSTimeInterval diffInterval = [nowDate timeIntervalSinceDate:_timeSincePlaybackStarted];
    [nowDate release];
    return diffInterval;
}


@end
