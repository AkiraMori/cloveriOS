//
//  CLCreateActivityNavigationController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/21/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCreateActivityNavigationController.h"

@implementation CLCreateActivityNavigationController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        self.createActivityViewController        = [CLCreateActivityViewController        new];
        self.createActivityFiltersViewController = [CLCreateActivityFiltersViewController new];
        self.createActivityPreviewViewController = [CLCreateActivityPreviewViewController new];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
