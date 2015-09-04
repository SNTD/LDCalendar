//
//  NSDate+extend.h
//
//  Created by lidi on 15/7/28.
//  Copyright (c) 2015年 Wisorg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (extend)

- (BOOL)isToday;

+ (NSDate *)dateStartOfDay:(NSDate *)date;

/**
 Adjust firstDate and secondDate is in the same day or not.
 **/
+ (BOOL)isSameDayWithDate:(NSDate*)firstDate andDate:(NSDate*)secondDate;

+ (BOOL)isSameDayWithTime:(NSTimeInterval )firstTime andTime:(NSTimeInterval )secondTime;
/**
 Return the 0 o'clock time of the "date".
 **/
+ (NSDate*)acquireTimeFromDate:(NSDate*)date;

/**
 Acquire the week index from date.
 **/
+ (NSInteger)acquireWeekDayFromDate:(NSDate*)date;

- (NSInteger)day;
- (NSInteger)month;
- (NSInteger)year;

/* 从时间戳获取特定格式的时间字符串 */
+ (NSString *)stringWithTimestamp:(NSTimeInterval)tt format:(NSString *)format;
@end
