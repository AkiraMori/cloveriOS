//
//  NSArray+CloverAdditions.h
//  Partake
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import "UIColor+CloverAdditions.h"

@implementation UIColor (CloverAdditions)

+ (UIColor *)primaryBrandColor
{
    return [UIColor colorWithRed:0.47 green:0.71 blue:0.6 alpha:1];
}

+ (UIColor *)secondaryBrandColor
{
    return [UIColor colorWithRed:1 green:0.59 blue:0.43 alpha:1];
}

+ (UIColor *)standardTextColor
{
    return [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1];
}

+ (UIColor *)secondaryBrandColorLighter
{
    return [UIColor colorWithRed:0.95 green:0.83 blue:0.75 alpha:1];
}

@end
