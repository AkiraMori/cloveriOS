//
//  NSArray+CloverAdditions.h
//  Clover
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import "UIAlertView+CloverAdditions.h"

@implementation UIAlertView (CloverAdditions)

+ (void)showMessage:(NSString *)message
{
    [self showMessage:message title:nil];
}

+ (void)showMessage:(NSString *)message title:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil]
     show];
}

+ (void)showErrorMessageWithAcceptAction:(void(^)(void))acceptAction
{
    [[[UIAlertView alloc] initWithTitle:@"Oh no!"
                                message:@"Something went wrong!"
                       cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"]
                       otherButtonItems:[RIButtonItem itemWithLabel:@"Try Again"
                                                             action:^{
                                                                 
                                                                 acceptAction();
                                                                 
                                                             }], nil] show];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
               acceptTitle:(NSString *)acceptTitle
        cancelButtonAction:(void(^)(void))cancelAction
              acceptAction:(void(^)(void))acceptAction
{
    RIButtonItem *cancelButtonItem = nil;
    if (cancelTitle != nil) cancelButtonItem = [RIButtonItem itemWithLabel:cancelTitle action:cancelAction];
    
    RIButtonItem *acceptButtonItem = nil;
    if (acceptTitle != nil) acceptButtonItem = [RIButtonItem itemWithLabel:acceptTitle action:acceptAction];
    
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                       cancelButtonItem:cancelButtonItem
                       otherButtonItems:acceptButtonItem, nil]
     show];
}

@end
