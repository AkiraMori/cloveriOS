//
//  CLDateHelper.m
//  Partake
//
//  Created by Pablo Episcopo on 2/26/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLDateHelper.h"
#import "NSDate+DateTools.h"
#import "CLConstants.h"

@implementation CLDateHelper

+ (NSString *)ISO8601StringForToday
{
    NSString *today = [[self localDateFormatterWithFormatString:kCLDateFormatterYearMonthDayDashed] stringFromDate:[NSDate date]];
    return [today stringByAppendingString:@"T00:00:00.000Z"];
}

+ (NSDate *)dateFromStringDate:(NSString *)stringDate formatter:(NSString *)stringFormat;
{
//    if ([kCLDateFormatterISO8601 isEqualToString:stringFormat]) {
//        return [[self UTCDateFormatterWithFormatString:stringFormat] dateFromString:stringDate];
//    }
    
    NSDate *date = [[self localDateFormatterWithFormatString:[stringFormat componentsSeparatedByString:@"T"].firstObject]
                    dateFromString:[stringDate componentsSeparatedByString:@"T"].firstObject];
//    NSDate *date = [[self localDateFormatterWithFormatString:stringFormat] dateFromString:stringDate];
    return date;
}

+ (NSString *)stringForSectionWithStringDate:(NSString *)stringDate
{
    NSDate *date = [self dateFromStringDate:stringDate formatter:kCLDateFormatterISO8601];
    return [[self localDateFormatterWithFormatString:@"EEEE, MMMM d"] stringFromDate:date];
}

+ (NSString *)stringDayDateFromStringDate:(NSString *)stringDate
{
    NSDate *date = [self dateFromStringDate:stringDate formatter:kCLDateFormatterISO8601];
    
    return [[self localDateFormatterWithFormatString:@"dd"] stringFromDate:date];
}

+ (NSString *)stringShortMonthFromStringDate:(NSString *)stringDate
{
    NSDate *date = [self dateFromStringDate:stringDate formatter:kCLDateFormatterISO8601];
    
    return [[self localDateFormatterWithFormatString:@"MMM"] stringFromDate:date];
}

+ (NSDate *)dateForShortStyleFormatterWithStringDate:(NSString *)stringDate
{
    NSDateFormatter *dateFormat = [self localDateFormatterWithFormatString:nil];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    
    return [dateFormat dateFromString:stringDate];
}

+ (NSString *)UTCStringForDate:(NSDate *)date {
    return [[self localDateFormatterWithFormatString:kCLDateFormatterISO8601] stringFromDate:date];
}

+ (NSString *)timeElapsedStringFromDate:(NSDate *)date {
    if (!date) {
        return @"";
    }
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Get conversion to months, days, hours, minutes
    NSDateComponents *dateComponents = [sysCalendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay |
                                        NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear
                                                      fromDate:date
                                                        toDate:[NSDate date]
                                                       options:0];
    
    // Return appropriate description string
    if (dateComponents.year) {
        return [NSString stringWithFormat:@"%ld years ago", (long)dateComponents.year];
        
    } else if (dateComponents.month) {
        return [NSString stringWithFormat:@"%ld months ago", (long)dateComponents.month];
        
    } else if (dateComponents.weekOfMonth) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)dateComponents.weekOfMonth];
        
    } else if (dateComponents.day) {
        return [NSString stringWithFormat:@"%ld days ago", (long)dateComponents.day];
        
    } else if (dateComponents.hour) {
        return [NSString stringWithFormat:@"%ld hours ago", (long)dateComponents.hour];
        
    } else if (dateComponents.minute > 1) {
        return [NSString stringWithFormat:@"%ld minutes ago", (long)dateComponents.minute];
        
    } else {
        return @"just now";
    }
}


#pragma mark - Private Methods

+ (NSDateFormatter *)localDateFormatterWithFormatString:(NSString *)formatString
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    }
    
    dateFormatter.dateFormat = formatString;
    
    return dateFormatter;
}

//+ (NSDateFormatter *)UTCDateFormatterWithFormatString:(NSString *)formatString
//{
//    static NSDateFormatter *dateFormatter;
//
//    if (!dateFormatter) {
//        dateFormatter = [[NSDateFormatter alloc] init];
//        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    }
//    
//    dateFormatter.dateFormat = formatString;
//    
//    return dateFormatter;
//}

@end
