//
//  CLActivityDetailsRequestStatusCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLActivityDetailsStatusRequestCell.h"

@implementation CLActivityDetailsStatusRequestCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.statusRequestLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    self.statusRequestLabel.text = dictionary[@"statusRequest"];
}

@end
