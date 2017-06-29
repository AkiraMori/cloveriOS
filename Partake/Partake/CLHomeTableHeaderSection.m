//
//  CLTableHeaderSection.m
//  Partake
//
//  Created by Pablo Episcopo on 2/27/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "UIView+Positioning.h"
#import "CLHomeTableHeaderSection.h"
#import "UIColor+CloverAdditions.h"

@interface CLHomeTableHeaderSection ()

@property (strong, nonatomic) UILabel  *labelTitle;

@end

@implementation CLHomeTableHeaderSection

- (instancetype)initWithTitle:(NSString *)sectionTitle
{
    self = [super init];
    
    if (self) {
        
        self.backgroundColor = [UIColor secondaryBrandColor];
        
        self.labelTitle               = [UILabel new];
        self.labelTitle.textColor     = [UIColor whiteColor];
        self.labelTitle.text          = sectionTitle;
        self.labelTitle.textAlignment = NSTextAlignmentLeft;
        self.labelTitle.font          = [UIFont fontWithName:kCLPrimaryBrandFontText
                                                        size:14.f];
        
        [self addSubview:self.labelTitle];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    CGFloat oneThird = (self.superview.width / 3);
    
    self.height = self.height - 4.f;
    self.width  = self.superview.width - oneThird;
    self.x      = oneThird;
    
    self.labelTitle.frame = CGRectMake(10.f, 0.f, self.width, self.height);
}

@end
