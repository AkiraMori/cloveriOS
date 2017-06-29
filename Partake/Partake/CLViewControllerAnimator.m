//
//  BLPAnimator.m
//  Blipic
//
//  Created by Pablo Episcopo on 8/6/14.
//  Copyright (c) 2014 SCF Ventures LLC. All rights reserved.
//

#import "CLAppDelegate.h"
#import "CLViewControllerAnimator.h"

@implementation CLViewControllerAnimator

+ (void)animateWithTabBarController
{
    [CLViewControllerAnimator animateWithRootViewController:[CLAppDelegate sharedInstance].tabBarController];
    
    [UIView transitionWithView:[CLAppDelegate sharedInstance].window
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [[CLAppDelegate sharedInstance] showTabBar];
                    }
                    completion:nil
     ];
}

+ (void)animateWithRootViewController:(UIViewController *)viewController
{
    [UIView transitionWithView:[CLAppDelegate sharedInstance].window
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [CLAppDelegate sharedInstance].window.rootViewController = viewController;
                    }
                    completion:nil
     ];
}

@end
