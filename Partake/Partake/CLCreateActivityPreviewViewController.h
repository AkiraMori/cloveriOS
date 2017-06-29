//
//  CLCreateActivityPreviewViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 4/15/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLCreateActivityPreviewViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSString *activityId;
@property (strong, nonatomic) NSString *locationId;

@end
