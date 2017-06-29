//
//  CLActivity.h
//  Partake
//
//  Created by Pablo Episcopo on 4/29/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLLocationActivity, CLUser;

@interface CLActivity : NSManagedObject

@property (nonatomic, retain) NSString * activityDate;
@property (nonatomic, retain) NSString * activityEndDate;
@property (nonatomic, retain) NSString * activityId;
@property (nonatomic, retain) NSNumber * ageFilterFrom;
@property (nonatomic, retain) NSNumber * ageFilterTo;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * deleteActivity;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * fromTime;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * isAtendeeVisible;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * toTime;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * visibility;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSNumber * isLiked;
@property (nonatomic, retain) CLLocationActivity *activityLocation;
@property (nonatomic, retain) CLUser *user;

@end
