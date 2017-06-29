//
//  CLNavigationTitleView.m
//  Partake
//
//  Created by Pablo Episcopo on 3/26/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "UIView+Positioning.h"
#import "CLNavigationTitleView.h"
#import "UIColor+CloverAdditions.h"

@interface CLNavigationTitleView ()

@property (strong, nonatomic) UILabel *labelTitle;
@property (strong, nonatomic) UILabel *labelSubtitle;

@end

@implementation CLNavigationTitleView

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
               subtitleHidden:(BOOL)hidden
{
    self = [super init];
    
    if (self) {
        
        self.labelTitle                 = [UILabel new];
        self.labelTitle.frame           = CGRectZero;
        self.labelTitle.textColor       = [UIColor whiteColor];
        self.labelTitle.text            = title;
        self.labelTitle.textAlignment   = NSTextAlignmentCenter;
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font            = [UIFont fontWithName:kCLPrimaryBrandFont
                                                          size:18.f];
        
        [self.labelTitle sizeToFit];
        
        [self addSubview:self.labelTitle];
        
        self.labelSubtitle                 = [UILabel new];
        self.labelSubtitle.frame           = CGRectZero;
        self.labelSubtitle.textColor       = [UIColor whiteColor];
        self.labelSubtitle.text            = subtitle;
        self.labelSubtitle.textAlignment   = NSTextAlignmentCenter;
        self.labelSubtitle.backgroundColor = [UIColor clearColor];
        self.labelSubtitle.alpha           = (hidden) ? 0.f : 1.f;
        self.labelSubtitle.font            = [UIFont fontWithName:kCLPrimaryBrandFont
                                                             size:11.f];
        
        [self.labelSubtitle sizeToFit];
        
        self.frame           = self.labelTitle.frame;
        
        self.labelSubtitle.x = (self.width / 2) - (self.labelSubtitle.width / 2);
        self.labelSubtitle.y = self.labelTitle.height - 6.f;
        
        [self addSubview:self.labelSubtitle];
        
    }
    
    return self;
}

- (void)showSubtitle:(BOOL)flag
{
    [UIView animateWithDuration:.5f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.labelTitle.y        = (flag) ? - 5.f : 0.f;
                         self.labelSubtitle.alpha = (flag) ?   1.f : 0.f;
                         
                     } completion:nil];
}

@end
