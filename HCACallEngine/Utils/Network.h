//
//  Network.h
//  NGT International B.V.
//
//  Created by Boris Godin on 7/30/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>

//--------------------------------------------------------------------------------------------------------------------
/// Enum for network types.
enum
{
    ENetworkUnknown = -1,
    ENetworkCarrier = 0,
    ENetwork3G,
    ENetworkWifi,
    ENetworkCable,
    ENoNetwork
};
typedef int TNetworkType;

@interface Network : NSObject {
}

/// Get array of strings pairs (ip, network interface name) for locas IPs. Array can be empty, but never null.
+ (NSArray *)getLocalIPsAndTypes;   // objectAtIndex: i*2 is ip, i*2+1 is network interface name.

/// Wifi is prefered over 3G, nil if no network is present.
+ (NSString *)getLocalIP;

/// Wifi is prefered over 3G, nil if no network. Also get network type.
+ (NSString *)getLocalIPWithType:(TNetworkType *)type;

/// Given domain name (ex. www.nimbuzz.com), returns its IPs.
+ (NSArray *)getIPAddressesFromDomainName:(NSString *)domainName;

@end // interface Network
