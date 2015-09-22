//
//  NSDate+extend.m
//
//  Created by lidi on 15/7/28.
//  Copyright (c) 2015年 Wisorg. All rights reserved.
//

#import "NSDate+extend.h"

@implementation NSDate (extend)
- (BOOL)isToday
{
    return [[NSDate dateStartOfDay:self] isEqualToDate:[NSDate dateStartOfDay:[NSDate date]]];
}

+ (NSDate *)dateStartOfDay:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components =
    [gregorian               components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                                         NSCalendarUnitDay) fromDate:date];
    return [gregorian dateFromComponents:components];
}

+ (BOOL)isSameDayWithTime:(NSTimeInterval )firstTime andTime:(NSTimeInterval )secondTime{
    NSDate *firstDate = [NSDate dateWithTimeIntervalSince1970:firstTime];
    NSDate *secondDate = [NSDate dateWithTimeIntervalSince1970:secondTime];
    return [firstDate isSameDayWithDate:secondDate];
}

+ (BOOL)isSameDayWithDate:(NSDate *)firstDate andDate:(NSDate *)secondDate {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:firstDate];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:secondDate];
    
    return [comp1 day] == [comp2 day] && 
    [comp1 month] == [comp2 month] && 
    [comp1 year] == [comp2 year];
}

- (BOOL)isSameDayWithDate:(NSDate*)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 day] == [comp2 day] && 
    [comp1 month] == [comp2 month] && 
    [comp1 year] == [comp2 year];
}

+ (NSDate*)acquireTimeFromDate:(NSDate*)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:date];
    NSDate* result = [calendar dateFromComponents:comps];
    return result;
}

+ (NSInteger)acquireWeekDayFromDate:(NSDate*)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitWeekday;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:date];
    return [comps weekday];
}


- (NSInteger)day {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitDay fromDate:self];
    return [components day];
}

- (NSInteger)month {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitMonth fromDate:self];
    return [components month];
}

- (NSInteger)year {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear fromDate:self];
    return [components year];
}

+(NSString *)stringWithTimestamp:(NSTimeInterval)tt format:(NSString *)format
{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:tt];
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	return [formatter stringFromDate:date];
}
@end
