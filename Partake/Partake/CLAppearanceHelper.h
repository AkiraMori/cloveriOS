//
//  CLAppearanceHelper.h
//  Partake
//
//  Created by Pablo Episcopo on 3/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLAppearanceHelper : NSObject

+ (UIImage *)backgroundDropImageForIndexPath:(NSIndexPath *)indexPath;

+ (UIImage *)backgroundArrowImageForIndexPath:(NSIndexPath *)indexPath;

+ (UIColor *)colorForIndexPath:(NSIndexPath *)indexPath;

+ (NSInteger)calculateHeightWithString:(NSString *)text fontFamily:(NSString *)fontFamilyName fontSize:(CGFloat)fontSize boundingSizeWidth:(CGFloat)width;

+ (void)setupRMessageViewAppearance;
@end
