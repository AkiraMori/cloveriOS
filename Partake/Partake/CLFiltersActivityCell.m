//
//  CLFiltersActivityCell.m
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFiltersActivityCell.h"

@interface CLFiltersActivityCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabel_X;

@end

@implementation CLFiltersActivityCell

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
    self.iconImageView.backgroundColor = [UIColor clearColor];
    
    if ([data[@"hideIcon"] boolValue]) {
        
        self.nameLabel_X.constant = 32.f;
        self.iconImageView.hidden = YES;
        
    } else {
        
        self.nameLabel_X.constant = 58.f;
        self.iconImageView.hidden = NO;
        
    }
    
    [self layoutIfNeeded];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary) {
        
        self.nameLabel.text           = dictionary[@"name"];
        self.iconImageView.image      = dictionary[@"icon"];
        self.checkmarkImageView.image = dictionary[@"checkmark"];
        
    }
}

@end
