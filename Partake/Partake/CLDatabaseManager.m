//
//  CLDatabaseManager.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLDatabaseManager.h"

static CLDatabaseManager * instance = nil;

@interface CLDatabaseManager ()

@end

@implementation CLDatabaseManager

+ (CLDatabaseManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [CLDatabaseManager new];
        
    });
    
    return instance;
}

- (void)removeInstance
{
    instance = nil;
}

- (id)init
{
    self = [super init];
    
    if (!self) {
        
        return nil;
        
    }
    
    [self setup];
    
    return self;
}

- (void)setup
{
    /**
     *  Bind Core Data with RestKit.
     */
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    if (!appName || [appName isEqualToString:@""]) {
        
        appName = @"app";
        
    }
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:[appName stringByAppendingString:@".sqlite"]];
    
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                                                     fromSeedDatabaseAtPath:nil
                                                                          withConfiguration:nil
                                                                                    options:@{
                                                                                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                                                                                              NSInferMappingModelAutomaticallyOption:       @YES
                                                                                              }
                                                                                      error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    /**
     *  Configure a managed object cache to ensure we do not create duplicate objects.
     */
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    _objectStore = managedObjectStore;
}

- (id<RKManagedObjectCaching>)managedObjectCache
{
    return _objectStore.managedObjectCache;
}

- (NSManagedObjectContext *)mainQueuemanagedObjectContext
{
    return _objectStore.mainQueueManagedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return _objectStore.persistentStoreCoordinator;
}

- (NSManagedObjectContext *)persistentStoreManagedObjectContext
{
    return _objectStore.persistentStoreManagedObjectContext;
}

- (NSManagedObjectContext *)generateScratchObjectContext
{
    NSManagedObjectContext *scratchObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    scratchObjectContext.parentContext = _objectStore.persistentStoreManagedObjectContext;

    return scratchObjectContext;
}

- (void)flushDatabase{
    __weak typeof(self) weakSelf = self;
    
    [self.persistentStoreManagedObjectContext performBlockAndWait:^{
        
        __strong typeof(self) strongSelf = weakSelf;
        
        for(NSPersistentStore *store in strongSelf.persistentStoreCoordinator.persistentStores) {
            [strongSelf.persistentStoreCoordinator removePersistentStore:store error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
        }
        
        strongSelf.objectStore = nil;

    }];
}


@end
