//
//  CLActivity+ModelController.m
//  Partake
//
//  Created by Pablo Episcopo on 3/17/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLAppDelegate.h"
#import "CLLocationActivity.h"
#import "CLHomeViewController.h"
#import "CLActivity+ModelController.h"
#import "CLDateHelper.h"

#define kCLMetersPerMile 1609.344

@implementation CLActivity (ModelController)

+ (CLActivity *)getActivityById:(NSString *)activityId
{
    NSManagedObjectContext *moc     = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    NSFetchRequest         *request = [NSFetchRequest new];
    
    NSEntityDescription    *entity  = [NSEntityDescription entityForName:@"CLActivity"
                                                  inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"activityId ==[c] %@", activityId];
    
    [request    setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *array = [moc executeFetchRequest:request
                                        error:&error];
    
    if (array != nil && array.count > 0) {
        
        return [array firstObject];
        
    }
    
    return nil;
}


- (CGFloat)distanceFromActiveUserInMiles
{
    return ([self distanceFromActiveUser] / kCLMetersPerMile);
}

- (void)setDistanceBasedOnRange
{
    NSDictionary *userLocation   = [CLApiClient sharedInstance].loggedUser.locationsArray.lastObject;
    
    CLLocation   *activityCoords = [[CLLocation alloc] initWithLatitude:[self.activityLocation.latitude  floatValue]
                                                              longitude:[self.activityLocation.longitude floatValue]];
    
    CLLocation   *coordinates    = [[CLLocation alloc] initWithLatitude:[userLocation[@"latitude"]  floatValue]
                                                              longitude:[userLocation[@"longitude"] floatValue]];
    
    
#if DEVELOPMENT
    coordinates = [[CLLocation alloc] initWithLatitude:39
                                             longitude:-77];
#endif
    
    NSNumber *distanceStr = @([activityCoords distanceFromLocation:coordinates]);
    self.distance = distanceStr;
}

- (BOOL)isLoggedUserOwner
{
    if ([self.user.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
        
        return YES;
        
    }
    
    return NO;
}

- (BOOL)isRepeated {
    return self.activityEndDateTimeStamp.integerValue >= (self.activityDateTimeStamp.integerValue + 60 * 60 * 24);
}

- (NSString *)name
{
    [self willAccessValueForKey:@"name"];
    
    NSString *name = [[self primitiveValueForKey:@"name"] uppercaseString];

    [self didAccessValueForKey:@"name"];
    
    return name;
}

- (NSNumber *)activityDateTimeStamp
{
    [self willAccessValueForKey:@"activityDate"];
    NSString *activityDate = [self primitiveValueForKey:@"activityDate"];
    [self didAccessValueForKey:@"activityDate"];
    
    NSDate *date = [CLDateHelper dateFromStringDate:activityDate formatter:kCLDateFormatterISO8601];
    return @([date timeIntervalSince1970]);
}

- (NSNumber *)activityEndDateTimeStamp
{
    [self willAccessValueForKey:@"activityEndDate"];
    NSString *activityDate = [self primitiveValueForKey:@"activityEndDate"];
    [self didAccessValueForKey:@"activityEndDate"];
    
    if (activityDate.length) {
        NSDate *date = [CLDateHelper dateFromStringDate:activityDate formatter:kCLDateFormatterISO8601];
        return @([date timeIntervalSince1970]);
    }
    return @0;
}

- (NSString *)activityDateTitle {
    NSDate *date = [CLDateHelper dateFromStringDate:self.activityDate
                                          formatter:kCLDateFormatterISO8601];
    if ([[NSDate date] compare:date] == NSOrderedDescending) {
        date = [NSDate date];
    }
    
    return [CLDateHelper stringForSectionWithStringDate:[CLDateHelper UTCStringForDate:date]];
}

#pragma mark - Private Methods

- (CLLocationDistance)distanceFromActiveUser
{
    if ([CLApiClient sharedInstance].loggedUser.locationsArray.count < 1) {
        
        return 0;
    }
    
    NSDictionary *dictionary       = [CLApiClient sharedInstance].loggedUser.locationsArray.lastObject;
    
    CLLocation   *userLocation     = [[CLLocation alloc] initWithLatitude:[dictionary[@"latitude"]  floatValue]
                                                                longitude:[dictionary[@"longitude"] floatValue]];
#if DEVELOPMENT
    userLocation = [[CLLocation alloc] initWithLatitude:39
                                             longitude:-77];
#endif
    CLLocation   *activityLocation = [[CLLocation alloc] initWithLatitude:[self.activityLocation.latitude  floatValue]
                                                                longitude:[self.activityLocation.longitude floatValue]];
    
    return [userLocation distanceFromLocation:activityLocation];
}

@end
