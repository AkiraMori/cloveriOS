//
//  CLOnboardingFacebookViewController.h
//  Partake
//
//  Created by Maikel on 24/11/15.
//  Copyright © 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLOnboardingController.h"

@interface CLOnboardingFacebookViewController : UIViewController

@property (strong, nonatomic) CLOnboardingController *onboardingController;

- (IBAction)nextAction:(id)sender;

@end
