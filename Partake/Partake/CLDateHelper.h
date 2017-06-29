//
//  CLDateHelper.h
//  Partake
//
//  Created by Pablo Episcopo on 2/26/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLDateHelper : NSObject

+ (NSString *)ISO8601StringForToday;

+ (NSDate *)dateFromStringDate:(NSString *)stringDate formatter:(NSString *)stringFormat;

+ (NSString *)stringForSectionWithStringDate:(NSString *)stringDate;

+ (NSString *)stringDayDateFromStringDate:(NSString *)stringDate;

+ (NSString *)stringShortMonthFromStringDate:(NSString *)stringDate;

+ (NSDate *)dateForShortStyleFormatterWithStringDate:(NSString *)stringDate;

+ (NSString *)timeElapsedStringFromDate:(NSDate *)date;

+ (NSString *)UTCStringForDate:(NSDate *)date;
@end
