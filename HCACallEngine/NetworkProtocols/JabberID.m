/*
 *--------------------------------------------------------------------------------------------------
 * Filename: JabberID.m
 *--------------------------------------------------------------------------------------------------
 *
 * Revision History:
 *
 *                             Modification     Tracking
 * Author                      Date             Number       Description of Changes
 * --------------------        ------------     ---------    ----------------------------------------
 * Roman Alarcon               2008-07-28                    File Created.
 * Roman Alarcon               2008-08-01                    Modified.
 *
 * Copyright (c) 2008 NGT International B.V. All rights reserved.
 */

/**
 * General Description:
 * This file provides the implementation of class JabberID.
 *
 * @author Roman Alarcon
 */

#import "JabberID.h"
#import "Common.h"
#import "NSStringExtended.h"


//#import "Constants.h"

#define kEmptyString                   @""

@interface JabberID()
{
@private
    NSMutableString *_user;
    NSMutableString *_domain;
    NSMutableString *_resourceName;
}
@end

@implementation JabberID;

/**
 *
 */
- (id)init
{
    if ((self = [super init]))
    {
        _user         = [[NSMutableString alloc] initWithString:kEmptyString];
        _domain       = [[NSMutableString alloc] initWithString:kEmptyString];
        _resourceName = [[NSMutableString alloc] initWithString:kEmptyString];
    }
    return self;
}


/**
 *
 */
- (id)initWithUser:(NSString *)user domain:(NSString *)domain resource:(NSString *)resourceName
{
    if ((self = [super init]))
    {
        if (user != nil)
        {
            _user = [[NSMutableString alloc] initWithString:user];
        }
        else
        {
            _user = [[NSMutableString alloc] initWithString:kEmptyString];
        }

        if (domain != nil)
        {
            _domain = [[NSMutableString alloc] initWithString:domain];
        }
        else
        {
            _domain = [[NSMutableString alloc] initWithString:kEmptyString];
        }

        if (resourceName != nil)
        {
            _resourceName = [[NSMutableString alloc] initWithString:resourceName];
        }
        else
        {
            _resourceName = [[NSMutableString alloc] initWithString:kEmptyString];
        }
    }
    return self;
}


/**
 *
 */
- (id)initWithJID:(NSString *)jid
{
    if ((self = [super init]))
    {
        _user         = [[NSMutableString alloc] initWithString:kEmptyString];
        _domain       = [[NSMutableString alloc] initWithString:kEmptyString];
        _resourceName = [[NSMutableString alloc] initWithString:kEmptyString];

        if (jid.isNotEmpty)
        {
            NSMutableString *domainAndResource = [[NSMutableString alloc] initWithString:kEmptyString];

            /* Get the user from the JID */
            NSRange rangeOfDomainSeparator = [jid rangeOfString:@"@"];
            if (rangeOfDomainSeparator.location != NSNotFound)
            {
                [_user setString:[jid substringToIndex:rangeOfDomainSeparator.location]];
                [domainAndResource setString:[jid substringFromIndex:rangeOfDomainSeparator.location + 1]];
            }
            else
            {
                [domainAndResource setString:jid];
            }

            /* Get the domain and the resource name */
            NSRange rangeOfResourceSeparator = [domainAndResource rangeOfString:@"/"];
            if (rangeOfResourceSeparator.location != NSNotFound)
            {
                [_domain setString:[domainAndResource substringToIndex:rangeOfResourceSeparator.location]];
                [_resourceName setString:[domainAndResource substringFromIndex:rangeOfResourceSeparator.location + 1]];
            }
            else
            {
                [_domain setString:domainAndResource];
            }

            [domainAndResource release];
        }
        else
        {
            [_user setString:kEmptyString];
            [_domain setString:kEmptyString];
            [_resourceName setString:kEmptyString];
        }
    }
    return self;
}


/*
 *
 */
+ (id)jabberIDWithJidString:(NSString *)jidString
{
#warning Think about proper solution
    return [XMPPJID jidWithString:jidString];
//    return [[[JabberID alloc] initWithJID:jidString] autorelease];
}


/**
 * @return the user part of the given jid, or the entire string if no @ character is found
 */
+ (NSString*)getUserFromJidString:(NSString*)jidString
{
    NSRange rangeOfDomainSeparator = [jidString rangeOfString:@"@"];
    if (rangeOfDomainSeparator.location != NSNotFound)
    {
        return [jidString substringToIndex:rangeOfDomainSeparator.location];
    }
    
    return jidString;
}

+ (NSString*)getJidWithUser:(NSString*)user withDomain:(NSString*)domain
{
    return [NSString stringWithFormat:@"%@@%@", user, domain];
}

/*
 *
 */
- (void)dealloc
{
    [_user release];
    [_domain release];
    [_resourceName release];
    [super dealloc];
}


/**
 *
 */
- (NSString *)getUser
{
    return _user;
}


/**
 *
 */
- (NSString *)getDomain
{
    return _domain;
}


/**
 *
 */
- (void)setResource:(NSString *)resourceName
{
    if (resourceName == nil)
    {
        DLOG(DEFAULT, "JabberID::resourceName: Argument \"resourceName\" is nil. Setting resource name to \"\"");
        [_resourceName setString:kEmptyString];
    }
    else
    {
        [_resourceName setString:resourceName];
    }
}


/**
 *
 */
- (NSString *)getResourceName
{
    return _resourceName;
}


/**
 *
 */
- (NSString *)getJIDString
{
    NSString *jid;

    if (_domain.isNotEmpty)
    {
        if (_user.isNotEmpty)
        {
            if (_resourceName.isNotEmpty)
            {
                jid = [NSString stringWithFormat:@"%@@%@/%@", _user, _domain, _resourceName];
            }
            else
            {
                jid = [NSString stringWithFormat:@"%@@%@", _user, _domain];
            }
        }
        else
        {
            if (_resourceName.isNotEmpty)
            {
                jid = [NSString stringWithFormat:@"%@/%@", _domain, _resourceName];
            }
            else
            {
                jid = [NSString stringWithFormat:@"%@", _domain];
            }
        }
    }
    else
    {
        jid = kEmptyString;
    }

    return jid;
}


/**
 *
 */
- (NSString *)getBareJIDString
{
    NSString *bareJid;

    if (_user.isNotEmpty && _domain.isNotEmpty)
    {
        bareJid = [NSString stringWithFormat:@"%@@%@", _user, _domain];
    }
    else if (_user.isNotEmpty)
    {
        bareJid = [NSString stringWithString:_user];
    }
    else if (_domain.isNotEmpty)
    {
        bareJid = [NSString stringWithString:_domain];
    }
    else
    {
        bareJid = kEmptyString;
    }

    return bareJid;
}


- (NSString *)description;
{
    return [self getJIDString];
}

@end
