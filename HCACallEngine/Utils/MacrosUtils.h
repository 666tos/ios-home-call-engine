//
//  MacrosUtils.h
//  iO
//
//  Created by Nikita Ivaniushchenko on 10/16/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#ifndef iO_MacrosUtils_h
#define iO_MacrosUtils_h

#define DECLARE_EXTERN_CONST_NSSTRING(name) extern NSString * const name
#define DEFINE_CONST_NSSTRING(name) NSString * const name = @#name

#define DEFINE_STATIC_CONST_NSSTRING(name) static DEFINE_CONST_NSSTRING(name)

#define ENUM_CASE_TO_STRING(enumValue)  \
case enumValue: return @#enumValue;


// Gets the name of a classes propery at compile time
// This is for cases where a propery name is needed, to be able to ensure at compile time that a certain propery exists,
// like:        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:KeyName(ConversationItem, timestamp) ascending:YES];
// instead of:  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
#define KeyName(class, key)      ([(class *)nil key] ? @#key : @#key)

#endif
