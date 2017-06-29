//
//  CLActivityCreatedCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/16/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLDateHelper.h"
#import "NSDate+DateTools.h"
#import "CLActivityHelper.h"
#import "UIAlertView+Blocks.h"
#import "CLLocationActivity.h"
#import "CLAppearanceHelper.h"
#import "CLActivityCreatedCell.h"
#import "UIColor+CloverAdditions.h"
#import "UIAlertView+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"

@interface CLActivityCreatedCell ()

@property (strong, nonatomic) CLActivity *activity;

@end

@implementation CLActivityCreatedCell

- (void)awakeFromNib
{
    [self.deleteButton addTarget:self
                          action:@selector(deleteActivity:)
                forControlEvents:UIControlEventTouchUpInside];
    
    self.arrowImageView.hidden = YES;
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellAppearanceWithData:(id)data
{
    NSIndexPath *indexPath    = data;
    UIColor     *indexColor   = [CLAppearanceHelper colorForIndexPath:indexPath];
    UIImage     *arrowImage   = [CLAppearanceHelper backgroundArrowImageForIndexPath:indexPath];
    
    self.topFrame.backgroundColor    = indexColor;
    self.leftFrame.backgroundColor   = indexColor;
    self.rightFrame.backgroundColor  = indexColor;
    self.bottomFrame.backgroundColor = indexColor;
    self.arrowImageView.image        = arrowImage;
    
    self.containerDateView.layer.borderWidth  = 3.f;
    self.containerDateView.layer.borderColor  = [UIColor standardTextColor].CGColor;
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        self.activity = dictionary[@"activity"];
        
        NSString *locationFull           = [CLActivityHelper determineStringToShowWithLocation:self.activity.activityLocation];
        
        NSDate *activityEndDate    = [CLDateHelper dateFromStringDate:self.activity.activityEndDate formatter:kCLDateFormatterISO8601];
        NSString *expiryDate       = [[activityEndDate dateByAddingMonths:2] formattedDateWithFormat:@"MMMM d"];
        
        self.titleLabel.text       = self.activity.name;
        self.dayDateLabel.text     = [CLDateHelper    stringDayDateFromStringDate:self.activity.activityDate];
        self.monthDateLabel.text   = [CLDateHelper stringShortMonthFromStringDate:self.activity.activityDate];
        self.locationLabel.text    = locationFull;
        self.expiresLabel.text     = [@"Expires: " stringByAppendingString:expiryDate];
        self.timeLabel.text        = [CLActivityHelper stringFormatForActivityDateWithFromTime:self.activity.fromTime
                                                                                        toTime:self.activity.toTime];
        
    }
}

#pragma mark User Actions

- (IBAction)deleteActivity:(id)sender
{
    [UIAlertView showAlertWithTitle:@"Are You Sure?"
                            message:@"This activity will be deleted."
                        cancelTitle:@"Cancel"
                        acceptTitle:@"I'm Sure"
                 cancelButtonAction:nil
                       acceptAction:^{
                           
                           [self deleteActivityServerCall];
                           
                       }];
}

#pragma mark - Private Methods

- (void)deleteActivityServerCall
{
    [[CLApiClient sharedInstance] deleteActivityWithId:self.activity.activityId
                                          successBlock:^(NSArray *result) {
                                              
                                              [UIAlertView showMessage:@"Successfully Deleted!"];
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kCLActivityDeletedNotification
                                                                                                  object:nil];
                                              
                                          }
                                          failureBlock:^(NSError *error) {
                                              
                                              [UIAlertView showErrorMessageWithAcceptAction:^{
                                                  
                                                  [self performSelector:@selector(deleteActivity:)
                                                             withObject:self];
                                                  
                                              }];
                                          }];
}

@end
