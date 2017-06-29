//
//  TADotView.m
//  TAPageControl
//
//  Created by Tanguy Aladenise on 2015-01-22.
//  Copyright (c) 2015 Tanguy Aladenise. All rights reserved.
//

#import "TADotView.h"

@implementation TADotView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    
    return self;
}


- (void)initialization
{
    self.backgroundColor    = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
    self.layer.borderColor  = [UIColor clearColor].CGColor;
    self.layer.borderWidth  = 2;
}


- (void)changeActivityState:(BOOL)active
{
    if (active) {
        self.backgroundColor   = [UIColor whiteColor];
        self.layer.borderColor = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f].CGColor;
        self.layer.borderWidth = 1;
    } else {
        self.backgroundColor   = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f];
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 2;
    }
}

@end
