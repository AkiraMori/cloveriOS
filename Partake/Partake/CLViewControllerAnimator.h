//
//  BLPAnimator.h
//  Blipic
//
//  Created by Pablo Episcopo on 8/6/14.
//  Copyright (c) 2014 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLViewControllerAnimator : NSObject

/**
 *  This method animate the transition to TabBarController with
 *  a Cross Dissolve effect.
 */
+ (void)animateWithTabBarController;

/**
 *  This method animate the transition to the view controller send as parameter.
 *
 *  @param viewController View Controller that's going to be the new root view.
 */
+ (void)animateWithRootViewController:(UIViewController *)viewController;

@end
