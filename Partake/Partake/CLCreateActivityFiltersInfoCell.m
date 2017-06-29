//
//  CLCreateActivityInfoCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLDateHelper.h"
#import "CLCreateActivityFiltersInfoCell.h"

@implementation CLCreateActivityFiltersInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellAppearanceWithData:(id)data
{
    if (data != nil) {
        
        NSDictionary *dictionary = data;
        
        self.infoLabel.text  = dictionary[@"infoLabel"];
        self.valueLabel.text = dictionary[@"valueLabel"];
        
        NSString *type = dictionary[@"type"];
        if ([type isEqualToString:@"onboarding"]) {
            _separatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.25f];
        }
        
    }
}

@end
