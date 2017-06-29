//
//  CLCreateActivityFiltersViewableByCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "NSDictionary+CloverAdditions.h"
#import "CLCreateActivityFiltersViewableByCell.h"

@interface CLCreateActivityFiltersViewableByCell ()

@property (copy, nonatomic) void (^viewableByValueBlock)(NSString *);

@end

@implementation CLCreateActivityFiltersViewableByCell

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
        
        if ([selectedSegment isEqualToString:@"Everyone"]) {
            
            index = 0;
            
        } else if ([selectedSegment isEqualToString:@"Friends"]) {
            
            index = 1;
            
        } else if ([selectedSegment isEqualToString:@"Friends_of_Friends"]) {
            
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
            filterValue = @"Everyone";
            break;
            
        case 1:
            filterValue = @"Friends";
            break;
            
        case 2:
            filterValue = @"Friends_of_Friends";
            break;
    }
    
    self.viewableByValueBlock(filterValue);
}

- (void)getSegmentedControlValueWithCompletion:(void (^)(NSString *))completion
{
    self.viewableByValueBlock = completion;
}

@end
