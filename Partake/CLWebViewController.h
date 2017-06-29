//
//  CLWebViewController.h
//  Partake
//
//  Created by Maikel on 10/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLViewController.h"

@interface CLWebViewController : CLViewController
@property (copy, nonatomic) NSString *navigationBarTitle;
@property (copy, nonatomic) NSString *URL;
@end
