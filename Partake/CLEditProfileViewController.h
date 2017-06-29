//
//  CLEditProfileViewController.h
//  Partake
//
//  Created by Maikel on 21/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTableViewController.h"

@interface CLEditProfileViewController : CLTableViewController
@property (strong, nonatomic) CLUser *user;

- (IBAction)unwindToProfile:(UIStoryboardSegue *)segue;
@end
