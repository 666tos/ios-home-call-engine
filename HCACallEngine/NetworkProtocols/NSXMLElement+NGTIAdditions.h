/*
 *--------------------------------------------------------------------------------------------------
 * Filename: XMPPDataBlock.h
 *--------------------------------------------------------------------------------------------------
 *
 * Revision History:
 *
 *                             Modification     Tracking
 * Author                      Date             Number       Description of Changes
 * --------------------        ------------     ---------    ----------------------------------------
 * Roman Alarcon               2008-06-26                    File Created.
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
 * @author Roman Alarcon
 */

//#import <Foundation/NSObject.h>
//#import <Foundation/NSDictionary.h>
//#import <Foundation/NSString.h>
//#import <Foundation/NSArray.h>

#import "JabberID.h"
//#import "NSStringAdditions.h"
//#import "NSXMLElementAdditions.h"

#import <Foundation/Foundation.h>
#import <HomeCenterXMPP/XMPPFramework.h>


extern NSString *const XMPP_ERROR;
extern NSString *const XMPP_IQ;
extern NSString *const XMPP_QUERY;

@interface NSXMLElement (NGTIAdditions)

- (BOOL)isEqualToType:(NSString *)type;
- (BOOL)isEqualPrefixedType:(NSString *)elementName;
- (void)addAttribute:(NSString *)name withValue:(NSString *)value;
- (NSString *)getAttribute:(NSString *)name;
- (NSXMLElement *)addNewChild:(NSString *)blockName;
- (BOOL)hasChildren;
- (BOOL)contains:(NSString *)datablockType;
- (NSUInteger)sizeInBytes;
// Traversal algorithms
- (NSXMLElement *)proceedUntil:(NSString *)datablockType;
- (NSXMLElement*)firstChild;
- (NSXMLElement*)childWithName:(NSString *)name;
- (NSArray *)childrenElementsWithName:(NSString *)name;
- (NSXMLElement *)nextElementNode;

/**
 * Retrieves the server timestamp from this data block.
 * The server timestamp is located in the delay element of the data block, according to XEP-0203,
 * with the timestamp formatted  as specified in XEP-0082.
 * @param dataBlock XMPP data block to get the delay from.
 * @return The timestamp as an instance of NSDate or nil when no timestamp was found.
 */
- (NSDate *)getServerTimestamp;

/**
 * Caulculates hash value of the receiver, ignoring optional attributes. The hash is used for quick determining if 2 XML elements
 * are logically equal so that the appropriate XMPP request is not sent multiple times.
 * Hash is calculated for the string representation of the element. Uses regular expressions for removing attributes to be ignored.
 * @param attributesToIgnore Array of string names of attributes to ignore while comparing
 * @return Calculated hash value
 */
- (NSUInteger)hashIgnoringAttributes:(NSArray *)attributesToIgnore;

@end

#define XMPPDataBlock NSXMLElement



