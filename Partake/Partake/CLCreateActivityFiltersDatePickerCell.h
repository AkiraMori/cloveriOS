//
//  CLCreateActivityFiltersDatePickerCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLCreateActivityFiltersDatePickerCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (void)getDateValueWithCompletion:(void (^)(NSDate *date, NSString *stringDate))completion;

@end
