/*
 *--------------------------------------------------------------------------------------------------
 * Filename: SoundPlayer.h
 *--------------------------------------------------------------------------------------------------
 *
 * Revision History:
 *
 *                             Modification     Tracking
 * Author                      Date             Number       Description of Changes
 * --------------------        ------------     ---------    ----------------------------------------
 * Roman Alarcon               2008-09-25                    File Created.
 *
 *
 * Copyright  2008 NGT International B.V. All rights reserved.
 */

//#import "ApplicationController.h"
#import "SoundPlayer.h"
#import "Sound.h"
#import "Common.h"
//#import "Utilities.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface SoundPlayer()
{
@private
    NSMutableDictionary *_soundMapping;
}

- (void)loadSound:(SoundID)soundId withFilename:(NSString *)filename;

@property (strong, nonatomic) dispatch_queue_t loopQueue;

@end

@implementation SoundPlayer

/********************************************************************************************/
/* Initialization                                                                           */
/********************************************************************************************/

#pragma mark - Initialization

+ (SoundPlayer *)getInstance
{
    static SoundPlayer *instance = nil;

    if (instance == nil)
    {
        instance = [[SoundPlayer alloc] init];
    }

    return instance;
}

- (instancetype)initWithLoopQueue:(dispatch_queue_t)loopQueue
{
    self = [self init];
    if (self)
    {
        self.loopQueue = loopQueue;
    }
    return self;
}

- (id)init
{
    if ((self = [super init]))
    {
        _soundMapping = [[NSMutableDictionary alloc] init];

        [self loadSound:MESSAGE_RECEIVED_SOUND withFilename:@"received.caf"];
        [self loadSound:MESSAGE_SENT_SOUND withFilename:@"sent.caf"];
        
        // BEN: Used for incoming push call (length 21s, contains multiple ringtone sounds)
        [self loadSound:INCOMING_CALL_LOCAL_NOTIFICATION withFilename:@"call_ln.caf"];
        // BEN: Used for looping incoming call while app is running (contains 1 ringtone sound)
        [self loadSound:INCOMING_CALL_SOUND withFilename:@"call_short.caf"];

        // DTMF Sounds
        [self loadSound:DTMF_0 withFilename:@"dtmf0.caf"];
        [self loadSound:DTMF_1 withFilename:@"dtmf1.caf"];
        [self loadSound:DTMF_2 withFilename:@"dtmf2.caf"];
        [self loadSound:DTMF_3 withFilename:@"dtmf3.caf"];
        [self loadSound:DTMF_4 withFilename:@"dtmf4.caf"];
        [self loadSound:DTMF_5 withFilename:@"dtmf5.caf"];
        [self loadSound:DTMF_6 withFilename:@"dtmf6.caf"];
        [self loadSound:DTMF_7 withFilename:@"dtmf7.caf"];
        [self loadSound:DTMF_8 withFilename:@"dtmf8.caf"];
        [self loadSound:DTMF_9 withFilename:@"dtmf9.caf"];
        [self loadSound:DTMF_STAR withFilename:@"dtmfstar.caf"];
        [self loadSound:DTMF_HASH withFilename:@"dtmfhash.caf"];

        [self loadSound:NOTIFICATION_SOUND withFilename:@"notification.caf"];
        [self loadSound:ALERT_SOUND withFilename:@"alert.caf"];
        
        // These sounds should not be played, they only exist to store the proper filename for the sound file
        // Playback is done through linphone
        [self loadSound:LINPHONE_RINGING withFilename:@"ringing.wav"];
        [self loadSound:LINPHONE_INCOMING_CALL withFilename:@"call_mono.wav"];
        [self loadSound:LINPHONE_CALL_BUSY withFilename:@"busy.wav"];
        [self loadSound:LINPHONE_CALL_ERROR withFilename:@"error.wav"];
        [self loadSound:LINPHONE_CALL_HANGUP withFilename:@"hangup.wav"];
        [self loadSound:LINPHONE_SILENCE withFilename:@"silence.wav"];
    }
    return self;
}


/********************************************************************************************/
/* Public methods                                                                           */
/********************************************************************************************/

#pragma mark - Public methods

- (NSString *)getFileName:(SoundID)soundID
{
    NSString * result = nil;
    
    Sound *sound = [_soundMapping objectForKey:[NSNumber numberWithInt:soundID]];
    
    if (sound)
    {
        result = sound.filename;
    }
    
    return result;
}

- (Float64)getFileLength:(SoundID)soundID
{
    const Float64 defaultlength = 2.0f;// sensible default
    Float64 length = defaultlength;
    
    NSString *filename = [self getFileName:soundID];
    if (!filename)
    {
        DLOG(JINGLE, "Could not get filename for soundid=%lu. Returning default length %.02f", (unsigned long)soundID, length);
        return length;
    }
    
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    if (!fileURL)
    {
        DLOG(JINGLE, "Could not get url for soundid=%lu. Returning default length %.02f", (unsigned long)soundID, length);
        return length;
    }
    
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    length = CMTimeGetSeconds(audioDuration);

    if (length != NAN)
    {
        DLOG(JINGLE, "File length for soundid=%ld is %.02f seconds", (long)soundID, length);
    }
    else
    {
        length = defaultlength;
        DLOG(JINGLE, "Could not get file length for soundid=%ld. Returning default length %.02f", (unsigned long)soundID, length);
    }
    return length;
}

- (void)playWithVibration:(SoundID)soundID
{
    [self play:soundID withVibration:YES withLoop:NO];
}


- (void)playWithoutVibration:(SoundID)soundID
{
    [self play:soundID withVibration:NO withLoop:NO];
}

- (void)playWithoutVibration:(SoundID)soundID withLoop:(BOOL)loop
{
    [self play:soundID withVibration:NO withLoop:loop];
}

- (void)playWithoutVibration:(SoundID)soundID withLoop:(BOOL)loop loopQueue:(dispatch_queue_t)loopQueue
{
    [self play:soundID withVibration:NO withLoop:loop loopQueue:loopQueue];
}

/**
 * Plays the sound with the given ID
 * @param soundID ID of the sound to be played
 * @param vibrate if YES the device will vibrate if it supports vibration
 * @return YES if the sound is playing, NO if it's not due to an error
 */
- (BOOL)play:(SoundID)soundID withVibration:(BOOL)vibrate withLoop:(BOOL)loop
{
    return [self play:soundID withVibration:vibrate withLoop:loop loopQueue:NULL];
}

- (BOOL)play:(SoundID)soundID withVibration:(BOOL)vibrate withLoop:(BOOL)loop loopQueue:(dispatch_queue_t)loopQueue
{
//    ApplicationControllerState applicationControllerState = [[ApplicationController getInstance] applicationControllerState];
//    if (applicationControllerState == ApplicationControllerStateActive)
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        Sound *sound = [_soundMapping objectForKey:[NSNumber numberWithInt:soundID]];
        if (!sound)
        {
            return NO;
        }
        
        return [sound playWithVibration:vibrate withLoop:loop loopQueue:loopQueue];
    }
    
    return NO;
}

- (BOOL)stop:(SoundID)soundID;
{
//    if ([[ApplicationController getInstance] currentlyInForeground])
//    {
        Sound *sound = [_soundMapping objectForKey:[NSNumber numberWithInt:soundID]];
        if (!sound)
        {
            return NO;
        }
        
        return [sound stop];
//    }
//    
//    return NO;
}
/********************************************************************************************/
/* Private methods                                                                          */
/********************************************************************************************/

#pragma mark - Private methods

- (void)loadSound:(SoundID)soundID withFilename:(NSString *)filename
{
    NSNumber * soundIDAsNumberObject = [NSNumber numberWithInt:soundID];
    if (soundIDAsNumberObject)
    {
        Sound *sound = [_soundMapping objectForKey:soundIDAsNumberObject];
        
        if (sound == nil)
        {
            @try
            {
                sound = [[Sound alloc] initWithID:soundID withFileName:filename loopQueue:self.loopQueue];
                
                [_soundMapping setObject:sound forKey:soundIDAsNumberObject];
            }
            @catch (NSException *exception)
            {
                ELOG(DEFAULT, "An exception has occurred when trying to load file (%@): %@", filename, [exception reason]);
            }
        }
    }
}


@end

