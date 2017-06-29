//
//  CLAnalyticsHelper.m
//  Partake
//
//  Created by Maikel on 16/01/16.
//  Copyright © 2016 SCF Ventures LLC. All rights reserved.
//

#import "CLAnalyticsHelper.h"
#import "Flurry.h"

NSString * const kCLFlurryKey = @"22Q2292WTG34XHHF4RB2";

@implementation CLAnalyticsHelper

+ (void)startAnalytics
{
    [Fabric with:@[[Crashlytics class], [Appsee class]]];
    
    [Flurry startSession:kCLFlurryKey];
}

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)params
{
    // Flurry
    [Flurry logEvent:eventName withParameters:params];
    
    // Answers
    [Answers logCustomEventWithName:eventName customAttributes:params];
    
    // Appsee
    [Appsee addEvent:eventName withProperties:params];
}

+ (void)logUserLocation:(CLLocation *)location
{
    [Flurry setLatitude:location.coordinate.latitude
     
              longitude:location.coordinate.longitude
     
     horizontalAccuracy:location.horizontalAccuracy
     
       verticalAccuracy:location.verticalAccuracy];
}

+ (void)logUserDetails:(CLLoggedUser *)loggedUser
{
    if (loggedUser) {
        // Flurry
        [Flurry setUserID:loggedUser.fbUserId];
        [Flurry setAge   :loggedUser.age.intValue];
        [Flurry setGender:loggedUser.gender];
        
        // Appsee
        [Appsee setUserID:loggedUser.fbUserId];
    }
}

+ (void)logPageViewsWithRootController:(id)rootViewController
{
    [Flurry logAllPageViewsForTarget:rootViewController];
}

@end
