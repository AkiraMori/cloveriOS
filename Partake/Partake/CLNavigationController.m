//
//  CLNavigationController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "UIView+Positioning.h"
#import "CLNavigationController.h"
#import "UIColor+CloverAdditions.h"

@implementation CLNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:YES];
    
    UIFont  *fontFamily = [UIFont  fontWithName:kCLPrimaryBrandFont
                                           size:18.f];
    
    UIColor *fontColor  = [UIColor whiteColor];
    
    self.navigationBar.translucent         = NO;
    self.navigationBar.tintColor           = [UIColor whiteColor];
    self.navigationBar.barTintColor        = [UIColor primaryBrandColor];
    self.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName: fontColor,
                                               NSFontAttributeName:            fontFamily
                                               };
    
    UIFont *barButtonFontFamily = [UIFont fontWithName:kCLPrimaryBrandFontText
                                                  size:15.f];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: barButtonFontFamily}
                                                forState:UIControlStateNormal];
}

@end
