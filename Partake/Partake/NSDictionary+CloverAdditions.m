//
//  NSDictionary+CloverAdditions.m
//  Clover
//
//  Created by Pablo Episcopo on 4/15/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "NSDictionary+CloverAdditions.h"

@implementation NSDictionary (CloverAdditions)

- (BOOL)hasKeys
{
    if (self == nil) {
        
        return NO;
        
    }
    
    return self.allKeys.count > 0;
}

@end
