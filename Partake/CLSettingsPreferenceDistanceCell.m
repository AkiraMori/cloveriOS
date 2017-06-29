//
//  CLSettingsPreferenceDistanceCell.m
//  Partake
//
//  Created by Maikel on 13/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsPreferenceDistanceCell.h"

@interface CLSettingsPreferenceDistanceCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (copy, nonatomic) void (^valueUpdatedBlock)(NSInteger);
@end

@implementation CLSettingsPreferenceDistanceCell

#pragma mark - CLConfigureCell

- (void)configureCellWithDictionary:(NSDictionary *)dictionary {
    _slider.value = [dictionary[@"distance"] floatValue];
    _lblDistance.text = [NSString stringWithFormat:@"%d", (int)_slider.value];
}

#pragma mark - Action Block

- (void)getSearchDistanceLimitWithCompletion:(void(^)(NSInteger distance))completion {
    self.valueUpdatedBlock = completion;
}


#pragma mark - Actions

- (IBAction)sliderValueChangedAction:(id)sender {
    UISlider *slider = sender;
    _lblDistance.text = [NSString stringWithFormat:@"%d", (int)slider.value];
    
    if (self.valueUpdatedBlock) {
        self.valueUpdatedBlock((int)slider.value);
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
