//
//  LocalyticsBuckets.m
//  iO
//
//  Created by Benjamin van den Hout on 30/09/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "LocalyticsBuckets.h"
#import "common.h"

@implementation LocalyticsBuckets


+(NSString*)bucketForBitrate:(int)bitrate withStep:(int)step withMax:(int)max;
{
    return [LocalyticsBuckets bucketForIntValue:bitrate withStep:step withMax:max withFormat:@"%d-%dK" withMaxFormat:@">%dK"];
}

+(NSString*)bucketForTimeInMs:(int)timeMs withStep:(int)step withMax:(int)max
{
    return [LocalyticsBuckets bucketForIntValue:timeMs withStep:step withMax:max withFormat:@"%d-%dms" withMaxFormat:@">%dms"];
}

+(NSString*)bucketForPercentage:(float)percentage withStep:(float)step withMax:(float)max
{
    return [LocalyticsBuckets bucketForFloatValue:percentage withStep:step withMax:max withFormat:@"%.1f-%.1f%%" withMaxFormat:@">%.1f%%"];
}


+(NSString*)bucketForConversationTimeSeconds:(int)sec;
{
    NSString *retval = @"unknown";
    retval = ((sec >= 0)    && (sec < 1))    ? @"0 to 1 sec"   : retval;
    retval = ((sec >= 1)    && (sec < 5))    ? @"1 to 5 sec"   : retval;
    retval = ((sec >= 5)    && (sec < 10))   ? @"5 to 10 sec"  : retval;
    retval = ((sec >= 10)   && (sec < 15))   ? @"10 to 15 sec" : retval;
    retval = ((sec >= 15)   && (sec < 30))   ? @"15 to 30 sec" : retval;
    retval = ((sec >= 30)   && (sec < 60))   ? @"30 to 60 sec" : retval;
    retval = ((sec >= 60)   && (sec < 120))  ? @"1 to 2 min"   : retval;
    retval = ((sec >= 120)  && (sec < 180))  ? @"2 to 3 min"   : retval;
    retval = ((sec >= 180)  && (sec < 240))  ? @"3 to 4 min"   : retval;
    retval = ((sec >= 240)  && (sec < 360))  ? @"4 to 6 min"   : retval;
    retval = ((sec >= 360)  && (sec < 600))  ? @"6 to 10 min"  : retval;
    retval = ((sec >= 600)  && (sec < 1200)) ? @"10 to 20 min" : retval;
    retval = ((sec >= 1200) && (sec < 1800)) ? @"20 to 30 min" : retval;
    retval = ((sec >= 1800) && (sec < 3600)) ? @"30 to 60 min" : retval;
    retval = ((sec >= 3600))                 ? @">60 min"      : retval;

    return retval;
}

+(NSString*)bucketForIntValue:(int)value withStep:(int)step withMax:(int)max withFormat:(NSString*)format withMaxFormat:(NSString*)maxFormat
{
    NSString *retval = nil;
    int cur = 0;
    
    // Special case: check if past maximum
    if (value > max)
    {
        return [NSString stringWithFormat:maxFormat, max];
    }
    
    // Determine bucket
    do
    {
        if ((value >= cur) && (value < (cur+step)))
        {
            retval = [NSString stringWithFormat:format, cur,(cur+step)];
            break;
        }
        
        cur += step;
        
    } while (cur < max);
    
    if (!retval) // should not happen
    {
        return @"unknown";
    }
    
    DLOG(DEFAULT, "Bucket value for %d: %@", value, retval);
    return retval;
}

+(NSString*)bucketForFloatValue:(float)value withStep:(float)step withMax:(float)max withFormat:(NSString*)format withMaxFormat:(NSString*)maxFormat
{
    NSString *retval = nil;
    float cur = 0.0f;
    
    // Special case: check if past maximum
    if (value > max)
    {
        return [NSString stringWithFormat:maxFormat, max];
    }
    
    // Determine bucket
    do
    {
        if ((value >= cur) && (value < (cur+step)))
        {
            retval = [NSString stringWithFormat:format, cur,(cur+step)];
            break;
        }
        
        cur += step;
        
    } while (cur < max);
    
    if (!retval) // should not happen
    {
        return @"unknown";
    }
    
    DLOG(DEFAULT, "Bucket value for %f: %@", value, retval);
    return retval;
}

+ (NSString *)exponentialBucketForTime:(NSTimeInterval)time a:(float)a b:(float)b c:(float)c max:(int)maxMs
{
    NSString *rangeString = @"";
    int timeMs = (time * 1000) + 0.5; // +0.5 because of freaking rounding conversion of double to int
    if ((time >= 0) && (maxMs > 0))
    {
        if (timeMs >= maxMs)
        {
            rangeString = [NSString stringWithFormat:@">%d ms", maxMs];
        }
        else
        {
            int x = 0;
            int rangeStart = 0;
            int rangeEnd = 0;
            do
            {
                rangeStart = rangeEnd;
                rangeEnd = (int)round(a * pow((b + c), x));
                if ((timeMs >= rangeStart) && (timeMs < rangeEnd))
                {
                    rangeString = [NSString stringWithFormat:@"%d-%d ms", rangeStart, rangeEnd];
                    break;
                }
                x++;
            }
            while (rangeEnd < maxMs);
        }
    }
    
    return rangeString;
}

@end
