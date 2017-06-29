//
//  UIViewController+SVProgressHUD.m
//  Fodessa
//
//  Created by Enrique Bermudez on 7/25/13.
//  Improved by Pablo Episcopo on 26/02/15.
//  Copyright (c) 2013 Enrique Bermudez. All rights reserved.
//

#import "UIViewController+SVProgressHUD.h"

@implementation UIViewController (SVProgressHUD)

/**
 *  Display the progress of an ongoing task with a given text
 *
 *  @param text: Text to be displayed on the ProgressHUD
 */
- (void)showProgressHUDWithStatus:(NSString *)status
{
    [[self view] setUserInteractionEnabled:NO];
    
    [SVProgressHUD showWithStatus:status
                         maskType:SVProgressHUDMaskTypeGradient];
}

/**
 *  Display a success ProgressHUD alert with gievn text and default success image
 *
 *  @param status Success message to display
 */
- (void)showSuccessWithStatus:(NSString *)status
{
    [[self view] setUserInteractionEnabled:NO];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showSuccessWithStatus:status];
    
    [[self view] setUserInteractionEnabled:YES];
}

/**
 *  Display an error ProgressHUD alert with given text and default error image
 *
 *  @param status Error message to display
 */
- (void)showErrorWithStatus:(NSString *)status
{
    [[self view] setUserInteractionEnabled:NO];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showErrorWithStatus:status];
    
    [[self view] setUserInteractionEnabled:YES];
}

/**
 *  Display a success ProgressHUD alert with text "Searching..."
 */
- (void)showSearchingProgressHUD
{
    [self showProgressHUDWithStatus:@"Searching..."];
}

/**
 *  Dismiss the ProgressHUD removing it from the view
 */
- (void)dismissProgressHUD
{
    [[self view] setUserInteractionEnabled:YES];
    
    [SVProgressHUD dismiss];
}

@end
