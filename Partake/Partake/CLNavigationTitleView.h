//
//  CLNavigationTitleView.h
//  Partake
//
//  Created by Pablo Episcopo on 3/26/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLNavigationTitleView : UIView

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
               subtitleHidden:(BOOL)hidden;

- (void)showSubtitle:(BOOL)flag;

@end
