//
//  CLCreateActivityFiltersGenderCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "NSDictionary+CloverAdditions.h"
#import "CLCreateActivityFiltersGenderCell.h"

@interface CLCreateActivityFiltersGenderCell ()

@property (copy, nonatomic) void (^genderValueBlock)(NSString *);

@end

@implementation CLCreateActivityFiltersGenderCell

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
        
        NSString *selectedSegment = dictionary[@"gender"];
        
        int index = 0;
        
        if ([selectedSegment isEqualToString:@"both"]) {
            
            index = 0;
            
        } else if ([selectedSegment isEqualToString:@"male"]) {
            
            index = 1;
            
        } else if ([selectedSegment isEqualToString:@"female"]) {
            
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
            filterValue = @"both";
            break;
            
        case 1:
            filterValue = @"male";
            break;
            
        case 2:
            filterValue = @"female";
            break;
    }
    
    self.genderValueBlock(filterValue);
}

- (void)getSegmentedControlValueWithCompletion:(void (^)(NSString *))completion
{
    self.genderValueBlock = completion;
}

@end
