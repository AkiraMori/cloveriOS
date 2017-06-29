//
//  CLFiltersTableHeaderSection.m
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "UIView+Positioning.h"
#import "UIColor+CloverAdditions.h"
#import "CLFiltersTableHeaderSection.h"

@interface CLFiltersTableHeaderSection ()

@property (strong, nonatomic) UILabel  *labelTitle;

@end

@implementation CLFiltersTableHeaderSection

- (instancetype)initWithTitle:(NSString *)sectionTitle
{
    self = [super init];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.labelTitle               = [UILabel new];
        self.labelTitle.font          = [UIFont  fontWithName:kCLPrimaryBrandFont
                                                         size:14.f];
        
        self.labelTitle.textColor     = [UIColor standardTextColor];
        self.labelTitle.text          = sectionTitle;
        self.labelTitle.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:self.labelTitle];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.labelTitle.frame = CGRectMake(10.f,
                                       0.f,
                                       self.width,
                                       self.height);
}

@end
