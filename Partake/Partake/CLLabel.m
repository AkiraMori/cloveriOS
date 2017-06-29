//
//  CLLabel.m
//  Partake
//
//  Created by Pablo Episcopo on 3/6/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLLabel.h"

@implementation CLLabel

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0, 5, 0, 5};
    
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
