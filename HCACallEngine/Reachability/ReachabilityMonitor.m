#import "ReachabilityMonitor.h"
#import "Reachability.h"
//#import "iOBackendAPI.h"
#import "Common.h"

static ReachabilityMonitor *instance = nil;

@interface ReachabilityMonitor (Private)
- (void)reachabilityChanged:(NSNotification * )note;
@end

@implementation ReachabilityMonitor

+ (ReachabilityMonitor *)getInstance
{
    if (instance == nil)
    {
        instance = [[ReachabilityMonitor alloc] init];
    }

    return instance;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _hostReach = nil;
    }
    return self;
}


- (void)dealloc
{
    if (_hostReach)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:_hostReach];
        [_hostReach release];
    }
    [super dealloc];
}


- (void)setHost:(NSString *)host
{
//    DASSERT([[NSThread currentThread] isEqual:[[iOBackendAPI instance] getBackendThread]]);

    DLOG(NET,"Setting host '%@' for testing reachability.", host);

    if (_hostReach)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:_hostReach];
        [_hostReach release];
        _hostReach = nil;
    }

    _hostReach = [[Reachability reachabilityWithHostName:host] retain];

    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:_hostReach];

    [_hostReach startNotifier];
}


//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification * )note
{
#pragma unused (note)
//    DASSERT([[NSThread currentThread] isEqual:[[iOBackendAPI instance] getBackendThread]]);
    DLOG(NET,"Reachability Changed(%d)",[self internetConnectionStatus]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityMonitorChangedNotification object:self];
}


- (NetStatus)internetConnectionStatus
{
    NetStatus status = NetStatusNotReachable;

    if (_hostReach)
    {
        switch ([_hostReach currentReachabilityStatus])
        {
            case ReachableViaWWAN:
                status = NetStatusReachableViaCarrier;
                break;
            case ReachableViaWiFi:
                status = NetStatusReachableViaWiFi;
                break;
            case NotReachable:
            default:
                status = NetStatusNotReachable;
                break;
        }
    }
    return status;
}


- (BOOL)isConnectedToCarrier
{
    return [_hostReach connectedToCarrier];
}


@end
