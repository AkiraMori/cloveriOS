//
//  CLActivityTypeCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/14/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLCreateActivityTypeCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak,   nonatomic) IBOutlet UIPickerView *typePickerView;
@property (strong, nonatomic)          NSArray      *arrayData;

- (void)getPickerIndexValueWithCompletion:(void (^)(NSInteger pickerIndex))completion;

@end
