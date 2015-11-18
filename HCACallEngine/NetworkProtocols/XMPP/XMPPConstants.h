//
//  XMPPConstants.h
//  iO
//
//  Created by Joost de Moel on 25-09-14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

typedef enum
{
    QueueStanzaWhenOffline,         // queue stanza when we're offline (haven't sent presence yet) AND when we're not connected yet
    QueueStanzaWhenNotConnected,    // queue stanza when we're not connected to server yet
    DontSendStanzaWhenNotConnected  // stanza is not sent when we're not connected to server yet
} OfflineQueuePolicy;

