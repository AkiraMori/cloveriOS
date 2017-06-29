//
//  CLAppearanceHelper.m
//  Partake
//
//  Created by Pablo Episcopo on 3/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLLabel.h"
#import "CLAppearanceHelper.h"
#import "UIColor+CloverAdditions.h"
#import "RMessageView.h"

@implementation CLAppearanceHelper

+ (UIImage *)backgroundDropImageForIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? [UIImage imageNamed:@"activity-avatar-primary-color"] : [UIImage imageNamed:@"activity-avatar-secondary-color"];
}

+ (UIImage *)backgroundArrowImageForIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? [UIImage imageNamed:@"activity-details-pointer-primary"] : [UIImage imageNamed:@"activity-details-pointer"];
}

+ (UIColor *)colorForIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? [UIColor primaryBrandColor] : [UIColor secondaryBrandColor];
}

+ (NSInteger)calculateHeightWithString:(NSString *)text fontFamily:(NSString *)fontFamilyName fontSize:(CGFloat)fontSize boundingSizeWidth:(CGFloat)width
{
    CGFloat marginValue = 40.f;
    
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    
    UIFont *font = [UIFont fontWithName:fontFamilyName
                                   size:fontSize];
    
    CLLabel *calculationView = [CLLabel new];
    calculationView.text     = text;
    calculationView.font     = font;
    
    CGRect textRect = [calculationView.text boundingRectWithSize:CGSizeMake(width - 14.f, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:font}
                                                         context:ctx];
    
    return textRect.size.height + marginValue;
}

+ (void)setupRMessageViewAppearance
{
    //[RMessageView addNotificationDesignFromFile:@"RMessages.json"];
}

@end
