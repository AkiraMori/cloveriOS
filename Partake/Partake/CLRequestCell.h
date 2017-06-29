//
//  RequestCell.h
//  Partake
//
//  Created by Pablo Episcopo on 3/27/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APAvatarImageView/APAvatarImageView.h>

#import "CLTableViewCell.h"
#import "IPDashedLineView.h"
#import "CLCellConfigurationProtocol.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"

@interface CLRequestCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *topSeparator;
@property (weak, nonatomic) IBOutlet UILabel *bottomSeparator;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestedTimeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarBackgroundDropImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventTypeIconImageView;

@property (weak, nonatomic) IBOutlet APAvatarImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet IPDashedLineView *dashedLine;

@end
