//
//  CellularCallController.m
//  iO
//
//  Created by Joost de Moel on 4/3/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import "Common.h"
#import "CellularCallController.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>

#if !__has_feature(objc_arc) 
#error "ARC is required" 
#endif

@interface CellularCallController()

@property (strong, nonatomic) CTCallCenter *ctCallCenter;


@end

@implementation CellularCallController

/********************************************************************************************/
/* Initialization                                                                           */
/********************************************************************************************/

#pragma mark - Initialization

- (id)init
{
    if ((self = [super init]))
    {
        _ctCallCenter = [[CTCallCenter alloc] init];
        
        __weak typeof(self) weakSelf = self;
        
        _ctCallCenter.callEventHandler=^(CTCall* call)
        {
            [weakSelf handleCallCenterEvent:call];
        };
    }
    
    return self;
}

- (void)handleCallCenterEvent:(CTCall *)call
{
    if (self.observer)
    {
        NSString* state = call.callState;
        
        if ([state isEqualToString:CTCallStateDialing] || [state isEqualToString:CTCallStateIncoming])
        {
            [self.observer notifyCellularCallStarted];
        }
        else if ([state isEqualToString:CTCallStateConnected])
        {
            [self.observer notifyCellularCallConnected];
        }
        else if ([state isEqualToString:CTCallStateDisconnected])
        {
            [self.observer notifyCellularCallReleased:self.isCellularCallActive];
        }
    }
}

/********************************************************************************************/
/* CellCallManagerInterface                                                                 */
/********************************************************************************************/

#pragma mark - CellCallManagerInterface

/**
 * @return YES if there currently is a cellular call active
 */
- (BOOL)isCellularCallActive
{
    // Note: do NOT use _ctCallCenter here. It doesn't give reliable results!
    
    CTCallCenter *ctCallCenter = [[CTCallCenter alloc] init];
    if (ctCallCenter.currentCalls != nil)
    {
        NSSet* set = ctCallCenter.currentCalls;
        
        for (CTCall *call in set)
        {
            if (call.callState == CTCallStateConnected)
            {
                DLOG(JINGLE, "call.callState: %@", call.callState);
                return YES;
            }
        }
    }
    
    return NO;
}



@end
