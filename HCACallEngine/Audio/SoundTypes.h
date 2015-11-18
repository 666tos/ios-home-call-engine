//
//  SoundTypes.h
//  NGT International B.V.
//
//  Created by Joost de Moel on 2/27/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

typedef NS_ENUM(NSUInteger, SoundID)
{
    NO_SOUND,
    MESSAGE_RECEIVED_SOUND,
    MESSAGE_SENT_SOUND,
    INCOMING_CALL_LOCAL_NOTIFICATION,
    INCOMING_CALL_SOUND,
    DTMF_0,
    DTMF_1,
    DTMF_2,
    DTMF_3,
    DTMF_4,
    DTMF_5,
    DTMF_6,
    DTMF_7,
    DTMF_8,
    DTMF_9,
    DTMF_STAR, // DTMF Sound 10
    DTMF_HASH,  // DTMF Sound 11
    NOTIFICATION_SOUND,
    ALERT_SOUND,
    LINPHONE_RINGING,
    LINPHONE_INCOMING_CALL,
    LINPHONE_CALL_BUSY,
    LINPHONE_CALL_ERROR,
    LINPHONE_CALL_HANGUP,
    LINPHONE_SILENCE,
};
