//
//  DeviceUtils.h
//  iO
//
//  Created by Nikita Ivaniushchenko on 4/16/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DeviceFamily)
{
    DeviceFamilyUnknown = 0,
    DeviceFamilyIPhone,
    DeviceFamilyIPad,
    DeviceFamilyIPodTouch
};

typedef NS_ENUM(NSUInteger, DeviceModel)
{
    DeviceModelUnknown = 0,
    DeviceModelIPhone,
    DeviceModelIPhone3G,
    DeviceModelIPhone3GS,
    DeviceModelIPhone4,
    DeviceModelIPhone4S,
    DeviceModelIPhone5,
    DeviceModelIPhone5S,
    DeviceModelIPhone6,
    DeviceModelIPhone6Plus,
    DeviceModelIPhoneUnknown,
    
    DeviceModelIPad = 0x100,
    DeviceModelIPad2,
    DeviceModelIPadMini,
    DeviceModelIPad3,
    DeviceModelIPad4,
    DeviceModelIPadAir,
    DeviceModelIPadMini2,
    DeviceModelIPadMini3,
    DeviceModelIPadAir2,
    DeviceModelIPadUnknown,
    
    DeviceModelIPodTouch = 0x300,
    DeviceModelIPodTouch2G,
    DeviceModelIPodTouch3G,
    DeviceModelIPodTouch4G,
    DeviceModelIPodTouch5G,
    DeviceModelIPodTouchUnknown
};

@interface DeviceUtils : NSObject

+ (DeviceUtils *)instance;

@property (nonatomic, readonly) BOOL isRunningOnIPad;
@property (nonatomic, readonly) BOOL isRunningOnIPodTouch;
@property (nonatomic, readonly) BOOL isRunningOnIOS8;
@property (nonatomic, readonly) BOOL isPushKitAvailable;
@property (nonatomic, readonly) BOOL isRunningOn3_5Inch;
@property (nonatomic, readonly) BOOL isRunningOniPhone6Plus;
@property (nonatomic, readonly) CGFloat screenScale;

@property (nonatomic, readonly) DeviceFamily deviceFamily;
@property (nonatomic, readonly) DeviceModel deviceModel;
@property (nonatomic, readonly) NSString *deviceModelString;

@property (nonatomic, readonly) NSUInteger numberOfCores;

@property (nonatomic, readonly) BOOL perspectiveZoomEffectAvailable;

@property (nonatomic, readonly) NSString *platform;

@end


#define RUNNING_ON_IPAD         ([DeviceUtils instance].isRunningOnIPad)
#define RUNNING_ON_IPOD_TOUCH   ([DeviceUtils instance].isRunningOnIPodTouch)
#define RUNNING_ON_IOS8         ([DeviceUtils instance].isRunningOnIOS8)
#define PUSH_KIT_AVAILABLE      ([DeviceUtils instance].isPushKitAvailable)
#define RUNNING_ON_3_5_INCH     ([DeviceUtils instance].isRunningOn3_5Inch)
#define RUNNING_ON_IPHONE_6PLUS ([DeviceUtils instance].isRunningOniPhone6Plus)
#define UI_SCREEN_SCALE         ([DeviceUtils instance].screenScale)
#define IS_UI_SCREEN_SCALE_3X      ([DeviceUtils instance].screenScale == 3.0f)