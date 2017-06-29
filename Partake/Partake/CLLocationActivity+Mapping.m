//
//  CLLocationActivity+Mapping.m
//  Partake
//
//  Created by Pablo Episcopo on 3/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLMappingProtocol.h"
#import "CLLocationActivity+Mapping.h"

@implementation CLLocationActivity (Mapping)

+ (NSString *)primaryKey
{
    return @"locationId";
}

+ (NSArray *)fetchRequestCleaners
{
    NSMutableArray *fetchRequests = [NSMutableArray array];
    
    [fetchRequests addObject:^NSFetchRequest *(NSURL *URL) {
        
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/location"];
        NSDictionary  *argsDict    = nil;
        
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        
        if (match) {
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
            
            fetchRequest.predicate       = nil;
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationId"
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
                         pathPattern:[@"/locations/:" stringByAppendingString:[self primaryKey]]
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
                                                  @"formatted_street":  @"formattedStreet",
                                                  @"city":              @"city",
                                                  @"state":             @"state",
                                                  @"zip":               @"zip",
                                                  @"formatted_address": @"formattedAddress",
                                                  @"lat":               @"latitude",
                                                  @"lon":               @"longitude",
                                                  @"createdAt":         @"createdAt",
                                                  @"updatedAt":         @"updatedAt",
                                                  @"locality":          @"locality",
                                                  @"neighborhood":      @"neighborhood",
                                                  @"stateShort":        @"stateShort"
                                                  }];
    
    [mapping setIdentificationAttributes:@[[self primaryKey]]];
    
    return mapping;
}

#pragma mark - Descriptors

+ (NSArray *)responseDescriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self responseMappingFromEntity:nil]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/location"
                                                         keyPath:@"location"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
             ];
}

+ (NSArray *)requestDescriptors
{
    return @[
             [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping]
                                                   objectClass:[self class]
                                                   rootKeyPath:@"location"
                                                        method:RKRequestMethodGET]
             ];
}

@end