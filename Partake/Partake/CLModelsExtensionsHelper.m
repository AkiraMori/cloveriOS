//
//  CLModelsExtensionsHelper.m
//  Partake
//
//  Created by Pablo Episcopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <objc/runtime.h>

#import "CLModelsExtensionsHelper.h"

@implementation MyCategoryIVars

@synthesize someObject;

+ (MyCategoryIVars *)fetch:(id)targetInstance
{
    static void * compactFetchIVarKey = &compactFetchIVarKey;
    
    MyCategoryIVars *ivars = objc_getAssociatedObject(targetInstance, &compactFetchIVarKey);
    
    if (ivars == nil) {
        objc_setAssociatedObject(targetInstance, &compactFetchIVarKey, [MyCategoryIVars new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return ivars;
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)dealloc
{
    self.someObject = nil;
}

@end

@implementation NSManagedObject (EasyInsert)

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                         inManagedObjectContext:context];
}

- (void)setCreatedAtToNow
{
    if (![self isUpdated] && ![self isDeleted]) {
        
        if (![self valueForKey:@"createdAt"] && [self respondsToSelector:@selector(createdAt)]) {
            [self setValue:[NSDate date] forKey:@"createdAt"];
        }
    }
}

- (NSNumber *)isSyncing
{
    return [MyCategoryIVars fetch:self].someObject;
}

- (void)setIsSyncing:(NSNumber *)isSyncing
{
    [MyCategoryIVars fetch:self].someObject = isSyncing;
}

+ (NSFetchRequest *)fetchRequestForFetchedProperty:(NSString *)fetchedPropertyName inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self)
                                              inManagedObjectContext:moc];
    
    NSFetchedPropertyDescription *fetchedProperty = [[entity propertiesByName] objectForKey:fetchedPropertyName];
    
    return [fetchedProperty fetchRequest];
}

+ (NSFetchRequest *)fetchRequestForEntity
{
    return [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
}

@end
