//
//  CLActivityHelper.m
//  Partake
//
//  Created by Pablo Episcopo on 3/12/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLDateHelper.h"
#import "NSDate+DateTools.h"
#import "CLActivityHelper.h"
#import "NSDictionary+CloverAdditions.h"

@implementation CLActivityHelper

+ (UIImage *)activityIconWithType:(NSString *)name isPrimaryColor:(BOOL)isPrimary
{
    NSString *activityNomenclature = nil;
    NSString *colorNomenclature;
    
    if (isPrimary) {
        
        colorNomenclature = @"primary-color";
        
    } else {
        
        colorNomenclature = @"secondary-color";
        
    }
    
    if ([name isEqualToString:@"Sports"]) {
        
        activityNomenclature = @"sport";
        
    } else if ([name isEqualToString:@"Food & Drinks"]) {
        
        activityNomenclature = @"drink";
        
    } else if ([name isEqualToString:@"Theater"]) {
        
        activityNomenclature = @"theater";
        
    } else if ([name isEqualToString:@"Music"]) {
        
        activityNomenclature = @"concert";
        
    } else if ([name isEqualToString:@"Movies"]) {
        
        activityNomenclature = @"cinema";
        
    } else if ([name isEqualToString:@"Outdoors"]) {
        
        activityNomenclature = @"outdoor";
        
    } else if ([name isEqualToString:@"Recreation"]) {
        
        activityNomenclature = @"recreation";
        
    }
    
    NSString *imageName = [NSString stringWithFormat:@"activity-%@-%@", activityNomenclature, colorNomenclature];
    
    return [UIImage imageNamed:imageName];
}

+ (NSArray *)activityTypes
{
    return @[
             @"Sports",
             @"Food & Drinks",
             @"Theater",
             @"Music",
             @"Movies",
             @"Outdoors",
             @"Recreation"
             ];
}

+ (BOOL)isTimeFrame:(NSString *)timeFrame
{
    return [[self timeFrames] containsObject:timeFrame];
}

+ (NSArray *)timeFrames
{
    return @[
             @"Morning",
             @"Afternoon",
             @"Evening"
             ];
}

+ (NSDictionary *)activityIconsWithActivityTypeKey
{
    return @{
             @"Sports":        [UIImage imageNamed:@"activity-sport-secondary-color"],
             @"Food & Drinks": [UIImage imageNamed:@"activity-drink-secondary-color"],
             @"Theater":       [UIImage imageNamed:@"activity-theater-secondary-color"],
             @"Music":         [UIImage imageNamed:@"activity-concert-secondary-color"],
             @"Movies":        [UIImage imageNamed:@"activity-cinema-secondary-color"],
             @"Outdoors":      [UIImage imageNamed:@"activity-outdoor-secondary-color"],
             @"Recreation":    [UIImage imageNamed:@"activity-recreation-secondary-color"]
             };
}

+ (NSString *)stringFormatForActivityDateWithFromTime:(NSString *)fromTime toTime:(NSString *)toTime;
{
    if ((![fromTime isEqual:@""] && fromTime != nil) &&
        (![toTime   isEqual:@""] && toTime   != nil)) {
        
        return [NSString stringWithFormat:@"%@ to %@", fromTime, toTime];
        
    }
    
    if ((![fromTime isEqual:@""] && fromTime != nil) &&
        ( [toTime   isEqual:@""] || toTime   == nil)) {
        
        return fromTime;
        
    }
    
    return @"No Available";
}

+ (NSString *)determineStringToShowWithLocation:(CLLocationActivity *)location
{
    NSString *neighborhoodLocality    = (location.neighborhood == nil)            ? location.locality : location.neighborhood;
    
    NSString *neighborhoodLocalitCity = (neighborhoodLocality  == nil)            ? location.city     : neighborhoodLocality;
    
    return [NSString stringWithFormat:@"%@, %@", (neighborhoodLocalitCity == nil) ? location.state    : neighborhoodLocalitCity, location.stateShort];
}

@end
