//
//  CLCoreDataFactories.h
//  Partake
//
//  Created by Pablo Episcopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLCoreDataFactories : NSObject

/**
 *  Activities in Main Queue Context
 */
+ (NSFetchedResultsController *)allActivities;

/**
 *  Activities in Scratch Context
 */
+ (NSFetchedResultsController *)allActivitiesInScratch;

/**
 *  Activities in a 80 kilometers range
 */
+ (NSFetchedResultsController *)allActivitiesInRange;

/**
 *  All logged user activities
 */
+ (NSFetchedResultsController *)loggedUserActivities;

/**
 *  Requests Fetched Results Controllers
 */
+ (NSFetchedResultsController *)pendingRequestsWithFacebookId:(NSString *)facebookId;

+ (NSFetchedResultsController *)acceptedRequestsWithFacebookId:(NSString *)facebookId;

+ (NSFetchedResultsController *)receivedRequestsWithFacebookId:(NSString *)facebookId;

+ (NSFetchedResultsController *)cancelledRequestsWithFacebookId:(NSString *)facebookId;

+ (NSFetchedResultsController *)rejectedRequestsWithFacebookId:(NSString *)facebookId;

+ (NSFetchedResultsController *)chattableRequestsWithFacebookId:(NSString *)facebookId;


+ (NSPredicate *)predicateWithUserDefaults;

+ (NSPredicate *)predicateWithActivityRequirements;

+ (NSPredicate *)predicateForUserActivities;
@end
