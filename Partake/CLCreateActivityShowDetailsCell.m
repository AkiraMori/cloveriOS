//
//  CLCreateActivityShowDetailsCell.m
//  Partake
//
//  Created by Maikel on 29/10/15.
//  Copyright © 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCreateActivityShowDetailsCell.h"

@interface CLCreateActivityShowDetailsCell ()
@property (copy, nonatomic) void (^getTapAction)();
@end

@implementation CLCreateActivityShowDetailsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)showAction:(id)sender {
    if (self.getTapAction) {
        self.getTapAction();
    }
}

- (void)getTapActionWithBlock:(void(^)())block {
    self.getTapAction = block;
}


@end
