//
//  CLActivity+ModelController.h
//  Partake
//
//  Created by Pablo Episcopo on 3/17/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLActivity.h"

@interface CLActivity (ModelController)

+ (CLActivity *)getActivityById:(NSString *)activityId;

- (CGFloat)distanceFromActiveUserInMiles;

- (void)setDistanceBasedOnRange;

- (BOOL)isLoggedUserOwner;
- (BOOL)isRepeated;

- (NSNumber *)activityDateTimeStamp;
- (NSNumber *)activityEndDateTimeStamp;
- (NSString *)activityDateTitle;

- (NSString *)name;

@end
