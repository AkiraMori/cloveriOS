//
//  CLLoggedUser.h
//  Partake
//
//  Created by Pablo Episcopo on 4/7/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLUser.h"
#import "CLProfilePhoto.h"
#import <CoreLocation/CoreLocation.h>

@interface CLLoggedUser : NSObject <NSCoding>

@property (nonatomic, strong)           NSMutableArray *locationsArray;

@property (nonatomic, strong, readonly) NSString       *userId;
@property (nonatomic, strong, readonly) NSString       *fbUserId;
@property (nonatomic, strong, readonly) NSString       *fbUserToken;
@property (nonatomic, strong, readonly) NSString       *firstName;
@property (nonatomic, strong, readonly) NSString       *lastName;
@property (nonatomic, strong, readonly) NSString       *loggedInDateString;
@property (nonatomic, strong, readonly) NSString       *gender;
@property (nonatomic, strong, readonly) NSNumber       *age;
@property (nonatomic, strong, readonly) NSArray        *pictures;

@property (nonatomic, strong, readonly) NSDate         *loggedInDate;
@property (nonatomic, readonly)         BOOL           isFirstTime;

@property (nonatomic, strong) NSNumber *defaultActivitiesAgeFrom;
@property (nonatomic, strong) NSNumber *defaultActivitiesAgeTo;
@property (nonatomic, strong) NSString *defaultActivitiesCreatedBy;
@property (nonatomic, strong) NSNumber *defaultLimitSearchResults;

@property (nonatomic, strong) NSArray *fbProfilePhotos;


- (instancetype)initWithUserId:(NSString *)userId;

/**
 *  Saves logged user data to disk. Use this method to store user's data in disk and reuse it across app launches.
 */
- (void)saveToDisk;

/**
 *  Removes the logged user data from disk. Use this method if user is logging out or something.
 */
- (void)removeFromDisk;

+ (CLLoggedUser *)loggedUserFromDisk;

- (CLLocationCoordinate2D)lastLocation;

@end
