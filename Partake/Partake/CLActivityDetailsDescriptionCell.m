//
//  CLActivityDetailsDescriptionCell.m
//  Partake
//
//  Created by Pablo Episcopo on 3/5/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLActivityDetailsDescriptionCell.h"

@implementation CLActivityDetailsDescriptionCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    self.titleLabel.text = dictionary[@"title"];
    self.detailsLabel.text = dictionary[@"activityDetails"];
}

@end
