//
//  HCACallEngine.h
//  HCACallEngine
//
//  Created by Maxim Malyhin on 1/26/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for HCACallEngine.
FOUNDATION_EXPORT double HCACallEngineVersionNumber;

//! Project version string for HCACallEngine.
FOUNDATION_EXPORT const unsigned char HCACallEngineVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HCACallEngine/PublicHeader.h>

static NSString * const kHCACallEngineBundleId = @"com.ngti.HCACallEngine";

#import <HCACallEngine/NetworkProtocolJingle.h>
#import <HCACallEngine/NetworkProtocolRelay.h>

#import <HCACallEngine/JinglePhone.h>
//#import <HCACallEngine/VoiceEngine.h>
#import <HCACallEngine/LinphoneVoiceEngine.h>

#import <HCACallEngine/RelayController.h>
#import <HCACallEngine/HCANetworkProtocolRelayAdapter.h> 
#import <HCACallEngine/XMPPProtocolJingle.h>
#import <HCACallEngine/XMPPDataBlockDispatcher.h>

#import <HCACallEngine/Network.h>

#import <HCACallEngine/XMPPStrings.h>
#import <HCACallEngine/NSStringExtended.h> 

#import <HCACallEngine/JingleContent.h>
#import <HCACallEngine/JingleSession.h>
#import <HCACallEngine/JingleTransport.h>

#import <HCACallEngine/HCACallJingleCantroller.h>
#import <HCACallEngine/HCACallControllerStatesDescription.h>

//Unit testing support
#import <HCACallEngine/TestVoiceEngine.h>
#import <HCACallEngine/HCATestXMPPDataBlockDispatcher.h>

