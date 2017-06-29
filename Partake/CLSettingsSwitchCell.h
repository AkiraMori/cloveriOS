//
//  CLSettingsSwitchCell.h
//  Partake
//
//  Created by Maikel on 10/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@protocol CLSettingsSwitchCellDelegate;
@interface CLSettingsSwitchCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (assign, nonatomic) id<CLSettingsSwitchCellDelegate> delegate;
@end

@protocol CLSettingsSwitchCellDelegate <NSObject>
- (void)settingsSwitchCell:(CLSettingsSwitchCell *)cell valueChanged:(BOOL)value;
@end