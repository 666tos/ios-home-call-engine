//
//  HCACallInfo.h
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/11/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

/*
 Data class that containes required information about call
 */

#import <Foundation/Foundation.h>

#import "JingleTypes.h"

typedef NS_ENUM(NSUInteger, HCACallOptions)
{
    HCACallOptionsDefault = 0,
    HCACallOptionVideoDisabled = 1,
    HCACallOptionAudioDisabled = 1 << 1,
    HCACallOptionWindow = 1 << 2, //Flag is set when call is a window activating (See feature description https://swisscom.atlassian.net/wiki/display/HOM/Windows+setup+and+viewing+behaviour)
};

typedef NS_ENUM(NSInteger, HCACallInitiationType)
{
    HCACallInitiationTypeOutgoing = 0,
    HCACallInitiationTypeIncoming,
    HCACallInitiationTypeIncomingPush,
};

@interface HCACallInfo : NSObject

/* remote user JID*/
@property (strong, nonatomic) NSString *contactJID;

@property (strong, nonatomic) NSString *sessionID;
@property (assign, nonatomic) NSInteger jingleCallID;

@property (assign, nonatomic) HCACallOptions callOptions;
@property (assign, nonatomic) HCACallInitiationType callInitiationType;

@property (strong, nonatomic) NSDate *serverTimeStamp;
@property (strong, nonatomic) NSDate *startRingingTime;
@property (strong, nonatomic) NSDate *startCallingDate;

@property (assign, nonatomic) BOOL videoSrtpEnabled;
@property (assign, nonatomic) BOOL audioSrtpEnabled;

@property (assign, nonatomic) JingleTerminationReason terminationReason;

- (instancetype)initWithContactJid:(NSString *)contactJid callInitiationType:(HCACallInitiationType)callInitiationType callOptions:(HCACallOptions)callOptions;

- (JingleGateway)jingleGetway;

- (BOOL)isJingleCallIDValid;

- (NSTimeInterval)callDuration;
- (NSTimeInterval)callDurationMinutes;
- (NSString *)callDurationString;

- (NSString *)contactBareJid;

//Option helpers
- (BOOL)isWindowCall;

@end
