//
//  CLActivityCreatedCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/16/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLActivityCreatedCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel     *dayDateLabel;
@property (weak, nonatomic) IBOutlet UILabel     *monthDateLabel;
@property (weak, nonatomic) IBOutlet UILabel     *expiresLabel;

@property (weak, nonatomic) IBOutlet UIButton    *deleteButton;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UIView      *containerDateView;
@property (weak, nonatomic) IBOutlet UIView      *topFrame;

@property (weak, nonatomic) IBOutlet UILabel     *leftFrame;
@property (weak, nonatomic) IBOutlet UILabel     *rightFrame;
@property (weak, nonatomic) IBOutlet UILabel     *bottomFrame;

@end
