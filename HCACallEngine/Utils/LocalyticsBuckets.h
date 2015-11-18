//
//  LocalyticsBuckets.h
//  iO
//
//  Created by Benjamin van den Hout on 30/09/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalyticsBuckets : NSObject

/**
 * Calculate bucket values for bitrate in kbps
 * Example: 45 kbps with step 50 with max 600 will return string like "0-50K"
 * @param bitrate Target bitrate
 * @param step Bucket size
 * @param max Maximum size of bucket list, anything about this will return ">(max)K"
 * @return Formatted string ready for localytics
 */
+(NSString*)bucketForBitrate:(int)bitrate withStep:(int)step withMax:(int)max;

/**
 * Calculate bucket values for time in ms
 * Example: 49 ms with step 50 with max 600 will return string like "0-50ms"
 * @param timeMs Time in ms
 * @param step Bucket size
 * @param max Maximum size of bucket list, anything about this will return ">(max)ms"
 * @return Formatted string ready for localytics
 */
+(NSString*)bucketForTimeInMs:(int)timeMs withStep:(int)step withMax:(int)max;

/**
 * Calculate bucket values for percentages
 * Example: 2.70 percent with step 0.50f with max 6.0f will return string like "2.5-3.0%"
 * @param percentage Percentage, one percent is specified as 1.0f
 * @param step Bucket size
 * @param max Maximum size of bucket list, anything about this will return ">(max)%"
 * @return Formatted string ready for localytics
 */
+(NSString*)bucketForPercentage:(float)percentage withStep:(float)step withMax:(float)max;

/**
 * Calculate bucket values for call duration (special range)
 * Example: 110 sec will return string like "1 to 2min"
 * @param sec Call duration in seconds
 * @return Formatted string ready for localytics
 */
+(NSString*)bucketForConversationTimeSeconds:(int)sec;

/**
 * Calculate bucket values for exponential scale using formula round(a * (b + c)^x)
 * @param time Time in seconds which needs to fit into a bucket
 * @param a The "a" variable for the formula
 * @param b The "b" variable for the formula
 * @param c The "c" variable for the formula
 * @param maxMs Maximum size of bucket list, anything that greater or equal to this will return ">(max) ms"
 * @return Formatted string ready for localytics
 */
+ (NSString *)exponentialBucketForTime:(NSTimeInterval)time a:(float)a b:(float)b c:(float)c max:(int)maxMs;


@end
