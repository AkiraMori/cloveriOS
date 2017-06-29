//
//  CLRequestEmptyTableView.m
//  Partake
//
//  Created by Pablo Episcopo on 3/31/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLRequestEmptyTableView.h"

@implementation CLRequestEmptyTableView

- (id)init
{
    self = [super init];
    
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CLRequestEmptyTableView class])
                                             owner:self
                                           options:nil].firstObject;
    }
    
    return self;
}

@end
