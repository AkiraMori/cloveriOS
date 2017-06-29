//
//  NSArray+CloverAdditions.h
//  Partake
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import "UILabel+TextKerning.h"

@implementation UILabel (TextKerning)

- (void)setText:(NSString *)text withKerning:(CGFloat)kerning
{
    if ([self respondsToSelector:@selector(setAttributedText:)]) {
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
        [attributedString addAttribute:NSKernAttributeName
                                 value:[NSNumber numberWithFloat:kerning]
                                 range:NSMakeRange(0, [text length])];
        
        [self setAttributedText:attributedString];
    } else {
        
        [self setText:text];
    }
}

- (void)setKerning:(CGFloat)kerning
{
    [self setText:self.text withKerning:kerning];
}

@end
