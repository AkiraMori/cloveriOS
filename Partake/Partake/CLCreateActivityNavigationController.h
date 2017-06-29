//
//  CLCreateActivityNavigationController.h
//  Partake
//
//  Created by Pablo Episcopo on 4/21/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLNavigationController.h"
#import "CLCreateActivityViewController.h"
#import "CLCreateActivityFiltersViewController.h"
#import "CLCreateActivityPreviewViewController.h"

@interface CLCreateActivityNavigationController : CLNavigationController

@property (strong, nonatomic) CLCreateActivityViewController        *createActivityViewController;
@property (strong, nonatomic) CLCreateActivityFiltersViewController *createActivityFiltersViewController;
@property (strong, nonatomic) CLCreateActivityPreviewViewController *createActivityPreviewViewController;

@property (nonatomic) BOOL isEditingActivity;

@end
