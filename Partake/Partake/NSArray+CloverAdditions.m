//
//  NSArray+PartakeAdditions.h
//  Partake
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import "NSArray+CloverAdditions.h"

@implementation NSArray (CloverAdditions)

- (NSArray *)invertedArray
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [self count]; i++) {
        [resultArray insertObject:self[i] atIndex:0];
    }
    
    return [NSArray arrayWithArray:resultArray];
}

- (NSArray *)objectsBeforeIndex:(NSUInteger)index
{
    if ([self count] <= index) {
        return nil;
    }
    
    NSRange objectsRange = NSMakeRange(0, index);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:objectsRange];
    
    return [self objectsAtIndexes:indexSet];
}

- (NSArray *)objectsAfterIndex:(NSUInteger)index
{
    if ([self count] <= index) {
        return nil;
    }
    
    if ([self count] - 1 == index) {
        return @[];
    }
    
    NSRange objectsRange = NSMakeRange(index + 1, [self count] - index - 1);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:objectsRange];
    
    return [self objectsAtIndexes:indexSet];
}

@end
