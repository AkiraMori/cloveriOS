//
//  NSArray+CloverAdditions.h
//  Clover
//
//  Created by Pablo Epíscopo on 2/11/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIAlertView+Blocks.h"

@interface UIAlertView (CloverAdditions)

+ (void)showMessage:(NSString *)message;

+ (void)showMessage:(NSString *)message
              title:(NSString *)title;

+ (void)showErrorMessageWithAcceptAction:(void(^)(void))acceptAction;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
               acceptTitle:(NSString *)acceptTitle
        cancelButtonAction:(void(^)(void))cancelAction
              acceptAction:(void(^)(void))acceptAction;

@end
