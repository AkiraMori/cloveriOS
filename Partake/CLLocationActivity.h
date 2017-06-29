//
//  CLLocationActivity.h
//  Partake
//
//  Created by Pablo Episcopo on 4/29/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CLLocationActivity : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSString * formattedStreet;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locality;
@property (nonatomic, retain) NSString * locationId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * neighborhood;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * stateShort;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * zip;

@end
