//
//  CLFiltersViewableCell.m
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFiltersViewableCell.h"
#import "NSDictionary+CloverAdditions.h"

@interface CLFiltersViewableCell ()

@property (copy, nonatomic) void (^viewableByValueBlock)(NSString *);

@end

@implementation CLFiltersViewableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.segmentedViewableControl addTarget:self
                                      action:@selector(viewableValueChange)
                            forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        NSString *selectedSegment = dictionary[@"createdBy"];
        
        int index = 0;
        
        if ([selectedSegment isEqualToString:@"everyone"]) {
            
            index = 0;
            
        } else if ([selectedSegment isEqualToString:@"friends"]) {
            
            index = 1;
            
        } else if ([selectedSegment isEqualToString:@"friends_of_friends"]) {
            
            index = 2;
            
        }
        
        [self.segmentedViewableControl setSelectedSegmentIndex:index];
    }
}

- (void)viewableValueChange
{
    NSString *filterValue;
    
    switch (self.segmentedViewableControl.selectedSegmentIndex) {
        case 0:
            filterValue = @"everyone";
            break;
            
        case 1:
            filterValue = @"friends";
            break;
            
        case 2:
            filterValue = @"friends_of_friends";
            break;
    }
    
    self.viewableByValueBlock(filterValue);
}

- (void)getSegmentedControlValueWithCompletion:(void (^)(NSString *))completion
{
    self.viewableByValueBlock = completion;
}

@end
