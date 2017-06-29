//
//  CLHomeEmptyTableView.m
//  Partake
//
//  Created by Pablo Episcopo on 3/18/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLHomeEmptyTableView.h"

@implementation CLHomeEmptyTableView

- (id)init
{
    self = [super init];
    
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CLHomeEmptyTableView class])
                                             owner:self
                                           options:nil].firstObject;
    }
    
    return self;
}

@end
