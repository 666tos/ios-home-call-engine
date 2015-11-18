//
//  CompilerUtils.h
//  iO
//
//  Created by Nikita Ivaniushchenko on 10/16/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

#define COMPILER_UTILS_SUPPRESS_DEPRECATION(Stuff) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
Stuff; \
_Pragma("clang diagnostic pop")

@interface CompilerUtils : NSObject

@end
