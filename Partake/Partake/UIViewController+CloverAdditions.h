//
//  UIViewController+CloverAdditions.h
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CloverAdditions)

- (void)requiredDismissModalButtonWithTitle:(NSString *)title;
- (void)requiredPopViewControllerBackButtonWithTitle:(NSString *)title;

- (void)requiredDismissModalBackButton;
- (void)requiredPopViewControllerBackButton;

@end
