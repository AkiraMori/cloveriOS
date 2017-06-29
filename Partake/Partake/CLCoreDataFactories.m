//
//  CLCoreDataFactories.m
//  Partake
//
//  Created by Pablo Episcopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLCoreDataFactories.h"
#import "CLApiClient.h"
#import "NSDate+DateTools.h"
#import "CLDateHelper.h"

@implementation CLCoreDataFactories

+ (NSPredicate *)predicateWithUserDefaults
{
    CLLoggedUser *loggedUser = [CLApiClient sharedInstance].loggedUser;
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    // default age predicate
    [predicates addObject:[NSPredicate predicateWithFormat:@"user.age >= %@ AND user.age <= %@", loggedUser.defaultActivitiesAgeFrom, loggedUser.defaultActivitiesAgeTo]];

    // default gender predicate
    if (![@"both" isEqualToString:loggedUser.defaultActivitiesCreatedBy]) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"user.gender LIKE[cd] %@", loggedUser.defaultActivitiesCreatedBy]];
    }
    
    // default range predicate
    [predicates addObject:[NSPredicate predicateWithFormat:@"distance <= %@", loggedUser.defaultLimitSearchResults]];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

+ (NSPredicate *)predicateWithActivityRequirements
{
    CLLoggedUser *loggedUser = [CLApiClient sharedInstance].loggedUser;
    NSNumber *userAge = loggedUser.age;

#ifdef DEVELOPMENT
    userAge = @32;
#endif
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    // age predicate
    [predicates addObject:[NSPredicate predicateWithFormat:@"ageFilterFrom <= %@ AND ageFilterTo >= %@", userAge, userAge]];
    
    // gender predicate
    [predicates addObject:[NSPredicate predicateWithFormat:@"gender IN %@", [@[@"both"] arrayByAddingObject:loggedUser.gender]]];
    
    // deleted
    [predicates addObject:[NSPredicate predicateWithFormat:@"deleteActivity == NO"]];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

+ (NSPredicate *)predicateWithActivityDate
{
    return [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"activityDate >= %@", [CLDateHelper ISO8601StringForToday]], [NSPredicate predicateWithFormat:@"activityEndDate >= %@", [CLDateHelper ISO8601StringForToday]]]];
}

+ (NSPredicate *)predicateForUserActivities
{
    NSMutableArray *predicates = [NSMutableArray array];
    
    // date predicate
    NSDate *date = [[NSDate date] dateBySubtractingDays:30];
    [predicates addObject:[NSPredicate predicateWithFormat:@"activityEndDateTimeStamp >= %@", @([date timeIntervalSince1970])]];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

+ (NSFetchedResultsController *)allActivities
{
    NSManagedObjectContext *context = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    return [self allActivitiesInContext:context
                          withPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                             [self predicateWithActivityDate],
                                                                                             [self predicateWithUserDefaults],
                                                                                             [self predicateWithActivityRequirements]
                                                                                             ]]
                     sectionNameKeyPath:@"activityDateTitle"];
}

+ (NSFetchedResultsController *)allActivitiesInScratch
{
    NSManagedObjectContext *context = [CLApiClient sharedInstance].scratchManagedObjectContext;
    
    return [self allActivitiesInContext:context
                          withPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                             [self predicateWithActivityDate],
                                                                                             [self predicateWithUserDefaults],
                                                                                             [self predicateWithActivityRequirements]
                                                                                             ]]
                     sectionNameKeyPath:@"activityDateTitle"];
}

+ (NSFetchedResultsController *)allActivitiesInRange
{
    NSManagedObjectContext *context = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    return [self allActivitiesInContext:context
                          withPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                             [self predicateWithActivityDate],
                                                                                             [self predicateWithUserDefaults],
                                                                                             [self predicateWithActivityRequirements]
                                                                                             ]]
                     sectionNameKeyPath:@"activityDateTitle"];
}

/**
 *  All logged user activities
 */
+ (NSFetchedResultsController *)loggedUserActivities
{
    NSManagedObjectContext *context = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    return [self allActivitiesInContext:context
                          withPredicate:[NSPredicate predicateWithFormat:@"user.userId==[c] %@ AND deleteActivity == NO", [CLApiClient sharedInstance].loggedUser.userId]
                     sectionNameKeyPath:nil];
}

+ (NSFetchedResultsController *)pendingRequestsWithFacebookId:(NSString *)facebookId
{
    return [self allRequestsWithPredicate:[NSPredicate predicateWithFormat:@"requestState ==[c] %@ AND userFbId ==[c] %@", kCLStatusRequestPending, facebookId]];
}

+ (NSFetchedResultsController *)acceptedRequestsWithFacebookId:(NSString *)facebookId
{
    return [self allRequestsWithPredicate:[NSPredicate predicateWithFormat:@"requestState ==[c] %@", kCLStatusRequestAccepted]];
}

+ (NSFetchedResultsController *)receivedRequestsWithFacebookId:(NSString *)facebookId
{
    return [self allRequestsWithPredicate:[NSPredicate predicateWithFormat:@"requestState ==[c] %@ AND userFbId !=[c] %@", kCLStatusRequestPending, facebookId]];
}

+ (NSFetchedResultsController *)chattableRequestsWithFacebookId:(NSString *)facebookId
{
    return [self allRequestsWithPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:@[
                                                                                              [NSPredicate predicateWithFormat:@"requestState ==[c] %@", kCLStatusRequestAccepted],
                                                                                              [NSPredicate predicateWithFormat:@"requestState ==[c] %@ AND userFbId !=[c] %@", kCLStatusRequestPending, facebookId]
                                                                                              ]]];
}

#pragma mark - Private Methods

+ (NSFetchedResultsController *)fetchResultsControllerForFetchRequest:(NSFetchRequest *)fetchRequest
                                                 managedObjectContext:(NSManagedObjectContext *)context
                                                   sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                            cacheName:(NSString *)cacheName
{
    NSFetchedResultsController *fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                             managedObjectContext:context
                                                                                               sectionNameKeyPath:sectionNameKeyPath
                                                                                                        cacheName:cacheName];
    
    NSError *error = nil;
    
    if (![fetchResultsController performFetch:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    return fetchResultsController;
}

+ (NSFetchedResultsController *)allActivitiesInContext:(NSManagedObjectContext *)context
                                         withPredicate:(NSPredicate *)predicate
                                    sectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    NSFetchRequest *fetchRequest = [CLActivity fetchRequestForEntity];
    fetchRequest.fetchBatchSize  = 50;
    fetchRequest.predicate       = predicate;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"activityDate"
                                                                 ascending:YES]];
    
    return [self fetchResultsControllerForFetchRequest:fetchRequest
                                  managedObjectContext:context
                                    sectionNameKeyPath:sectionNameKeyPath
                                             cacheName:nil];
}

+ (NSFetchedResultsController *)allRequestsWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [CLRequest fetchRequestForEntity];
    fetchRequest.fetchBatchSize  = 50;
    fetchRequest.predicate       = predicate;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"requestCreatedAt"
                                                                 ascending:YES]];
    
    return [self fetchResultsControllerForFetchRequest:fetchRequest
                                  managedObjectContext:[CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext
                                    sectionNameKeyPath:nil
                                             cacheName:nil];
}

@end
