//
//  CLSearchLocationViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 4/28/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLViewController.h"

@interface CLSearchLocationViewController : CLViewController <UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>

- (void)getLocationValueWithCompletion:(void (^)(NSString *location))completion;

@end
