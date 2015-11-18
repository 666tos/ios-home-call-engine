//
//  Utilities.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 4/14/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *)generateRandomAlphanumericID
{
    static const unsigned int ALPHABET_LENGTH = 52;
    static const unsigned int MAX_ID_LENGTH   = 10;
    static const char *       alphabet               = "0a1b2c3d4e5f6g7h8i9jAkBlCmDnEoFpGqHrIsJtKuLvMwNxOyPz";
    static BOOL               initialized = NO;
    char                      output[MAX_ID_LENGTH + 1];
    
    output[MAX_ID_LENGTH] = '\0';
    
    if (!initialized)
    {
        initialized = YES;
        srandomdev();
    }
    
    for (unsigned int i = 0; i < MAX_ID_LENGTH; ++i)
    {
        output[i] = alphabet[random() % ALPHABET_LENGTH];
    }
    
    NSString *stringid = [NSString stringWithUTF8String:output];
    
    return stringid;
}
@end
