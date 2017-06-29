//
//  CLReportsTableHeaderSection.m
//  Partake
//
//  Created by Maikel on 08/09/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLReportsTableHeaderSection.h"
#import "UIView+Positioning.h"
#import "UIColor+CloverAdditions.h"
#import "CLFiltersTableHeaderSection.h"
#import "CLConstants.h"

@interface CLReportsTableHeaderSection ()

@property (strong, nonatomic) UILabel  *labelTitle;

@end


@implementation CLReportsTableHeaderSection

- (instancetype)initWithTitle:(NSString *)sectionTitle
{
    self = [super init];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.labelTitle               = [UILabel new];
        self.labelTitle.font          = [UIFont  fontWithName:kCLPrimaryBrandFont
                                                         size:15.f];
        
        self.labelTitle.textColor     = [UIColor standardTextColor];
        self.labelTitle.text          = sectionTitle;
        self.labelTitle.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:self.labelTitle];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.labelTitle.frame = CGRectMake(15.f,
                                       self.height - 24.f,
                                       self.width,
                                       20.f);
}

@end
