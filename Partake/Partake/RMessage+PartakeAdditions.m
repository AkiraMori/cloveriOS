//
//  RMessage+PartakeAdditions.m
//  Partake
//
//  Created by Pablo Episcopo on 4/29/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "RMessage+PartakeAdditions.h"

@implementation RMessage (PartakeAdditions)

+ (void)showErrorMessageInViewController:(UIViewController *)viewController
{
    [RMessage showNotificationInViewController:viewController title:@"Sorry about that!" subtitle:@"Oh no! Something went wrong!" type:RMessageTypeError customTypeName:nil callback:nil];
}

+ (void)showSuccessMessageWithTitle:(NSString *)title
{
    [RMessage showNotificationWithTitle:title
                                    type:RMessageTypeSuccess customTypeName:nil callback:nil];
}

+ (void)showErrorMessageWithTitle:(NSString *)title
{
    [RMessage showNotificationWithTitle:title
                                    type:RMessageTypeError customTypeName:nil callback:nil];
}

+ (void)showNotificationWithTitle:(NSString *)message
{
    [RMessage showNotificationWithTitle:message
                                    type:RMessageTypeNormal customTypeName:nil callback:nil];
}
@end
