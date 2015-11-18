//
//  Network.m
//  NGT International B.V.
//
//  Created by Boris Godin on 7/30/10.
//  Copyright 2010 NGT International B.V. All rights reserved.
//

#include "common.h"

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>

#import <Foundation/Foundation.h>
#import <Foundation/NSAutoreleasePool.h>
#import "Network.h"

@implementation Network

+ (NSArray *)getLocalIPsAndTypes
{
    NSMutableArray *result = [NSMutableArray array];

    DASSERT(result);

    struct ifaddrs *list;
    int             error;
    if ((error = getifaddrs(&list)) < 0)
    {
        ELOG(NET, "ERROR: getifaddrs returned %d", error);
        return result;
    }

    struct ifaddrs *cur;
    for (cur = list; cur != NULL; cur = cur->ifa_next)
    {
        if (cur->ifa_addr->sa_family != AF_INET || (cur->ifa_flags & IFF_LOOPBACK) != 0)
        {
            continue;
        }

        struct sockaddr_in *addrStruct = (struct sockaddr_in *)cur->ifa_addr;
        NSString *          name = [NSString stringWithUTF8String:cur->ifa_name];
        NSString *          addr = [NSString stringWithUTF8String:inet_ntoa(addrStruct->sin_addr)];
        [result addObject:addr];
        [result addObject:name];
        DLOG(NET, "Local address found, %@ (%@)", addr, name);
    }

    freeifaddrs(list);
    return result;
}


//--------------------------------------------------------------------------------------------------------------------
+ (NSString *)getLocalIP
{
    TNetworkType type;

    return [Network getLocalIPWithType:&type];
}


//--------------------------------------------------------------------------------------------------------------------
+ (NSString *)getLocalIPWithType:(TNetworkType *)type
{
    *type = ENetworkUnknown;
    NSString *address =  nil;
    NSArray * ips = [Network getLocalIPsAndTypes];

    if ([ips count] == 0)
    {
        address =  @"192.168.1.2"; // Default address for the router itself.
        DLOG(NET, "There are no local ips, %@ will be used", address);
    }
    else
    {
        for (NSUInteger i=0; i < [ips count]/2; i++)
        {
            NSString *addr = [ips objectAtIndex:i*2];
            NSString *name = [ips objectAtIndex:i*2 + 1];
            if ([name isEqualToString:@"en0"])
            {
                address = addr;
                *type = ENetworkWifi;
                break; // stop searching
            }
            else if ([name isEqualToString:@"pdp_ip0"])
            {
                address = addr;
                *type = ENetwork3G;
                // keep searching for wifi interface
            }
            else
            {
                if (address == nil)
                {
                    address = addr;
                }
                DLOG(NET, "Unknown network interface found: %@", name);
            }

        }
    }

    DLOG(NET, "Local address found, %@ (%@)", address, (*type == ENetworkWifi) ? @"en0, wifi" : @"pdp_ip0, 3G or carrier");
    return address;
}


//--------------------------------------------------------------------------------------------------------------------
+ (NSArray *)getIPAddressesFromDomainName:(NSString *)domainName
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:4];

    DASSERT(result);
    struct hostent *hp = gethostbyname([domainName UTF8String]);

    if (hp)
    {
        for (int i = 0; hp->h_addr_list[i] != NULL; ++i)
        {
            [result addObject:[NSString stringWithFormat:@"%d.%d.%d.%d",
                               (unsigned char) hp->h_addr_list[i][0],
                               (unsigned char) hp->h_addr_list[i][1],
                               (unsigned char) hp->h_addr_list[i][2],
                               (unsigned char) hp->h_addr_list[i][3]]];
        }
    }

    return result;
}


@end
