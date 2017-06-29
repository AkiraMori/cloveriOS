//
//  CLRequest.h
//  Partake
//
//  Created by Maikel on 27/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CLUser;

@interface CLRequest : NSManagedObject

@property (nonatomic, retain) NSString * activityDate;
@property (nonatomic, retain) NSString * activityId;
@property (nonatomic, retain) NSString * activityName;
@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSDate * requestCreatedAt;
@property (nonatomic, retain) NSString * requestId;
@property (nonatomic, retain) NSString * requestNote;
@property (nonatomic, retain) NSString * requestState;
@property (nonatomic, retain) NSDate * requestUpdatedAt;
@property (nonatomic, retain) NSNumber * userAge;
@property (nonatomic, retain) NSString * userFbId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) CLUser *user;
@property (nonatomic, retain) CLUser *activityCreator;

@end
