//
//  CLGenericFlowCollectionViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 4/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLGenericHeaderCell.h"
#import "CLGenericUserDataCell.h"
#import "CLCollectionViewController.h"

static NSString * const kCLHeaderIdentifier   = @"CLGenericHeaderCell";
static NSString * const kCLUserDataIdentifier = @"CLGenericUserDataCell";

@interface CLGenericFlowCollectionViewController : CLCollectionViewController

@property (strong, nonatomic) NSArray *objectsArray;

@end
