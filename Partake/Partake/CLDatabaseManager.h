//
//  CLDatabaseManager.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKManagedObjectStore;

@protocol RKManagedObjectCaching;

@interface CLDatabaseManager : NSObject

@property (strong, nonatomic) RKManagedObjectStore *objectStore;

@property (readonly, strong, nonatomic) id<RKManagedObjectCaching> managedObjectCache;

@property (readonly, strong, nonatomic) NSManagedObjectContext       *mainQueuemanagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext       *persistentStoreManagedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CLDatabaseManager *)sharedInstance;
- (NSManagedObjectContext *)generateScratchObjectContext;

- (void)removeInstance;
- (void)flushDatabase;

@end
