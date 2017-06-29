//
//  CLActivityDetailsDescriptionCell.h
//  Partake
//
//  Created by Pablo Episcopo on 3/5/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLLabel.h"
#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLActivityDetailsDescriptionCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet CLLabel *titleLabel;

@property (weak, nonatomic) IBOutlet CLLabel *detailsLabel;

@end
