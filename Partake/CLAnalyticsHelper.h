//
//  CLAnalyticsHelper.h
//  Partake
//
//  Created by Maikel on 16/01/16.
//  Copyright © 2016 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"
#import <Appsee/Appsee.h>
#import <Crashlytics/Answers.h>

@interface CLAnalyticsHelper : NSObject

+ (void)startAnalytics;

+ (void)logUserLocation:(CLLocation *)location;
+ (void)logUserDetails:(CLLoggedUser *)loggedUser;
+ (void)logPageViewsWithRootController:(id)rootViewController;

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)params;

@end
