//
//  CLTextField.m
//  Partake
//
//  Created by Pablo Episcopo on 4/9/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTextField.h"
#import "CLConstants.h"
#import "UIView+Positioning.h"
#import "UIColor+CloverAdditions.h"

@implementation CLTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        UIColor *fontColor  = [UIColor standardTextColor];
        UIFont  *fontFamily = [UIFont  fontWithName:kCLPrimaryBrandFontText
                                               size:13.f];
        
        self.backgroundColor = [UIColor secondaryBrandColorLighter];
        self.font            = fontFamily;
        self.textColor       = fontColor;
        self.tintColor       = [UIColor secondaryBrandColor];
        
    }
    
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 9.f, 0.f);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 9.f, 0.f);
}

@end
