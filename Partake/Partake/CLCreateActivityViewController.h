//
//  CLCreateActivityViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 2/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewController.h"

@interface CLCreateActivityViewController : CLTableViewController

@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;
@property (strong, nonatomic) NSString *activityDetails;

@end
