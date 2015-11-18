//
//  NSStringExtended.m
//  NGT International B.V.
//
//  Created by Ronnie on 9/19/12.
//  Copyright (c) 2012 NGT International B.V. All rights reserved.
//

#import "NSStringExtended.h"


@implementation NSString (Extended)

/* Note:
 * NSString stringByAddingPercentEscapesUsingEncoding encodes non-URL characters but leaves the reserved characters
 * (like slash / and ampersand &) alone? "Apparently" this is a "bug" apple is aware of, but they haven't done
 * anything about it yet, and so below is a solution that actually works.
 */
- (NSString *)URLEncodedString
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?#[]"),
                                                                           kCFStringEncodingUTF8);

    [result autorelease];
    return result;
}


- (NSString *)MinimalURLEncodedString
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           CFSTR("%"),             // characters to leave unescaped (NULL = all escaped sequences are replaced)
                                                                           CFSTR("?=&+"),          // legal URL characters to be escaped (NULL = all legal characters are replaced)
                                                                           kCFStringEncodingUTF8); // encoding

    [result autorelease];
    return result;
}


- (NSString *)URLDecodedString
{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);

    [result autorelease];
    return result;
}

/**
 * Return if the string is nil or empty.
 * @return YES when the string is not nil and contains characters, otherwise NO.
 */
- (BOOL)isNotEmpty
{
    return (self.length != 0);
}

@end
