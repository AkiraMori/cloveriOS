//
//  RMessage+PartakeAdditions.h
//  Partake
//
//  Created by Pablo Episcopo on 4/29/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "RMessageView.h"

@interface RMessage (PartakeAdditions)

+ (void)showErrorMessageInViewController:(UIViewController *)viewController;

+ (void)showSuccessMessageWithTitle:(NSString *)title;

+ (void)showErrorMessageWithTitle:(NSString *)title;

+ (void)showNotificationWithTitle:(NSString *)message;

@end
