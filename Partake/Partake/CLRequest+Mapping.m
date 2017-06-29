//
//  CLRequest+Mapping.m
//  Partake
//
//  Created by Pablo Episcopo on 3/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLRequest+Mapping.h"
#import "CLUser+Mapping.h"
#import "CLActivity+Mapping.h"


@implementation CLRequest (Mapping)

+ (NSString *)primaryKey
{
    return @"requestId";
}

+ (NSArray *)fetchRequestCleaners
{
    NSMutableArray *fetchRequests = [NSMutableArray array];
    
    [fetchRequests addObject:^NSFetchRequest *(NSURL *URL) {
        
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/request"];
        NSDictionary  *argsDict    = nil;
        
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        
        if (match) {
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
            
            fetchRequest.predicate       = [NSPredicate predicateWithFormat:@"requestState !=[c] %@ AND requestState !=[c] %@",
                                            kCLStatusRequestCancelled,
                                            kCLStatusRequestRejected];
            
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"requestId"
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
                         pathPattern:[@"/request/:" stringByAppendingString:[self primaryKey]]
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
                                                  @"requestId":        [self primaryKey],
                                                  @"userFbId":         @"userFbId",
                                                  @"userName":         @"userName",
                                                  @"userAge":          @"userAge",
                                                  @"userId":           @"userId",
                                                  @"activityName":     @"activityName",
                                                  @"activityDate":     @"activityDate",
                                                  @"activityId":       @"activityId",
                                                  @"activityType":     @"activityType",
                                                  @"requestCreatedAt": @"requestCreatedAt",
                                                  @"requestState":     @"requestState",
                                                  @"requestUpdatedAt": @"requestUpdatedAt",
                                                  @"requestNote":      @"requestNote"
                                                  }];
    
    [mapping setIdentificationAttributes:@[[self primaryKey]]];
    
    if (entityClass != [CLUser class]) {
        
        RKRelationshipMapping *relatedUserMapping     = [RKRelationshipMapping relationshipMappingFromKeyPath:@"requester"
                                                                                                    toKeyPath:@"user"
                                                                                                  withMapping:[CLUser responseMappingFromEntity:[self class]]];
        
        [mapping addPropertyMapping:relatedUserMapping];
        
    }
    
    if (entityClass != [CLUser class]) {
        
        RKRelationshipMapping *relatedActivityMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"activity.creator"
                                                                                                    toKeyPath:@"activityCreator"
                                                                                                  withMapping:[CLUser responseMappingFromEntity:[self class]]];
        
        [mapping addPropertyMapping:relatedActivityMapping];
        
    }

    return mapping;
}

#pragma mark - Descriptors

+ (NSArray *)responseDescriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/request"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/request"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:[CLUser class]]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/request/accept"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:[CLUser class]]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/request/cancel"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:[CLUser class]]
                                                          method:RKRequestMethodPOST
                                                     pathPattern:@"/request/deny"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             ];
}

+ (NSArray *)requestDescriptors
{
    return @[
             [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping]
                                                   objectClass:[self class]
                                                   rootKeyPath:@"request"
                                                        method:RKRequestMethodGET]
             ];
}

@end
