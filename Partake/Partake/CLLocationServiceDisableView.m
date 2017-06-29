//
//  CLLocationServiceDisableView.m
//  Partake
//
//  Created by Pablo Episcopo on 3/18/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLLocationServiceDisableView.h"

@implementation CLLocationServiceDisableView

- (id)init
{
    self = [super init];
    
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CLLocationServiceDisableView class])
                                             owner:self
                                           options:nil].firstObject;
    }
    
    return self;
}

@end
