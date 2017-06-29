//
//  CLHomeViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLLocationManagerController.h"
#import "CLCoreDataTableViewController.h"

@interface CLHomeViewController : CLCoreDataTableViewController <UISearchBarDelegate, UISearchControllerDelegate, CLLocationManagerControllerDelegate>

@end
