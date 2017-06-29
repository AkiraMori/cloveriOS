//
//  CLActivityDetailsCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/14/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLCreateActivityDetailsCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UILabel    *characterCount;

- (void)getDetailsValueWithCompletion:(void (^)(NSString *details))completion;

@end
