//
//  CLActivityHelper.h
//  Partake
//
//  Created by Pablo Episcopo on 3/12/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLLocationActivity.h"

@interface CLActivityHelper : NSObject

+ (UIImage *)activityIconWithType:(NSString *)name isPrimaryColor:(BOOL)isPrimary;

+ (NSArray *)activityTypes;

+ (NSArray *)timeFrames;

+ (BOOL)isTimeFrame:(NSString *)timeFrame;

+ (NSDictionary *)activityIconsWithActivityTypeKey;

+ (NSString *)stringFormatForActivityDateWithFromTime:(NSString *)fromTime toTime:(NSString *)toTime;

+ (NSString *)determineStringToShowWithLocation:(CLLocationActivity *)location;

@end
