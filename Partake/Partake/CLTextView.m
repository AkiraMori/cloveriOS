//
//  CLTextView.m
//  Partake
//
//  Created by Pablo Episcopo on 4/9/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTextView.h"
#import "CLConstants.h"
#import "UIView+Positioning.h"
#import "UIColor+CloverAdditions.h"

@implementation CLTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        UIColor *fontColor  = [UIColor standardTextColor];
        UIFont  *fontFamily = [UIFont  fontWithName:kCLPrimaryBrandFontText
                                               size:13.f];
        
        self.backgroundColor    = [UIColor secondaryBrandColorLighter];
        self.font               = fontFamily;
        self.textColor          = fontColor;
        self.tintColor          = [UIColor secondaryBrandColor];
        self.textContainerInset = UIEdgeInsetsMake(10.f, 5.f, 10.f, 5.f);
        
    }
    
    return self;
}

@end
