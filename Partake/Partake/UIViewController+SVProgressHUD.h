//
//  UIViewController+SVProgressHUD.h
//  Fodessa
//
//  Created by Enrique Bermudez on 7/25/13.
//  Improved by Pablo Episcopo on 26/02/15.
//  Copyright (c) 2013 Enrique Bermudez. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SVProgressHUD.h"

@interface UIViewController (SVProgressHUD)

/**
 *  Display the progress of an ongoing task with a given text
 *
 *  @param text: Text to be displayed on the ProgressHUD
 */
- (void)showProgressHUDWithStatus:(NSString *)status;

/**
 *  Display a success ProgressHUD alert with given text and default success image
 *
 *  @param status Success message to display
 */
- (void)showSuccessWithStatus:(NSString *)status;

/**
 *  Display an error ProgressHUD alert with given text and default error image
 *
 *  @param status Error message to display
 */
- (void)showErrorWithStatus:(NSString *)status;

/**
 *  Display a success ProgressHUD alert with text "Searching..."
 */
- (void)showSearchingProgressHUD;

/**
 *  Dismiss the ProgressHUD removing it from the view
 */
- (void)dismissProgressHUD;

@end
