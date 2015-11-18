//
//  CellularCallController.h
//  iO
//
//  Created by Joost de Moel on 4/3/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CellCallObserver <NSObject>

/**
 * Fired when a cellular call is started
 * Note: this method can be invoked from different thread contexts
 */
- (void)notifyCellularCallStarted;


/**
 * Fired when a cellular call is connected (audio is flowing)
 * Note: this method can be invoked from different thread contexts
 */
- (void)notifyCellularCallConnected;


/**
 * Fired when a cellular call is released
 * Note: this method can be invoked from different thread contexts
 * @param isAnotherCellularCallActive YES if there is still another cellular call active
 */
- (void)notifyCellularCallReleased:(BOOL)isAnotherCellularCallActive;

@end


@interface CellularCallController : NSObject

/**
 * Sets the observer to listen to events from the CellCallManager.
 * Note: there can only be 1 observer at the moment
 */
@property (weak, nonatomic) id <CellCallObserver> observer;

- (id)init;

/**
 * @return YES if there currently is a cellular call active
 */
- (BOOL)isCellularCallActive;

@end
