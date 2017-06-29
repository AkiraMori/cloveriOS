//
//  CLSettingsSwitchCell.m
//  Partake
//
//  Created by Maikel on 10/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsSwitchCell.h"

@interface CLSettingsSwitchCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

@end

@implementation CLSettingsSwitchCell

#pragma mark - CLTableViewCell

- (void)configureCellWithDictionary:(NSDictionary *)dictionary {
    NSString *title = dictionary[@"title"];
    
    _lblTitle.hidden = _switchControl.hidden = (title.length == 0);
    
    _lblTitle.text = title;
    
    NSNumber *switchValue = dictionary[@"switch"];
    _switchControl.on = [switchValue boolValue];
}

- (IBAction)switchAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(settingsSwitchCell:valueChanged:)]) {
        [self.delegate settingsSwitchCell:self valueChanged:[sender isOn]];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
