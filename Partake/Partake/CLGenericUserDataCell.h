//
//  CLGenericUserDataCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APAvatarImageView/APAvatarImageView.h>

#import "CLCollectionViewCell.h"
#import "CLCellConfigurationProtocol.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"

@interface CLGenericUserDataCell : CLCollectionViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *nameAndAgeLabel;

@property (weak, nonatomic) IBOutlet APAvatarImageView *avatarImageView;

@end
