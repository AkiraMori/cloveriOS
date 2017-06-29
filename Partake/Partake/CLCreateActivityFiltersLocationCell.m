//
//  CLCreateActivityFiltersLocationCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "UIColor+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLCreateActivityFiltersLocationCell.h"

@implementation CLCreateActivityFiltersLocationCell

- (void)awakeFromNib
{
    self.locationButton.layer.cornerRadius = 2.f;
    self.locationButton.layer.borderWidth  = .5f;
    self.locationButton.layer.borderColor  = [UIColor secondaryBrandColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        [self.locationButton setTitle:dictionary[@"location"]
                             forState:UIControlStateNormal];
        
    }
}

@end
