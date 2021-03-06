//
//  CLTableViewCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/29/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMessageView.h"
#import "CLConstants.h"
#import "SVProgressHUD.h"
#import "UIView+Positioning.h"
#import "CLNavigationController.h"
#import "UIColor+CloverAdditions.h"
#import "RMessage+PartakeAdditions.h"
#import "UIAlertView+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"
#import "UIViewController+SVProgressHUD.h"
#import "UIViewController+CloverAdditions.h"

@interface CLTableViewCell : UITableViewCell
+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

@end
