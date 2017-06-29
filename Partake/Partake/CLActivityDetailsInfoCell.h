//
//  CLActivityDetailsInfoCell.h
//  Partake
//
//  Created by Pablo Episcopo on 3/5/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLActivityDetailsInfoCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateDashLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayEndDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthEndDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;

@property (weak, nonatomic) IBOutlet UIImageView *eventIconImageView;

@property (weak, nonatomic) IBOutlet UIView *containerDateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateWidthConstraint;

@end
