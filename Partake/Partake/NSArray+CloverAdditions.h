//
//  NSArray+PartakeAdditions.h
//  Partake
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Partake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CloverAdditions)

/**
*  Returns an inversed array
*
*  @discussion If the receiver is @[1, 2, 3] the result array will be @[3, 2, 1]
*/
- (NSArray *)invertedArray;

/**
 *  Returns the objects before an index in the array not including the index object
 *
 *  @discussion Let's say that the array is [1, 2, 3, 4, 5] and you want the objects before index 3, it'd result in [1, 2]
 */
- (NSArray *)objectsBeforeIndex:(NSUInteger)index;

/**
 *  Returns the objects after an index in the array not including the index object
 *
 *  @discussion Let's say that the array is [1, 2, 3, 4, 5] and you want the objects after index 3, it'd result in [4, 5]
 */
- (NSArray *)objectsAfterIndex:(NSUInteger)index;

@end
