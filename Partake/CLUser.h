//
//  CLUser.h
//  Partake
//
//  Created by Maikel on 27/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CLUser : NSManagedObject

@property (nonatomic, retain) NSString * aboutMe;
@property (nonatomic, retain) NSDate * activeFrom;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * blocked;
@property (nonatomic, retain) id blockedUsers;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * defaultActivitiesAgeFrom;
@property (nonatomic, retain) NSNumber * defaultActivitiesAgeTo;
@property (nonatomic, retain) NSString * defaultActivitiesCreatedBy;
@property (nonatomic, retain) NSNumber * defaultLimitSearchResults;
@property (nonatomic, retain) NSString * fbUserId;
@property (nonatomic, retain) NSString * fbUserToken;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) id pictures;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * points;

@end
