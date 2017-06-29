//
//  CLActivityViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 3/4/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLViewController.h"
#import "CLUser+ModelController.h"
#import "CLActivity+ModelController.h"
#import "CLRequest+ModelController.h"

@interface CLActivityDetailsViewController : CLViewController 

@property (strong, nonatomic) NSString *activityId;

@property (strong, nonatomic) CLUser   *headerUser;
@property (strong, nonatomic) NSString *footerText;
@property (strong, nonatomic) NSString *footerTextTitle;

@end
