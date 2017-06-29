//
//  NSFetchedResultsController+CloverAdditions.m
//  Clover
//
//  Created by Pablo Epíscopo on 4/3/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "NSFetchedResultsController+CloverAdditions.h"

@implementation NSFetchedResultsController (CloverAdditions)

- (BOOL)isUsingScratchManagedObjectContext
{
    if (self.managedObjectContext == [CLApiClient sharedInstance].scratchManagedObjectContext) {
        
        return YES;
        
    }
    
    return NO;
}

@end
