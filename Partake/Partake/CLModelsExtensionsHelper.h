//
//  CLModelsExtensionsHelper.h
//  Partake
//
//  Created by Pablo Episcopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLRequest.h"
#import "CLActivity.h"

@interface MyCategoryIVars : NSObject

@property (retain, nonatomic) id someObject;

+ (MyCategoryIVars *)fetch:(id)targetInstance;

@end

@interface NSManagedObject (EasyInsert)

@property (retain, nonatomic) NSNumber *isSyncing;

+ (NSFetchRequest *)fetchRequestForFetchedProperty:(NSString *)fetchedPropertyName inManagedObjectContext:(NSManagedObjectContext *)moc;
+ (NSFetchRequest *)fetchRequestForEntity;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
- (void)setCreatedAtToNow;

@end
