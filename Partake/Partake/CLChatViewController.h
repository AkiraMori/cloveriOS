//
//  CLChatViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 2/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLChatService.h"
#import "CLViewController.h"

@interface CLChatViewController : CLViewController

@property (strong, nonatomic) QBChatDialog *createdDialog;

@end
