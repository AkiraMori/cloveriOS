//
//  NSFetchedResultsController+CloverAdditions.h
//  Clover
//
//  Created by Pablo Epíscopo on 4/3/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchedResultsController (CloverAdditions)

- (BOOL)isUsingScratchManagedObjectContext;

@end
