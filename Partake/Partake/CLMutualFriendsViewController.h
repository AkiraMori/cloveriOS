//
//  CLMutualFriendsViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 4/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLGenericFlowCollectionViewController.h"

@interface CLMutualFriendsViewController : CLGenericFlowCollectionViewController

@property (strong, nonatomic) NSString *activityOwnerFbId;
@property (strong, nonatomic) NSString *activityOwnerFirstName;

@end
