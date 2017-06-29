//
//  CLActivityTypeCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/14/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLActivityHelper.h"
#import "UIColor+CloverAdditions.h"
#import "CLCreateActivityTypeCell.h"
#import "NSDictionary+CloverAdditions.h"

#define kCLNumberOfRowsInPicker 1

@interface CLCreateActivityTypeCell () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (copy,   nonatomic) void (^pickerIndexValueBlock)(NSInteger);
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation CLCreateActivityTypeCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        NSInteger index = [dictionary[@"index"] integerValue];
        
        [self.typePickerView selectRow:index
                           inComponent:0
                              animated:NO];
        
        NSString *type = dictionary[@"type"];
        
        if ([type isEqualToString:@"onboarding"]) {
            [self.separatorView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.25f]];
        }
        
    }
}

- (void)getPickerIndexValueWithCompletion:(void (^)(NSInteger))completion
{
    self.pickerIndexValueBlock = completion;
}

#pragma mark - UIPickerView Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return kCLNumberOfRowsInPicker;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.arrayData[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UIColor *fontColor  = [UIColor standardTextColor];
    UIFont  *fontFamily = [UIFont  fontWithName:kCLPrimaryBrandFontText
                                           size:18.f];
    
    return [[NSMutableAttributedString alloc] initWithString:self.arrayData[row]
                                                  attributes:@{
                                                               NSForegroundColorAttributeName: fontColor,
                                                               NSFontAttributeName:            fontFamily
                                                               }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerIndexValueBlock(row);
}

@end
