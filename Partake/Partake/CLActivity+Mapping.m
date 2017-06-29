//
//  CLActivity+Mapping.m
//  Partake
//
//  Created by Pablo Episcopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLUser.h"
#import "CLUser+Mapping.h"
#import "CLLocationActivity.h"
#import "CLActivity+Mapping.h"
#import "CLLocationActivity+Mapping.h"

@implementation CLActivity (Mapping)

+ (NSString *)primaryKey
{
    return @"activityId";
}

+ (NSArray *)fetchRequestCleaners
{
    NSMutableArray *fetchRequests = [NSMutableArray array];
    
    [fetchRequests addObject:^NSFetchRequest *(NSURL *URL) {
        
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/activity"];
        NSDictionary  *argsDict    = nil;
        
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
            
//            fetchRequest.predicate       = [NSPredicate predicateWithFormat:@"NOT (user.userId LIKE[cd] %@)", [CLApiClient sharedInstance].loggedUser.userId];
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                           ascending:YES]];
            
            return fetchRequest;
        }
        
        return nil;
    }];
    
    return fetchRequests;
}

+ (NSArray *)routes
{
    return @[
             [RKRoute routeWithClass:[self class]
                         pathPattern:[@"/activities/:" stringByAppendingString:[self primaryKey]]
                              method:RKRequestMethodGET]
             ];
}

+ (RKMapping *)requestMapping
{
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    
    [mapping addAttributeMappingsFromArray:@[[self primaryKey]]];
    
    return mapping;
}

+ (RKMapping *)responseMappingFromEntity:(Class)entityClass;
{
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class])
                                                   inManagedObjectStore:[CLDatabaseManager sharedInstance].objectStore];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id":               [self primaryKey],
                                                  @"date":             @"activityDate",
                                                  @"endDate":          @"activityEndDate",
                                                  @"name":             @"name",
                                                  @"details":          @"details",
                                                  @"fromTime":         @"fromTime",
                                                  @"toTime":           @"toTime",
                                                  @"isAtendeeVisible": @"isAtendeeVisible",
                                                  @"createdAt":        @"createdAt",
                                                  @"updatedAt":        @"updatedAt",
                                                  @"type":             @"type",
                                                  @"visibility":       @"visibility",
                                                  @"gender":           @"gender",
                                                  @"age_filter_from":  @"ageFilterFrom",
                                                  @"age_filter_to":    @"ageFilterTo",
                                                  @"deleted":          @"deleteActivity",
                                                  @"likes":            @"likes",
                                                  @"liked":            @"isLiked",
                                                  }];
    
    [mapping setIdentificationAttributes:@[[self primaryKey]]];
    
    if (entityClass != [CLUser class]) {
        
        RKRelationshipMapping *relatedUserMapping     = [RKRelationshipMapping relationshipMappingFromKeyPath:@"creator"
                                                                                                    toKeyPath:@"user"
                                                                                                  withMapping:[CLUser responseMappingFromEntity:[self class]]];
        
        [mapping addPropertyMapping:relatedUserMapping];
        
    }
    
    if (entityClass != [CLLocationActivity class] && entityClass != [CLRequest class]) {
        
        RKRelationshipMapping *relatedLocationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"location"
                                                                                                    toKeyPath:@"activityLocation"
                                                                                                  withMapping:[CLLocationActivity responseMappingFromEntity:[self class]]];
        
        [mapping addPropertyMapping:relatedLocationMapping];
        
    }
    
    return mapping;
}

#pragma mark - Descriptors

+ (NSArray *)responseDescriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/activity"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/activity"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/activity/edit"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/activity/like"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/activity/unlike"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodDELETE
                                                     pathPattern:@"/activity"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[CLUser responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/activity/attendance"
                                                         keyPath:@"users"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/activity/createdByUser"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:[@"/activity/:" stringByAppendingString:[self primaryKey]]
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/activity/findByQuery"
                                                         keyPath:@"activities"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
             ];
}

+ (NSArray *)requestDescriptors
{
    return @[
             [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping]
                                                   objectClass:[self class]
                                                   rootKeyPath:@"activity"
                                                        method:RKRequestMethodGET]
             ];
}

@end
