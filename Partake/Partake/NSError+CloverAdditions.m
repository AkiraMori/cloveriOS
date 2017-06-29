//
//  NSArray+CloverAdditions.h
//  Clover
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import "NSError+CloverAdditions.h"
#import "UIApplication+CloverAdditions.h"

@implementation NSError (CloverAdditions)

+ (NSError *)errorWithMessage:(NSString *)message
{
    if (!message) {
        return nil;
    }
    
    return [NSError errorWithDomain:[UIApplication sharedApplication].applicationDomain
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

+ (NSError *)errorFromException:(NSException *)exception
{
    if (!exception) {
        return nil;
    }
    
    return [NSError errorWithDomain:[UIApplication sharedApplication].applicationDomain
                               code:0
                           userInfo:exception.userInfo];
}

@end
