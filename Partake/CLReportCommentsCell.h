//
//  CLReportCommentsCell.h
//  Partake
//
//  Created by Maikel on 08/09/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLReportCommentsCell : CLTableViewCell <CLCellConfigurationProtocol>

- (void)getCommentTextWithCompletion:(void(^)(NSString *))completion;

@end
