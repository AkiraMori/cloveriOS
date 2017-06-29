//
//  CLTabBarController.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLHomeViewController.h"
#import "CLNavigationController.h"

@interface CLTabBarController : UITabBarController

@property (strong, nonatomic) CLNavigationController *homeNavigationController;
@property (strong, nonatomic) CLNavigationController *requestsNavigationController;
@property (strong, nonatomic) CLNavigationController *chatNavigationController;
@property (strong, nonatomic) CLNavigationController *createActivityNavigationController;
@property (strong, nonatomic) CLNavigationController *settingsNavigationController;

+ (CLTabBarController   *)sharedInstance;
- (CLHomeViewController *)homeViewControllerSharedInstance;

@end
