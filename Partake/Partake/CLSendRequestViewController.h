//
//  CLSendRequestViewController.h
//  Partake
//
//  Created by Pablo Epíscopo on 4/3/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLSendRequestViewController : UIViewController

@property (strong, nonatomic) CLActivity *activity;

- (void)updateBarButtonWithCompletion:(void (^)(BOOL flag))completion;

@end
