//
//  NSArray+CloverAdditions.h
//  Partake
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (TextKerning)

- (void)setText:(NSString *)text withKerning:(CGFloat)kerning;

@end
