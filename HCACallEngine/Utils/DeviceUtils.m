//
//  DeviceUtils.m
//  iO
//
//  Created by Nikita Ivaniushchenko on 4/16/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "DeviceUtils.h"

#include <sys/types.h>
#include <sys/sysctl.h>

#define kDeviceModelStringUnknown           @"Unknown"
#define kDeviceModelStringIPhone            @"iPhone"
#define kDeviceModelStringIPhone3G          @"iPhone3G"
#define kDeviceModelStringIPhone3GS         @"iPhone3GS"
#define kDeviceModelStringIPhone4           @"iPhone4"
#define kDeviceModelStringIPhone4S          @"iPhone4S"
#define kDeviceModelStringIPhone5           @"iPhone5"
#define kDeviceModelStringIPhone5S          @"iPhone5S"
#define kDeviceModelStringIPhone6           @"iPhone6"
#define kDeviceModelStringIPhone6Plus       @"iPhone6Plus"
#define kDeviceModelStringIPhoneUnknown     @"iPhoneUnknown"

#define kDeviceModelStringIPad              @"iPad"
#define kDeviceModelStringIPad2             @"iPad2"
#define kDeviceModelStringIPadMini          @"iPadMini"
#define kDeviceModelStringIPad3             @"iPad3"
#define kDeviceModelStringIPad4             @"iPad4"
#define kDeviceModelStringIPadAir           @"iPadAir"
#define kDeviceModelStringIPadMini2         @"iPadMini2"
#define kDeviceModelStringIPadMini3         @"iPadMini3"
#define kDeviceModelStringIPadAir2          @"iPadAir2"
#define kDeviceModelStringIPadUnknown       @"iPadUnknown"

#define kDeviceModelStringIPodTouch         @"iPodTouch"
#define kDeviceModelStringIPodTouch2G       @"iPodTouch2G"
#define kDeviceModelStringIPodTouch3G       @"iPodTouch3G"
#define kDeviceModelStringIPodTouch4G       @"iPodTouch4G"
#define kDeviceModelStringIPodTouch5G       @"iPodTouch5G"
#define kDeviceModelStringIPodTouchUnknown  @"iPodTouchUnknown"

static DeviceUtils *sInstance = nil;

@interface DeviceUtils()

@property (nonatomic, readwrite) float systemVersion;

@property (nonatomic, readwrite) BOOL isRunningOnIOS8;
@property (nonatomic, readwrite) BOOL isPushKitAvailable;
@property (nonatomic, readwrite) BOOL isRunningOn3_5Inch;
@property (nonatomic, readwrite) CGFloat screenScale;

@property (nonatomic, readwrite) DeviceFamily deviceFamily;
@property (nonatomic, readwrite) DeviceModel deviceModel;
@property (nonatomic, readwrite) NSString *deviceModelString;

@property (nonatomic, readwrite) NSUInteger numberOfCores;

@end

@implementation DeviceUtils

@dynamic isRunningOnIPad;
@dynamic isRunningOnIPodTouch;
@dynamic isRunningOniPhone6Plus;

@dynamic perspectiveZoomEffectAvailable;

@dynamic platform;

+ (DeviceUtils *)instance
{
    if (sInstance != nil)
    {
        return sInstance;
    }
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^
    {
        sInstance = [[self alloc] init];
    });
    
    return sInstance;
}

- (id)init
{
    if (self = [super init])
    {
        _systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        _isRunningOnIOS8 = (_systemVersion >= 8.f);
        _isPushKitAvailable = (_systemVersion >= 8.1f);
        _isRunningOn3_5Inch = ([UIScreen mainScreen].bounds.size.height == 480.f);
        _screenScale = ([UIScreen mainScreen].scale);
        
        _numberOfCores = [NSProcessInfo processInfo].activeProcessorCount;
        
        [self detectDeviceFamilyAndModel];
    }
    
    return self;
}

- (BOOL)isRunningOnIPad
{
    return (self.deviceFamily == DeviceFamilyIPad);
}

- (BOOL)isRunningOnIPodTouch
{
    return (self.deviceFamily == DeviceFamilyIPodTouch);
}

- (BOOL)isRunningOniPhone6Plus
{
    return (self.deviceModel == DeviceModelIPhone6Plus);
}

- (BOOL)perspectiveZoomEffectAvailable
{
    return (_numberOfCores > 1);
}

- (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (void)detectDeviceFamilyAndModel
{
#if TARGET_IPHONE_SIMULATOR
    BOOL isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    self.deviceFamily = isIPad ? DeviceFamilyIPad : DeviceFamilyIPhone;
    self.deviceModel = isIPad ? DeviceModelIPadUnknown : DeviceModelIPhoneUnknown;
    
    if (!isIPad && (self.screenScale == 3.f))
    {
        self.deviceModel = DeviceModelIPhone6Plus;
    }
#else
    
    NSString *platformString = [self platform];
    
    self.deviceFamily = DeviceFamilyUnknown;
    self.deviceModel = DeviceModelUnknown;
    self.deviceModelString = kDeviceModelStringUnknown;
    
    NSInteger firstDigit = 0, lastDigit = 0;
    
    if (platformString.length >= 7)
    {
        firstDigit = [[platformString substringWithRange:NSMakeRange(platformString.length - 3, 1)] integerValue];
        lastDigit = [[platformString substringWithRange:NSMakeRange(platformString.length - 1, 1)] integerValue];
    }
    
    if ([platformString hasPrefix:@"iPhone"])
    {
        self.deviceFamily = DeviceFamilyIPhone;
        
        [self detectIPhoneModelWithFirstDigit:firstDigit lastDigit:lastDigit];
    }
    else if ([platformString hasPrefix:@"iPad"])
    {
        self.deviceFamily = DeviceFamilyIPad;
        
        [self detectIPadModelWithFirstDigit:firstDigit lastDigit:lastDigit];
    }
    else if ([platformString hasPrefix:@"iPod"])
    {
        self.deviceFamily = DeviceFamilyIPodTouch;
        
        [self detectIPodTouchModelWithFirstDigit:firstDigit lastDigit:lastDigit];
    }
#endif
}

#pragma mark -
#pragma mark Detecting model

- (void)detectIPhoneModelWithFirstDigit:(NSInteger)firstDigit lastDigit:(NSInteger)lastDigit
{
    switch (firstDigit)
    {
        case 1:
            self.deviceModel = (lastDigit == 1) ? DeviceModelIPhone : DeviceModelIPhone3G;
            self.deviceModelString = (lastDigit == 1) ? kDeviceModelStringIPhone : kDeviceModelStringIPhone3G;
            break;
            
        case 2:
            self.deviceModel = DeviceModelIPhone3GS;
            self.deviceModelString = kDeviceModelStringIPhone3GS;
            break;
            
        case 3:
            self.deviceModel = DeviceModelIPhone4;
            self.deviceModelString = kDeviceModelStringIPhone4;
            break;

        case 4:
            self.deviceModel = DeviceModelIPhone4S;
            self.deviceModelString = kDeviceModelStringIPhone4S;
            break;

        case 5:
            self.deviceModel = DeviceModelIPhone5;
            self.deviceModelString = kDeviceModelStringIPhone5;
            break;
            
        case 6:
            self.deviceModel = DeviceModelIPhone5S;
            self.deviceModelString = kDeviceModelStringIPhone5S;
            break;
            
        case 7:
            self.deviceModel = (lastDigit == 1) ? DeviceModelIPhone6Plus : DeviceModelIPhone6;
            self.deviceModelString = (lastDigit == 1) ? kDeviceModelStringIPhone6Plus : kDeviceModelStringIPhone6;
            break;

        default:
            self.deviceModel = DeviceModelIPhoneUnknown;
            self.deviceModelString = kDeviceModelStringIPhoneUnknown;
            break;
    }
}

- (void)detectIPodTouchModelWithFirstDigit:(NSInteger)firstDigit lastDigit:(NSInteger)lastDigit
{
#pragma unused(lastDigit)
    switch (firstDigit)
    {
        case 1:
            self.deviceModel = DeviceModelIPodTouch;
            self.deviceModelString = kDeviceModelStringIPodTouch;
            break;
            
        case 2:
            self.deviceModel = DeviceModelIPodTouch2G;
            self.deviceModelString = kDeviceModelStringIPodTouch2G;
            break;

        case 3:
            self.deviceModel = DeviceModelIPodTouch3G;
            self.deviceModelString = kDeviceModelStringIPodTouch3G;
            break;

        case 4:
            self.deviceModel = DeviceModelIPodTouch4G;
            self.deviceModelString = kDeviceModelStringIPodTouch4G;
            break;

        case 5:
            self.deviceModel = DeviceModelIPodTouch5G;
            self.deviceModelString = kDeviceModelStringIPodTouch5G;
            break;
            
        default:
            self.deviceModel = DeviceModelIPodTouchUnknown;
            self.deviceModelString = kDeviceModelStringIPodTouchUnknown;
            break;
    }
}

- (void)detectIPadModelWithFirstDigit:(NSInteger)firstDigit lastDigit:(NSInteger)lastDigit
{
    switch (firstDigit)
    {
        case 1:
            self.deviceModel = DeviceModelIPad;
            self.deviceModelString = kDeviceModelStringIPad;
            break;
        case 2:
            if (lastDigit < 5)          //iPad2,1 - iPad2,4 - iPad2
            {
                self.deviceModel = DeviceModelIPad2;
                self.deviceModelString = kDeviceModelStringIPad2;
            }
            else                        //iPad2,5 - iPad2,7 - iPadMini
            {
                self.deviceModel = DeviceModelIPadMini;
                self.deviceModelString = kDeviceModelStringIPadMini;
            }
            break;

        case 3:
            if (lastDigit < 4)         //iPad3,1 - iPad3,3 - iPad3
            {
                self.deviceModel = DeviceModelIPad3;
                self.deviceModelString = kDeviceModelStringIPad3;
            }
            else                        //iPad3,4 - iPad3,6 - iPad3
            {
                self.deviceModel = DeviceModelIPad4;
                self.deviceModelString = kDeviceModelStringIPad4;
            }
            break;
            
        case 4:
            if (lastDigit < 4)          //iPad4,1 - iPad4,3 - iPadAir
            {
                self.deviceModel = DeviceModelIPadAir;
                self.deviceModelString = kDeviceModelStringIPadAir;
            }
            else if (lastDigit < 7)     //iPad4,4 - iPad4,6 - iPadMini2
            {
                self.deviceModel = DeviceModelIPadMini2;
                self.deviceModelString = kDeviceModelStringIPadMini2;
            }
            else                        //iPad4,7 - iPad4,9 - iPadMini3
            {
                self.deviceModel = DeviceModelIPadMini3;
                self.deviceModelString = kDeviceModelStringIPadMini3;
            }
            break;
            
        case 5:
            self.deviceModel = DeviceModelIPadAir2;
            self.deviceModelString = kDeviceModelStringIPadAir2;
            break;
            
        default:
            self.deviceModel = DeviceModelIPadUnknown;
            self.deviceModelString = kDeviceModelStringIPadUnknown;
            break;
    }
}

@end
