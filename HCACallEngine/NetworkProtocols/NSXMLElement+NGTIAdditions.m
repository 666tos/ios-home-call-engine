/*
 *--------------------------------------------------------------------------------------------------
 * Filename: NSXMLElement.m
 *--------------------------------------------------------------------------------------------------
 *
 * Revision History:
 *
 *                             Modification     Tracking
 * Author                      Date             Number       Description of Changes
 * --------------------        ------------     ---------    ----------------------------------------
 * Roman Alarcon               2008-06-26                    File Created.
 * Roman Alarcon               2008-07-15                    Modified.
 *                                                             - Two new cases were added to method
 *                                                               "print"
 * Roman Alarcon               2008-07-22                    Modified.
 *                                                             - Uses of "const char *" were removed.
 *                                                               NSString used instead.
 * Roman Alarcon               2008-08-01                    Modified.
 *
 * Copyright  2008 NGT International B.V. All rights reserved.
 */

/**
 * General Description:
 *
 *
 * @author Romn Alarcn
 */


#import <Foundation/Foundation.h>

#import "NSXMLElement+NGTIAdditions.h"

#import "Common.h"
#import "Constants.h"
//#import "Utilities.h"
//#import "DateTimeUtils.h"
#import "XMPPStrings.h"
#import "NSStringExtended.h"
//#import "NSString+MKNetworkKitAdditions.h"

@import HCAUtils;
@import HomeCenterXMPP;

NSString *const XMPP_ERROR = @"ERROR";
NSString *const XMPP_IQ = @"IQ";
NSString *const XMPP_QUERY = @"QUERY";

static NSDateFormatter *      utcDateFormatter = nil; // this date formatter is used for parsing strings having 24-hour format and in UTC time zone

@implementation NSXMLElement (NGTIAdditions)



- (BOOL)isEqualToType:(NSString *)type
{
    return [[[self name] uppercaseString] isEqualToString:[type uppercaseString]];
}


- (BOOL)isEqualPrefixedType:(NSString *)elementName
{
    NSString * myElementName = nil;
    
    NSString * prefix = [self prefix];
    if (prefix.isNotEmpty)
    {
        myElementName = [NSString stringWithFormat:@"%@:%@", prefix, [self name]];
    }
    else
    {
        myElementName = [self name];
    }
    
    return [[myElementName uppercaseString] isEqualToString:[elementName uppercaseString]];
}


/**
 *
 */
- (void)addAttribute:(NSString *)name withValue:(NSString *)value
{
    if (name.isNotEmpty && value.isNotEmpty)
    {
        NSXMLElement *node = [NSXMLElement attributeWithName:name stringValue:value];
        [self addAttribute:node];
    }
}


/**
 *
 */
- (NSString *)getAttribute:(NSString *)name
{
    return [[self attributeForName:name] stringValue];
}


///**
// *
// */
//-(void) addChild: (NSXMLElement *) block
//{
//	[self addChild:];
//}

/**
 *
 */
- (NSXMLElement *)addNewChild:(NSString *)blockName
{
    NSXMLElement *result = [NSXMLElement elementWithName:blockName];

    [self addChild:result];

    return result;
}


/**
 *
 */
- (BOOL)hasChildren
{
    return [self childCount] > 0;
}


/**
 *
 */
- (BOOL)contains:(NSString *)datablockType
{
    return [self proceedUntil:datablockType] != nil;
}


/**
 *
 */
- (NSUInteger)sizeInBytes
{
    return [[self XMLString] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark -
#pragma mark TRAVERSAL ALGORITHMS


/**
 *
 */
- (NSXMLElement *)proceedUntil:(NSString *)datablockType
{
    for (NSXMLElement *tmp = self; tmp; tmp = (NSXMLElement *)[tmp nextNode])
    {
        if ([tmp kind] == NSXMLElementKind && [tmp isEqualToType:datablockType])
        {
            return tmp;
        }
    }

    return nil;
}

/**
 * @return the first child node or nil when there is none
 */
- (NSXMLElement*)firstChild
{
    for (NSXMLElement *child in [self children])
    {
        if ([child kind] == NSXMLElementKind)
        {
            return child;
        }
    }
    
    return nil;
}

/**
 * @return the first child with the given name or nil if it wasn't found
 */
- (NSXMLElement*)childWithName:(NSString *)name
{
    for (NSXMLElement *child in [self children])
    {
        if ([child kind] == NSXMLElementKind && [child isEqualToType:name])
        {
            return child;
        }
    }

    return nil;
}


- (NSArray *)childrenElementsWithName:(NSString *)name
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:5];

    for (NSXMLElement *child in [self children])
    {
        if ([child kind] == NSXMLElementKind && [child isEqualToType:name])
        {
            [ret addObject:child];
        }
    }

    return ret;
}


- (NSXMLElement *)nextElementNode
{
    for (NSXMLElement *tmp = (NSXMLElement *)[self nextNode]; tmp; tmp = (NSXMLElement *)[tmp nextNode])
    {
        if ([tmp kind] == NSXMLElementKind)
        {
            return tmp;
        }
    }

    return nil;
}

/**
 * Retrieves the server timestamp from this data block.
 * The server timestamp is located in the delay element of the data block, according to XEP-0203,
 * with the timestamp formatted  as specified in XEP-0082.
 * @param dataBlock XMPP data block to get the delay from.
 * @return The timestamp as an instance of NSDate or nil when no timestamp was found.
 */
- (NSDate *)getServerTimestamp
{
    for (NSXMLElement *child in [self children])
    {
        if ([child kind] == NSXMLElementKind && [child isEqualToType:kTagNameDelay])
        {
            NSString *timestampString = [child getAttribute:kAttributeStamp];
            if (timestampString.isNotEmpty)
            {
                return [[self class] stringToDateUTC:timestampString withFormat:kCommonISO8601DateTimeFormat];
            }
        }
    }
    
    return nil;
}

#pragma mark - 

+ (NSDate *)stringToDateUTC:(NSString *)timestamp withFormat:(NSString *)format
{
    NSDate *date = nil;
    
    if (timestamp.isNotEmpty && format.isNotEmpty)
    {
        @synchronized(utcDateFormatter)
        {
            if (utcDateFormatter == nil)
            {
                utcDateFormatter = [[NSDateFormatter alloc] init];
                [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                
                // NIPH-2716 Create "good" locale that does not expect AM/PM token for the date format
                NSLocale *goodLocale = [NSLocale localeWithLocaleIdentifier:kValueLanguageEn];
                [utcDateFormatter setLocale:goodLocale];
            }
            
            [utcDateFormatter setDateFormat:format];
            
            date = [utcDateFormatter dateFromString:timestamp];
        }
    }
    
    return date;
}

#pragma mark -


- (NSUInteger)hashIgnoringAttributes:(NSArray *)attributesToIgnore
{
    NSString *xmlString = [self XMLStringWithOptions:NSXMLNodeCompactEmptyElement];

    for (NSString *attribute in attributesToIgnore)
    {
        // use regular expressions for removing attribute
        NSError *error = nil;
        NSString *pattern = [NSString stringWithFormat:@"%@=\\\"[^\\\"]*\\\"", attribute];
        NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

        if (nil == error)
        {
            xmlString = [regExp stringByReplacingMatchesInString:xmlString options:0 range:NSMakeRange(0, [xmlString length]) withTemplate:kEmptyString];
        }
    }

    // always use MD5 value of string since -hash method is unreliable on strings longer than 96 characters
    return [[xmlString hca_md5] hash];
}


@end
