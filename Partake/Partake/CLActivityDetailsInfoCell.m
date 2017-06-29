//
//  CLActivityDetailsInfoCell.m
//  Partake
//
//  Created by Pablo Episcopo on 3/5/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLDateHelper.h"
#import "NSDate+DateTools.h"
#import "CLActivityHelper.h"
#import "CLLocationActivity.h"
#import "UIColor+CloverAdditions.h"
#import "CLActivityDetailsInfoCell.h"
#import "CLActivity+ModelController.h"
#import "NSDictionary+CloverAdditions.h"

@implementation CLActivityDetailsInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureCellAppearanceWithData:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellAppearanceWithData:(id)data
{
    self.containerDateView.layer.borderWidth  = 3.f;
    self.containerDateView.layer.borderColor  = [UIColor standardTextColor].CGColor;
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        NSString *type;
        NSString *locationHumanAddress;
        NSString *neighborhood;
        NSString *locality;
        NSString *city;
        NSString *state;
        NSString *stateShort;
        NSString *name;
        NSString *activityDate;
        NSString *activityEndDate;
        NSString *fromTime;
        NSString *toTime;
        NSDate   *createdAt;
        
        if ([dictionary.allKeys containsObject:@"activity"]) {
            
            CLActivity *activity = dictionary[@"activity"];
            
            type         = activity.type;
            neighborhood = activity.activityLocation.neighborhood;
            locality     = activity.activityLocation.locality;
            city         = activity.activityLocation.city;
            state        = activity.activityLocation.state;
            stateShort   = activity.activityLocation.stateShort;
            name         = activity.name;
            activityDate = activity.activityDate;
            activityEndDate = activity.activityEndDate;
            createdAt    = activity.createdAt;
            fromTime     = activity.fromTime;
            toTime       = activity.toTime;
            
            NSString *locationFull     = [CLActivityHelper determineStringToShowWithLocation:activity.activityLocation];
            
            self.locationLabel.text    = locationFull;
            self.createdAtLabel.text   = [@"Created " stringByAppendingString:createdAt.timeAgoSinceNow.lowercaseString];
            
            CGFloat locationDistance   = [activity distanceFromActiveUserInMiles];
            
            if (locationDistance > 0) {
                
                NSNumberFormatter *fmt = [NSNumberFormatter new];
                [fmt setPositiveFormat:@"0.##"];
                
                self.distanceFromUserLabel.text = [[fmt stringFromNumber:@(locationDistance)] stringByAppendingString:@" mi"];
                
            }
            
        } else if ([dictionary.allKeys containsObject:@"activityPreview"]) {
            
            NSDictionary *activityDic         = dictionary[@"activityPreview"];
            
            type                              = activityDic[@"type"];
            locationHumanAddress              = activityDic[@"location"];
            name                              = activityDic[@"name"];
            activityDate                      = activityDic[@"activityDate"];
            activityEndDate                   = activityDic[@"activityEndDate"];
            fromTime                          = activityDic[@"fromTime"];
            toTime                            = activityDic[@"toTime"];
            
            self.locationLabel.text           = locationHumanAddress;
            
            NSDate *endDate                   = [CLDateHelper dateFromStringDate:activityEndDate formatter:@"yyyy-MM-dd"];
            NSString *formattedDate           = [[endDate dateByAddingMonths:2] formattedDateWithFormat:@"MMMM d"];

            self.createdAtLabel.text          = [@"Expires " stringByAppendingString:formattedDate];
            
            self.distanceFromUserLabel.hidden = YES;
            
            NSDate *date = [CLDateHelper dateFromStringDate:activityDate formatter:@"yyyy-MM-dd"];
            activityDate = [CLDateHelper UTCStringForDate:date];
            activityEndDate = activityDate;
        }
        
        UIImage *imageIcon              = [CLActivityHelper activityIconWithType:type
                                                                  isPrimaryColor:YES];
        
        self.nameLabel.text             = name;
        self.dayDateLabel.text          = [CLDateHelper stringDayDateFromStringDate:activityDate];
        self.monthDateLabel.text        = [CLDateHelper stringShortMonthFromStringDate:activityDate];
        self.dayEndDateLabel.text       = [CLDateHelper stringDayDateFromStringDate:activityEndDate];
        self.monthEndDateLabel.text     = [CLDateHelper stringShortMonthFromStringDate:activityEndDate];
        self.eventIconImageView.image   = imageIcon;
        self.timeLabel.text             = [CLActivityHelper stringFormatForActivityDateWithFromTime:fromTime
                                                                                             toTime:toTime];
        
        BOOL isRepeated = activityEndDate && !([self.dayDateLabel.text isEqualToString:self.dayEndDateLabel.text] && [self.monthDateLabel.text isEqualToString:self.monthEndDateLabel.text]);
        self.dateDashLabel.hidden = !isRepeated;
        self.dateWidthConstraint.constant = isRepeated ? 110.f : 60.f;
        [self layoutIfNeeded];
    }
}

@end
