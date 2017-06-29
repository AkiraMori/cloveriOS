//
//  CLCreateActivityFiltersAttendeeVisibleCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "NSDictionary+CloverAdditions.h"
#import "CLCreateActivityFiltersAttendeeVisibleCell.h"

@interface CLCreateActivityFiltersAttendeeVisibleCell ()

@property (copy, nonatomic) void (^attendeeVisibleValueBlock)(BOOL);

@end

@implementation CLCreateActivityFiltersAttendeeVisibleCell

- (void)awakeFromNib
{
    [self.attendeeVisibleSwitch addTarget:self
                                   action:@selector(attendeeValueChange)
                         forControlEvents:UIControlEventValueChanged];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        BOOL attendeeValue = [dictionary[@"attendeeValue"] boolValue];
        
        [self.attendeeVisibleSwitch setOn:attendeeValue];
        
    }
}

- (void)attendeeValueChange
{
    BOOL attendeeValue = self.attendeeVisibleSwitch.isOn;
    
    self.attendeeVisibleValueBlock(attendeeValue);
}

- (void)getSwitchValueWithCompletion:(void (^)(BOOL))completion
{
    self.attendeeVisibleValueBlock = completion;
}

@end