//
//  HCACallInfo.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/11/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "HCACallInfo.h"

#import "JinglePhone.h"

#import <HomeCenterXMPP/XMPPJID.h>

@implementation HCACallInfo

- (instancetype)initWithContactJid:(NSString *)contactJid callInitiationType:(HCACallInitiationType)callInitiationType callOptions:(HCACallOptions)callOptions
{
    self = [super init];
    
    if (self)
    {
        self.contactJID = contactJid;
        self.callInitiationType = callInitiationType;
        self.callOptions = callOptions;
    }
    
    return self;
}

- (JingleGateway)jingleGetway
{
    return JingleGatewayRelayedVideo;
}

- (BOOL)isJingleCallIDValid
{
    return self.jingleCallID != kInvalidCallID;
}

- (NSTimeInterval)callDuration
{
    return -[self.startCallingDate timeIntervalSinceNow];
}

- (NSTimeInterval)callDurationMinutes
{
    return [self callDuration] / 60.;
}

- (NSString *)callDurationString
{
    static const NSInteger secondsInMinute = 60;
    
    NSTimeInterval callDuration = [self callDuration];
    NSInteger callDurationSeconds = (NSInteger) callDuration;
    
    NSInteger seconds = callDurationSeconds % secondsInMinute;
    NSInteger minutes = (callDurationSeconds - seconds) / secondsInMinute;
    
    NSString *callDurationString = [NSString stringWithFormat:@"%02d:%02d", (int)minutes, (int)seconds];
    return callDurationString;
}

- (NSString *)contactBareJid
{
    XMPPJID *jid = [XMPPJID jidWithString:self.contactJID];
    return [jid bare];
}

- (BOOL)isWindowCall
{
    return self.callOptions & HCACallOptionWindow; 
}

@end
