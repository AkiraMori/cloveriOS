//
//  CLTabBar.m
//  Partake
//
//  Created by Pablo Episcopo on 2/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTabBar.h"

#define kCLImageInset     6.f
#define kCLImageInsetZero 0.f

@implementation CLTabBar

- (void)drawRect:(CGRect)rect
{
    [self setTranslucent:NO];
    
//    [self.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
//        
//        item.title       = nil;
//        item.imageInsets = UIEdgeInsetsMake(kCLImageInset,
//                                            kCLImageInsetZero,
//                                            - kCLImageInset,
//                                            kCLImageInsetZero);
//    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    self.backgroundColor = [UIColor colorWithRed:0.34 green:0.35 blue:0.35 alpha:1];
    self.tintColor       = [UIColor whiteColor];
}

@end
