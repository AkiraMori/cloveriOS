//
//  ActivityCell.h
//  Partake
//
//  Created by Pablo Epíscopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APAvatarImageView/APAvatarImageView.h>

#import "CLTableViewCell.h"
#import "IPDashedLineView.h"
#import "CLCellConfigurationProtocol.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"

@interface CLActivityCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *topSeparator;
@property (weak, nonatomic) IBOutlet UILabel *bottomSeparator;

@property (weak, nonatomic) IBOutlet UILabel *creatorNameAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarBackgroundDropImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventTypeIconImageView;

@property (weak, nonatomic) IBOutlet APAvatarImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet IPDashedLineView *dashedLine;

@property (weak, nonatomic) IBOutlet UIButton *btnLikes;
@property (weak, nonatomic) IBOutlet UIImageView *imgRepeatIcon;

- (void)needsDistanceLayout;

@end
