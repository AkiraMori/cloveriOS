//
//  CLCreateActivityAcceptedOwnerCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLActivityDetailsAcceptedOwnerCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

- (void)setOnStartChat:(void(^)())startChat;

@end
