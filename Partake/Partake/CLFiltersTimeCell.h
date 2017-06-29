//
//  CLFiltersTimeCell.h
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMRangeSlider.h"
#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLFiltersTimeCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *minDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxDaysLabel;

@property (weak, nonatomic) IBOutlet UIView  *daysMinContainer;
@property (weak, nonatomic) IBOutlet UIView  *daysMaxContainer;

@property (weak, nonatomic) IBOutlet NMRangeSlider *rangeSlider;

- (void)getDayStartDayEndValuesWithCompletion:(void (^)(NSInteger dayStart, NSInteger dayEnd))completion;

@end
