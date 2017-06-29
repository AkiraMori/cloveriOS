//
//  CLOnboardingController.h
//  Partake
//
//  Created by Maikel on 24/11/15.
//  Copyright © 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLOnboardingController : UIPageViewController

@property (assign, nonatomic) NSInteger currentPage;
- (void)gotoNextPage;
@property (assign, nonatomic) BOOL shouldRerequestPermissions;

@end
