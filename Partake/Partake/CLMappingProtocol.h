//
//  CLMappingProtocol.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMapping;
@class RKRequestDescriptor;
@class RKResponseDescriptor;

@protocol CLMappingProtocol <NSObject>

@required
+ (NSString *)primaryKey;

+ (NSArray *)responseDescriptors;
+ (NSArray *)requestDescriptors;

+ (RKMapping *)requestMapping;
+ (RKMapping *)responseMappingFromEntity:(Class)entityClass;

+ (NSArray *)routes;

@optional
+ (NSArray *)fetchRequestCleaners;
+ (NSArray *)paginatorsMapping;

@end