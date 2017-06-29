//
//  CLTableViewCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/29/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTableViewCell.h"

@implementation CLTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)reuseIdentifier {
    return [NSString stringWithFormat:@"tvc%@", NSStringFromClass([self class])];
}

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end
