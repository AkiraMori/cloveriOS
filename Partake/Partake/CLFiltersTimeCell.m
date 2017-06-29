//
//  CLFiltersTimeCell.m
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFiltersTimeCell.h"
#import "UIColor+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"

@interface CLFiltersTimeCell ()

@property (copy, nonatomic) void (^daysValuesBlock)(NSInteger, NSInteger);
@property (assign, nonatomic) BOOL shouldShowPlus;

@end

@implementation CLFiltersTimeCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)configureCellAppearanceWithData:(id)data
{
    self.daysMinContainer.layer.cornerRadius = 3.f;
    self.daysMinContainer.layer.borderWidth  = .5f;
    self.daysMinContainer.layer.borderColor  = [UIColor secondaryBrandColor].CGColor;
    self.daysMinContainer.backgroundColor    = [UIColor clearColor];
    
    self.daysMaxContainer.layer.cornerRadius = 3.f;
    self.daysMaxContainer.layer.borderWidth  = .5f;
    self.daysMaxContainer.layer.borderColor  = [UIColor secondaryBrandColor].CGColor;
    self.daysMaxContainer.backgroundColor    = [UIColor clearColor];
    
    if ([data hasKeys]) {
        
        self.rangeSlider.minimumValue = [data[@"minValue"] integerValue];
        self.rangeSlider.maximumValue = [data[@"maxValue"] integerValue];
        self.shouldShowPlus = [data[@"showPlus"] boolValue];
        
    }
    
    self.rangeSlider.tintColor    = [UIColor secondaryBrandColor];
    
    [self.rangeSlider addTarget:self
                         action:@selector(rangeSliderChangeValue)
               forControlEvents:UIControlEventValueChanged];
    
    [self.rangeSlider addTarget:self
                         action:@selector(daysStartEndChangeValue)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.rangeSlider addTarget:self
                         action:@selector(daysStartEndChangeValue)
               forControlEvents:UIControlEventTouchUpOutside];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        self.infoLabel.text         = dictionary[@"info"];
        
        NSInteger dayStart          = lroundf([dictionary[@"dayStart"] floatValue]);
        NSInteger dayEnd            = lroundf([dictionary[@"dayEnd"]   floatValue]);
        
        self.rangeSlider.upperValue = dayEnd;
        self.rangeSlider.lowerValue = dayStart;
        
        [self updateDaysLabelWithDayStart:dayStart DayEnd:dayEnd];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)rangeSliderChangeValue
{
    [self updateDaysLabelWithDayStart:lroundf(self.rangeSlider.lowerValue) DayEnd:lroundf(self.rangeSlider.upperValue)];

    self.rangeSlider.lowerValue = lroundf(self.rangeSlider.lowerValue);
    self.rangeSlider.upperValue = lroundf(self.rangeSlider.upperValue);
}

- (void)daysStartEndChangeValue
{
    self.daysValuesBlock(self.rangeSlider.lowerValue,
                         self.rangeSlider.upperValue);
}

- (void)getDayStartDayEndValuesWithCompletion:(void (^)(NSInteger dayStart, NSInteger dayEnd))completion
{
    self.daysValuesBlock = completion;
}


#pragma mark - Misc

- (void)updateDaysLabelWithDayStart:(NSInteger)dayStart DayEnd:(NSInteger)dayEnd {
    
    if (dayStart < self.rangeSlider.minimumValue) {
        dayStart = self.rangeSlider.minimumValue;
    }
    
    if (dayEnd > self.rangeSlider.maximumValue) {
        dayEnd = self.rangeSlider.maximumValue;
    }
    
    self.minDaysLabel.text      = [NSString stringWithFormat:@"%lu", dayStart];
    self.maxDaysLabel.text      = [NSString stringWithFormat:@"%lu", dayEnd];
    
    if (self.shouldShowPlus && dayEnd == self.rangeSlider.maximumValue) {
        self.maxDaysLabel.text = [self.maxDaysLabel.text stringByAppendingString:@"+"];
    }
    
}
@end
