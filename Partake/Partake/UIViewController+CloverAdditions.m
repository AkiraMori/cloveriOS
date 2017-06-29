//
//  UIViewController+CloverAdditions.m
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "UIViewController+CloverAdditions.h"

@implementation UIViewController (CloverAdditions)

- (void)requiredDismissModalButtonWithTitle:(NSString *)title
{
    if (title == nil || [title isEqualToString:@""]) {
        
        title = @"Back";
        
    }
    
    [self setLeftBarButtonWithTitle:title selector:@selector(dismissModal:)];
}

- (void)requiredPopViewControllerBackButtonWithTitle:(NSString *)title
{
    if (title == nil || [title isEqualToString:@""]) {
        
        title = @"Back";
        
    }
    
    [self setLeftBarButtonWithTitle:title selector:@selector(popViewController:)];
}

- (void)requiredDismissModalBackButton
{
    [self requiredDismissModalButtonWithTitle:nil];
}

- (void)requiredPopViewControllerBackButton
{
    [self requiredPopViewControllerBackButtonWithTitle:nil];
}

#pragma mark - Private Methods

- (void)setLeftBarButtonWithTitle:(NSString *)title selector:(SEL)selector
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:selector];
}

- (void)dismissModal:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
