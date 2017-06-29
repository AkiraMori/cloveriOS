//
//  NSArray+CloverAdditions.h
//  Clover
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (CloverAdditions)

+ (NSError *)errorWithMessage:(NSString *)message;
+ (NSError *)errorFromException:(NSException *)exception;

@end
