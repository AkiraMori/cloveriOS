//
//  CLOnboardingPrivacyInfoViewController.m
//  Partake
//
//  Created by Maximilian Bosch on 1/6/17.
//  Copyright © 2017 CodigoDelSur. All rights reserved.
//

#import "CLOnboardingPrivacyInfoViewController.h"

@interface CLOnboardingPrivacyInfoViewController ()

@end

@implementation CLOnboardingPrivacyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)facebookLoginTapped:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.parentVC facebookLoginTapped:nil];
    }];
}

@end
