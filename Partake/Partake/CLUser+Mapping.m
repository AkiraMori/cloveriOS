//
//  CLUser+Mapping.m
//  Partake
//
//  Created by Pablo Episcopo on 2/25/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLUser+Mapping.h"

@implementation CLUser (Mapping)

+ (NSString *)primaryKey
{
    return @"userId";
}

+ (NSArray *)fetchRequestCleaners
{
    NSMutableArray *fetchRequests = [NSMutableArray array];
    
    [fetchRequests addObject:^NSFetchRequest *(NSURL *URL) {
        
//        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/user"];
//        NSDictionary  *argsDict    = nil;
//        
//        BOOL match = [pathMatcher matchesPath:[URL relativePath]
//                         tokenizeQueryStrings:NO
//                              parsedArguments:&argsDict];
//        
//        if (match) {
//            
//            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
//            
//            fetchRequest.predicate       = nil;
//            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName"
//                                                                           ascending:YES]];
//            
//            return fetchRequest;
//        }
        
        return nil;
    }];
    
    return fetchRequests;
}

+ (NSArray *)routes
{
    return @[
             [RKRoute routeWithClass:[self class]
                         pathPattern:[@"/users/:" stringByAppendingString:[self primaryKey]]
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
                                                  @"id":                            [self primaryKey],
                                                  @"fbId":                          @"fbUserId",
                                                  @"fbToken":                       @"fbUserToken",
                                                  @"firstName":                     @"firstName",
                                                  @"lastName":                      @"lastName",
                                                  @"gender":                        @"gender",
                                                  @"email":                         @"email",
                                                  @"age":                           @"age",
                                                  @"blocked":                       @"blocked",
                                                  @"aboutMe":                       @"aboutMe",
                                                  @"activeFrom":                    @"activeFrom",
                                                  @"createdAt":                     @"createdAt",
                                                  @"updatedAt":                     @"updatedAt",
                                                  @"default_limit_search_results":  @"defaultLimitSearchResults",
                                                  @"default_activities_created_by": @"defaultActivitiesCreatedBy",
                                                  @"default_activities_age_from":   @"defaultActivitiesAgeFrom",
                                                  @"default_activities_age_to":     @"defaultActivitiesAgeTo",
                                                  @"pictures":                      @"pictures",
                                                  @"blocked_users":                 @"blockedUsers",
                                                  @"karma_point":                   @"points"
                                                  }];
    
    [mapping setIdentificationAttributes:@[[self primaryKey], @"firstName"]];
    
    return mapping;
}

#pragma mark - Descriptors

+ (NSArray *)responseDescriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/user/login"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/user/mutualFriends"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/user/blockUser"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/user/saveDefaultPreferences"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/user/edit"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/user/shared"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
             ];
}

+ (NSArray *)requestDescriptors
{
    return @[
             [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping]
                                                   objectClass:[self class]
                                                   rootKeyPath:@"user"
                                                        method:RKRequestMethodGET]
             ];
}

@end
