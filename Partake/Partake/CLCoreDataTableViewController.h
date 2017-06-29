//
//  CLTableViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMessage.h"
#import "CLConstants.h"
#import "SVProgressHUD.h"
#import "UIView+Positioning.h"
#import "CLNavigationController.h"
#import "UIColor+CloverAdditions.h"
#import "RMessage+PartakeAdditions.h"
#import "UIAlertView+CloverAdditions.h"
#import "UIViewController+SVProgressHUD.h"
#import "UIViewController+CloverAdditions.h"

@protocol CoreDataTableViewControllerProtocol <NSObject>

@required
- (BOOL)shouldUpdateDataIfChangesManagedObject:(NSDictionary *)changes;

@end

@interface CLCoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic)     NSFetchedResultsController           *fetchedResultsController;
@property (weak,   nonatomic) id <CoreDataTableViewControllerProtocol> coreDataTVCDelegate;

/**
 *  Causes the fetchedResultsController to refetch the data.
 *  You almost certainly never need to call this.
 *  The NSFetchedResultsController class observes the context (so if the objects in the context change, you do not need to call performFetch since the NSFetchedResultsController will notice and update the table automatically).
 *  This will also automatically be called if you change the fetchedResultsController @property.
 */
- (void)performFetch;

/**
 *  Set to YES to get some debugging output in the console.
 */
@property BOOL debug;

@end
