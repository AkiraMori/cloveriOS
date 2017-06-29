//
//  CLSettingsPreferenceDistanceCell.h
//  Partake
//
//  Created by Maikel on 13/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLSettingsPreferenceDistanceCell : CLTableViewCell <CLCellConfigurationProtocol>
- (void)getSearchDistanceLimitWithCompletion:(void(^)(NSInteger distance))completion;
@end
