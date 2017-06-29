//
//  CLMessagesViewController.h
//  Partake
//
//  Created by Maikel on 04/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import <Quickblox/Quickblox.h>


@interface CLMessagesViewController : JSQMessagesViewController

@property (strong, nonatomic) QBChatDialog *chatDialog;

@end
