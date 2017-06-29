//
//  CLProfileHeaderCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"


@interface CLProfileHeaderCell : CLTableViewCell <CLCellConfigurationProtocol>
- (void)setReportAction:(id)target selector:(SEL)selector;

@end
