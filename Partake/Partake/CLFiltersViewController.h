//
//  FiltersViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLFiltersViewController : UITableViewController

- (void)getFilteredActivitiesWithCompletion:(void (^)(NSArray *results))completion;

@end
