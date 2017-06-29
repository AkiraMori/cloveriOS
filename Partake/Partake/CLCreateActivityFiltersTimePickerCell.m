//
//  CLCreateActivityFiltersTimePickerCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "NSDate+DateTools.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLCreateActivityFiltersTimePickerCell.h"

@interface CLCreateActivityFiltersTimePickerCell ()

@property (copy, nonatomic) void (^timeValueBlock)(NSDate *, NSString *);

@end

@implementation CLCreateActivityFiltersTimePickerCell

- (void)awakeFromNib
{
    self.timePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    [self.timePicker addTarget:self
                        action:@selector(timePickerChangeValue)
              forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        [self.timePicker setDate:dictionary[@"time"]];
        
    }
}

- (void)getTimeValueWithCompletion:(void (^)(NSDate *, NSString *))completion
{
    self.timeValueBlock = completion;
}

- (void)timePickerChangeValue
{
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    
    dateFormat.locale    = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    
    NSString *stringTime = [dateFormat stringFromDate:self.timePicker.date];
    
    self.timeValueBlock(self.timePicker.date, stringTime);
}

@end
