//#import "Constants.h"
#import <Foundation/Foundation.h>

#define kReachabilityMonitorChangedNotification @"kReachabilityMonitorChangedNotification"

@class Reachability;

//typedef enum
//{
//    NetStatusNotReachable = 0,
//    NetStatusReachableViaCarrier,
//    NetStatusReachableViaWiFi
//} NetStatus;

#import "Constants.h"

@interface ReachabilityMonitor : NSObject {
    Reachability *_hostReach;
}

+ (ReachabilityMonitor *)getInstance;
- (NetStatus)internetConnectionStatus;
- (void)setHost:(NSString *)host;
- (BOOL)isConnectedToCarrier;
@end
