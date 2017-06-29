//
//  CLActivityDetailsHeaderCell.h
//  Partake
//
//  Created by Pablo Episcopo on 3/5/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APAvatarImageView/APAvatarImageView.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLActivityDetailsHeaderCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *nameAndAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mutualFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (weak, nonatomic) IBOutlet UIImageView       *mutualFriendsImageView;
@property (weak, nonatomic) IBOutlet APAvatarImageView *avatarImageView;

- (void)updateMutualFriendsWithCounter:(NSInteger)counter;

@end
