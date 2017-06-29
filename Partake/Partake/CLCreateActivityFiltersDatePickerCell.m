//
//  CLCreateActivityFiltersDatePickerCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "NSDate+DateTools.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLCreateActivityFiltersDatePickerCell.h"

@interface CLCreateActivityFiltersDatePickerCell ()

@property (copy, nonatomic) void (^dateValueBlock)(NSDate *, NSString *);

@end

@implementation CLCreateActivityFiltersDatePickerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.maximumDate = [[NSDate date] dateByAddingMonths:6];
    
    [self.datePicker addTarget:self
                        action:@selector(datePickerChangeValue)
              forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        [self.datePicker setDate:dictionary[@"date"]];
        
        if (dictionary[@"endDate"]) {
            self.datePicker.minimumDate = [dictionary[@"endDate"] dateByAddingDays:-60];
            self.datePicker.maximumDate = dictionary[@"endDate"];
        }

        [self datePickerChangeValue];
    }
}

- (void)getDateValueWithCompletion:(void (^)(NSDate *, NSString *))completion
{
    self.dateValueBlock = completion;
}

- (void)datePickerChangeValue
{
    if (self.dateValueBlock) {
        NSString *stringDate = [self.datePicker.date formattedDateWithFormat:@"yyyy-MM-dd"];
        
        self.dateValueBlock(self.datePicker.date, stringDate);
    }
}

@end
