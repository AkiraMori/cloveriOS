//
//  CLCreateActivityFiltersAttendeeVisibleCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLCreateActivityFiltersAttendeeVisibleCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UISwitch *attendeeVisibleSwitch;

- (void)getSwitchValueWithCompletion:(void (^)(BOOL attendeeVisible))completion;

@end
