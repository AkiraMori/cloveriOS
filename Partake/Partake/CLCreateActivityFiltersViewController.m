//
//  CLCreateActivityFiltersViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/9/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLActivityHelper.h"
#import "NSDate+DateTools.h"
#import "CLFiltersTimeCell.h"
#import "UIView+Positioning.h"
#import "CLCreateActivityTypeCell.h"
#import "UIAlertView+CloverAdditions.h"
#import "CLSearchLocationViewController.h"
#import "CLCreateActivityFiltersInfoCell.h"
#import "UIViewController+CloverAdditions.h"
#import "CLCreateActivityFiltersGenderCell.h"
#import "CLCreateActivityFiltersLocationCell.h"
#import "CLCreateActivityNavigationController.h"
#import "CLCreateActivityFiltersViewController.h"
#import "CLCreateActivityFiltersDatePickerCell.h"
#import "CLCreateActivityFiltersTimePickerCell.h"
#import "CLCreateActivityFiltersViewableByCell.h"
#import "CLCreateActivityPreviewViewController.h"
#import "CLCreateActivityFiltersAttendeeVisibleCell.h"
#import "CLDateHelper.h"
#import "CLLocationManagerController.h"

#define kCLHeaderFooterHeight    20.f

#define kCLInfoFirstCellTag      90
#define kCLInfoNextCellTag       91
#define kCLInfoTimeFrameCellTag  97
#define kCLInfoSecondCellTag     98
#define kCLInfoThirdCellTag      99

#define kCLTimeFramesPlaceholder @"-- Custom --"
#define kCLLocationPlaceholder @"Tap to choose a location"

static NSString * const kCLInfoCellIdentifier            = @"InfoCell";
static NSString * const kCLTimeFrameCellIdentifier       = @"TypeCell";
static NSString * const kCLLocationCellIdentifier        = @"LocationCell";
static NSString * const kCLViewableByCellIdentifier      = @"ViewableByCell";
static NSString * const kCLGenderCellIdentifier          = @"GenderCell";
static NSString * const kCLAgeCellIdentifier             = @"FiltersCell";
static NSString * const kCLAttendeeVisibleCellIdentifier = @"AttendeeVisibleCell";
static NSString * const kCLDatePickerCellIdentifier      = @"DatePickerCell";
static NSString * const kCLTimePickerCellIdentifier      = @"TimePickerCell";

@interface CLCreateActivityFiltersViewController ()

@property (strong, nonatomic) CLCreateActivityFiltersInfoCell            *infoFirstCell;
@property (strong, nonatomic) CLCreateActivityFiltersInfoCell            *infoNextCell;
@property (strong, nonatomic) CLCreateActivityFiltersInfoCell            *infoTimeFrameCell;
@property (strong, nonatomic) CLCreateActivityFiltersInfoCell            *infoSecondCell;
@property (strong, nonatomic) CLCreateActivityFiltersInfoCell            *infoThirdCell;
@property (strong, nonatomic) CLCreateActivityTypeCell                   *timeFrameCell;
@property (strong, nonatomic) CLCreateActivityFiltersLocationCell        *locationCell;
@property (strong, nonatomic) CLCreateActivityFiltersViewableByCell      *viewableByCell;
@property (strong, nonatomic) CLCreateActivityFiltersGenderCell          *genderCell;
@property (strong, nonatomic) CLFiltersTimeCell                          *ageCell;
@property (strong, nonatomic) CLCreateActivityFiltersAttendeeVisibleCell *attendeeVisibleCell;
@property (strong, nonatomic) CLCreateActivityFiltersDatePickerCell      *datePickerCell;
@property (strong, nonatomic) CLCreateActivityFiltersDatePickerCell      *endDatePickerCell;
@property (strong, nonatomic) CLCreateActivityFiltersTimePickerCell      *timePickerStartCell;
@property (strong, nonatomic) CLCreateActivityFiltersTimePickerCell      *timePickerEndCell;

@property (nonatomic)         NSInteger      timeFrameIndex;
@property (strong, nonatomic) NSMutableArray *timeFrames;
@property (strong, nonatomic) NSMutableArray *cells;

@end

@implementation CLCreateActivityFiltersViewController

- (id)init {
    self = [super init];
    if (self) {
        _attendeeValue = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Create Activity";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preview"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(validateBeforeSegue:)];
    
    self.timeFrames = [NSMutableArray arrayWithArray:[CLActivityHelper timeFrames]];
    
    [self.timeFrames insertObject:kCLTimeFramesPlaceholder
                          atIndex:0];
    
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    
    dateFormat.locale    = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    
    NSString *stringStartTime = [dateFormat stringFromDate:[NSDate date]];
    NSString *stringEndTime   = [dateFormat stringFromDate:[[NSDate date] dateByAddingHours:1]];

    NSDate *activityDate = [NSDate date];
    if (self.dateString) {
        activityDate = [CLDateHelper dateFromStringDate:self.dateString formatter:kCLDateFormatterISO8601];
    }
    self.dateString = [activityDate formattedDateWithFormat:@"yyyy-MM-dd"];

    NSDate *activityEndDate = [[NSDate date] dateByAddingDays:30];
    if (self.endDateString) {
        activityEndDate = [CLDateHelper dateFromStringDate:self.endDateString formatter:kCLDateFormatterISO8601];
    }
    self.endDateString = [activityEndDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    self.timeEndString        = (self.timeEndString)        ? self.timeEndString        : stringEndTime;
    self.locationHumanAddress = (self.locationHumanAddress) ? self.locationHumanAddress : kCLLocationPlaceholder;
    self.ageFrom              = (self.ageFrom)              ? self.ageFrom              : kCLAgeRangeMin;
    self.ageTo                = (self.ageTo)                ? self.ageTo                : kCLAgeRangeMax;
    self.viewableBy           = (self.viewableBy)           ? self.viewableBy           : @"Everyone";
    self.gender               = (self.gender)               ? self.gender               : @"both";
    self.attendeeValue        = (!self.attendeeValue)       ? self.attendeeValue        : YES;
    self.date                 = (self.date)                 ? self.date                 : [NSDate date];
    self.endDate              = (self.endDate)              ? self.endDate              : activityEndDate;
    self.timeStart            = (self.timeStart)            ? self.timeStart            : [NSDate date];
    self.timeEnd              = (self.timeEnd)              ? self.timeEnd              : [[NSDate date] dateByAddingHours:1];
    
    self.timeFrame            = ([CLActivityHelper isTimeFrame:self.timeStartString])   ? self.timeStartString : @"Select Time Frame";
    self.timeFrameIndex       = ([self.timeFrame isEqualToString:@"Select Time Frame"]) ? 0              : [self.timeFrames indexOfObject:self.timeFrame];
    [self enableTimeCells:NO];
    
    if ([CLActivityHelper isTimeFrame:self.timeStartString]) {
        
        self.timeStartString = stringStartTime;
        self.timeEndString   = stringEndTime;
        
        [self enableTimeCells:NO];
        
    } else {
        
        self.timeStartString = (self.timeStartString) ? self.timeStartString : stringStartTime;
        
    }
    
    [self loadCellNibs];
    
    self.infoFirstCell        = [self.tableView dequeueReusableCellWithIdentifier:kCLInfoCellIdentifier];
    self.infoNextCell         = [self.tableView dequeueReusableCellWithIdentifier:kCLInfoCellIdentifier];
    self.infoTimeFrameCell    = [self.tableView dequeueReusableCellWithIdentifier:kCLInfoCellIdentifier];
    self.infoSecondCell       = [self.tableView dequeueReusableCellWithIdentifier:kCLInfoCellIdentifier];
    self.infoThirdCell        = [self.tableView dequeueReusableCellWithIdentifier:kCLInfoCellIdentifier];
    self.timeFrameCell        = [self.tableView dequeueReusableCellWithIdentifier:kCLTimeFrameCellIdentifier];
    self.locationCell         = [self.tableView dequeueReusableCellWithIdentifier:kCLLocationCellIdentifier];
    self.viewableByCell       = [self.tableView dequeueReusableCellWithIdentifier:kCLViewableByCellIdentifier];
    self.genderCell           = [self.tableView dequeueReusableCellWithIdentifier:kCLGenderCellIdentifier];
    self.ageCell              = [self.tableView dequeueReusableCellWithIdentifier:kCLAgeCellIdentifier];
    self.attendeeVisibleCell  = [self.tableView dequeueReusableCellWithIdentifier:kCLAttendeeVisibleCellIdentifier];
    self.datePickerCell       = [self.tableView dequeueReusableCellWithIdentifier:kCLDatePickerCellIdentifier];
    self.endDatePickerCell    = [self.tableView dequeueReusableCellWithIdentifier:kCLDatePickerCellIdentifier];
    self.timePickerStartCell  = [self.tableView dequeueReusableCellWithIdentifier:kCLTimePickerCellIdentifier];
    self.timePickerEndCell    = [self.tableView dequeueReusableCellWithIdentifier:kCLTimePickerCellIdentifier];
    
    [self configureCells];
    
    self.cells = [NSMutableArray arrayWithObjects:self.infoFirstCell,
                  self.infoNextCell,
                  self.infoTimeFrameCell,
                  self.infoSecondCell,
                  self.infoThirdCell,
                  self.locationCell,
                  self.viewableByCell,
                  self.genderCell,
                  self.ageCell,
                  self.attendeeVisibleCell,
                  nil];
    
//    if ([CLActivityHelper isTimeFrame:self.timeFrame]) {
    
        [self enableTimeCells:NO];
        
//    }
    
    [self requiredPopViewControllerBackButton];
}

#pragma mark - Utilities

- (void)loadCellNibs
{
    UINib *infoFirstCellNib       = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersInfoCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *infoTimeFrameCellNib   = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersInfoCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *infoSecondCellNib      = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersInfoCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *infoThirdCellNib       = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersInfoCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *timeFrameCellNib       = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityTypeCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *locationCellNib        = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersLocationCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *viewableByCellNib      = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersViewableByCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *genderCellNib          = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersGenderCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *timeCellNib            = [UINib nibWithNibName:NSStringFromClass([CLFiltersTimeCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *attendeeVisibleCellNib = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersAttendeeVisibleCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *datePickerCellNib      = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersDatePickerCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *timePickerStartCellNib = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersTimePickerCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    UINib *timePickerEndCellNib   = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersTimePickerCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:infoFirstCellNib
         forCellReuseIdentifier:kCLInfoCellIdentifier];
    
    [self.tableView registerNib:infoTimeFrameCellNib
         forCellReuseIdentifier:kCLInfoCellIdentifier];
    
    [self.tableView registerNib:infoSecondCellNib
         forCellReuseIdentifier:kCLInfoCellIdentifier];
    
    [self.tableView registerNib:infoThirdCellNib
         forCellReuseIdentifier:kCLInfoCellIdentifier];
    
    [self.tableView registerNib:timeFrameCellNib
         forCellReuseIdentifier:kCLTimeFrameCellIdentifier];
    
    [self.tableView registerNib:locationCellNib
         forCellReuseIdentifier:kCLLocationCellIdentifier];
    
    [self.tableView registerNib:viewableByCellNib
         forCellReuseIdentifier:kCLViewableByCellIdentifier];
    
    [self.tableView registerNib:genderCellNib
         forCellReuseIdentifier:kCLGenderCellIdentifier];
    
    [self.tableView registerNib:timeCellNib
         forCellReuseIdentifier:kCLAgeCellIdentifier];
    
    [self.tableView registerNib:attendeeVisibleCellNib
         forCellReuseIdentifier:kCLAttendeeVisibleCellIdentifier];
    
    [self.tableView registerNib:datePickerCellNib
         forCellReuseIdentifier:kCLDatePickerCellIdentifier];
    
    [self.tableView registerNib:timePickerStartCellNib
         forCellReuseIdentifier:kCLTimePickerCellIdentifier];
    
    [self.tableView registerNib:timePickerEndCellNib
         forCellReuseIdentifier:kCLTimePickerCellIdentifier];
}

- (void)configureCells
{
    [self.infoFirstCell  configureCellAppearanceWithData:@{
                                                           @"infoLabel" : @"Start Date:",
                                                           @"valueLabel": self.dateString
                                                           }];
    
    [self.infoNextCell  configureCellAppearanceWithData:@{
                                                          @"infoLabel" : @"End Date:",
                                                          @"valueLabel": self.endDateString
                                                          }];
    
    [self.infoTimeFrameCell configureCellAppearanceWithData:@{
                                                              @"infoLabel" : @"Time Frame:",
                                                              @"valueLabel": self.timeFrame
                                                              }];
    
    [self.infoSecondCell configureCellAppearanceWithData:@{
                                                           @"infoLabel" : @"Start:",
                                                           @"valueLabel": self.timeStartString
                                                           }];
    
    [self.infoThirdCell  configureCellAppearanceWithData:@{
                                                           @"infoLabel" : @"End:",
                                                           @"valueLabel": self.timeEndString
                                                           }];
    
    self.infoFirstCell.tag      = kCLInfoFirstCellTag;
    self.infoNextCell.tag       = kCLInfoNextCellTag;
    self.infoTimeFrameCell.tag  = kCLInfoTimeFrameCellTag;
    self.infoSecondCell.tag     = kCLInfoSecondCellTag;
    self.infoThirdCell.tag      = kCLInfoThirdCellTag;
    
    [self.viewableByCell configureCellWithDictionary:@{@"createdBy": self.viewableBy}];
    
    [self.viewableByCell getSegmentedControlValueWithCompletion:^(NSString *viewableBy) {
        
        self.viewableBy = viewableBy;
        
    }];
    
    [self.genderCell configureCellWithDictionary:@{@"gender": self.gender}];
    
    [self.genderCell getSegmentedControlValueWithCompletion:^(NSString *gender) {
        
        self.gender = gender;
        
    }];
    
    [self.ageCell configureCellAppearanceWithData:@{
                                                    @"minValue": @(kCLAgeRangeMin),
                                                    @"maxValue": @(kCLAgeRangeMax),
                                                    @"showPlus": @(YES)
                                                    }];
    
    [self.ageCell configureCellWithDictionary:@{
                                                @"dayStart": @(self.ageFrom),
                                                @"dayEnd"  : @(self.ageTo),
                                                @"info"    : @"Age"
                                                }];
    
    [self.ageCell getDayStartDayEndValuesWithCompletion:^(NSInteger dayStart, NSInteger dayEnd) {
        
        self.ageFrom = dayStart;
        self.ageTo   = dayEnd;
        
        if (dayEnd == kCLAgeRangeMax) {
            self.ageTo = 100;
        }
    }];
    
    [self.attendeeVisibleCell configureCellWithDictionary:@{@"attendeeValue": @(self.attendeeValue)}];
    
    [self.attendeeVisibleCell getSwitchValueWithCompletion:^(BOOL attendeeVisible) {
        
        self.attendeeValue = attendeeVisible;
        
    }];
    
    [self.datePickerCell configureCellWithDictionary:@{@"date": self.date, @"endDate": self.endDate}];
    
    [self.datePickerCell getDateValueWithCompletion:^(NSDate *date, NSString *stringDate) {
        
        self.date       = date;
        self.dateString = stringDate;
        
        [self.infoFirstCell  configureCellAppearanceWithData:@{
                                                               @"infoLabel" : @"Start Date:",
                                                               @"valueLabel": stringDate
                                                               }];
        
    }];
    
    [self.endDatePickerCell configureCellWithDictionary:@{@"date": self.endDate}];
    
    [self.endDatePickerCell getDateValueWithCompletion:^(NSDate *date, NSString *stringDate) {
        
        self.endDate       = date;
        self.endDateString = stringDate;
        
        [self.infoNextCell  configureCellAppearanceWithData:@{
                                                              @"infoLabel" : @"End Date:",
                                                              @"valueLabel": stringDate
                                                              }];
        [self.datePickerCell configureCellWithDictionary:@{@"date": self.date, @"endDate": self.endDate}];
        
    }];
    
    self.timeFrameCell.arrayData = self.timeFrames;
    
    [self.timeFrameCell configureCellWithDictionary:@{@"index": @(self.timeFrameIndex)}];
    
    [self.timeFrameCell getPickerIndexValueWithCompletion:^(NSInteger pickerIndex) {
        
        NSString *frame        = self.timeFrames[pickerIndex];
        
        self.timeFrameIndex = pickerIndex;
        self.timeFrame      = frame;
        
        [self.infoTimeFrameCell configureCellAppearanceWithData:@{
                                                                  @"infoLabel" : @"Time Frame:",
                                                                  @"valueLabel": [frame isEqualToString:kCLTimeFramesPlaceholder] ? @"Custom" : frame
                                                                  }];
        
        (![frame isEqualToString:kCLTimeFramesPlaceholder]) ? [self enableTimeCells:NO] : [self enableTimeCells:YES];
        
    }];
    
    [self.timePickerStartCell configureCellWithDictionary:@{@"time": self.timeStart}];
    
    [self.timePickerStartCell getTimeValueWithCompletion:^(NSDate *date, NSString *stringTime) {
        
        self.timeStart       = date;
        self.timeStartString = stringTime;
        
        [self.infoSecondCell  configureCellAppearanceWithData:@{
                                                                @"infoLabel" : @"Start:",
                                                                @"valueLabel": stringTime
                                                                }];
        
    }];
    
    [self.timePickerEndCell configureCellWithDictionary:@{@"time": self.timeEnd}];
    
    [self.timePickerEndCell getTimeValueWithCompletion:^(NSDate *date, NSString *stringTime) {
        
        self.timeEnd       = date;
        self.timeEndString = stringTime;
        
        [self.infoThirdCell  configureCellAppearanceWithData:@{
                                                               @"infoLabel" : @"End:",
                                                               @"valueLabel": stringTime
                                                               }];
        
    }];
    
    if ([kCLLocationPlaceholder isEqualToString:self.locationHumanAddress]) {
        if ([CLLocationManagerController sharedInstance].currentAddress) {
            self.locationHumanAddress = @"Current Location";
        }
    }
    [self.locationCell configureCellWithDictionary:@{@"location": self.locationHumanAddress}];
    
    [self.locationCell.locationButton addTarget:self
                                         action:@selector(presentSearchLocationController)
                               forControlEvents:UIControlEventTouchUpInside];
}

- (UIView *)viewForHeaderFooter
{
    UIView *sectionSpace         = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width, self.tableView.height)];
    
    sectionSpace.backgroundColor = [UIColor clearColor];
    
    return sectionSpace;
}

- (IBAction)validateBeforeSegue:(id)sender
{
    if ([self isFormValid]) {
        
        CLCreateActivityPreviewViewController *createActivityPreviewViewController = ((CLCreateActivityNavigationController *)self.navigationController).createActivityPreviewViewController;
        
        [self.navigationController pushViewController:createActivityPreviewViewController
                                             animated:YES];
        
    }
}

- (BOOL)isFormValid
{
    if ([self.timeFrame isEqualToString:@"Select Time Frame"]) {
        
        [UIAlertView showMessage:@"Please select time frame."
                           title:@"Missing or Invalid Entry"];
        
        return NO;
    }
    
    if (self.timeFrameIndex == 0 && self.timeStart.timeIntervalSince1970 > self.timeEnd.timeIntervalSince1970) {
        
        [UIAlertView showMessage:@"You cannot have an end time that is before the start time."
                           title:@"Missing or Invalid Entry"];
        
        return NO;
    }
    
    if ([self.locationHumanAddress isEqualToString:kCLLocationPlaceholder]) {

        [UIAlertView showMessage:@"Please select event location."
                           title:@"Missing or Invalid Entry"];

        return NO;
    }
    
    return YES;
}

- (void)enableTimeCells:(BOOL)flag
{
    CGFloat alpha = flag ? 1.f : .5f;
    
    self.infoSecondCell.userInteractionEnabled = flag;
    self.infoThirdCell.userInteractionEnabled  = flag;
    
    self.infoSecondCell.contentView.hidden = self.infoThirdCell.contentView.hidden = !flag;
    
    self.infoSecondCell.infoLabel.textColor    = [self.infoSecondCell.infoLabel.textColor  colorWithAlphaComponent:alpha];
    self.infoSecondCell.valueLabel.textColor   = [self.infoSecondCell.valueLabel.textColor colorWithAlphaComponent:alpha];

    self.infoThirdCell.infoLabel.textColor     = [self.infoThirdCell.infoLabel.textColor   colorWithAlphaComponent:alpha];
    self.infoThirdCell.valueLabel.textColor    = [self.infoThirdCell.valueLabel.textColor  colorWithAlphaComponent:alpha];
    
}

- (void)presentSearchLocationController
{
    NSString *className = NSStringFromClass([CLSearchLocationViewController class]);
    
    CLSearchLocationViewController *searchLocationViewController = [[CLSearchLocationViewController alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
    CLNavigationController          *navController               = [[CLNavigationController         alloc] initWithRootViewController:searchLocationViewController];
    
    [searchLocationViewController getLocationValueWithCompletion:^(NSString *location) {
        
        self.locationHumanAddress = location;
        
        [self.locationCell configureCellWithDictionary:@{@"location": self.locationHumanAddress}];
        
    }];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.cells[indexPath.row];
    
    return cell.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.cells[indexPath.row];
    
    cell.selectionStyle   = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kCLHeaderFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kCLHeaderFooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self viewForHeaderFooter];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self viewForHeaderFooter];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *cellToHide = nil;
    
    NSIndexPath *indexPathToModify = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                        inSection:indexPath.section];
    
    if (cell.tag == kCLInfoFirstCellTag) {
        
        cell = self.datePickerCell;
        cellToHide = self.endDatePickerCell;
        
    } else if (cell.tag == kCLInfoNextCellTag) {
        
        cell = self.endDatePickerCell;
        cellToHide = self.datePickerCell;
        
    } else if (cell.tag == kCLInfoSecondCellTag) {
        
        cell = self.timePickerStartCell;
        
    } else if (cell.tag == kCLInfoThirdCellTag) {
        
        cell = self.timePickerEndCell;
        
    } else if (cell.tag == kCLInfoTimeFrameCellTag) {
        
        cell = self.timeFrameCell;
        
        if (self.timeFrameIndex == 0) {
            self.timeFrame = self.timeFrames.firstObject;
            
            [self.infoTimeFrameCell configureCellAppearanceWithData:@{
                                                                      @"infoLabel" : @"Time Frame:",
                                                                      @"valueLabel": @"Custom"
                                                                      }];
            [self enableTimeCells:YES];
        }
        
    }
    
    if (![self.cells containsObject:cell]) {
        
        [self.cells insertObject:cell
                         atIndex:indexPathToModify.row];
        [self.tableView insertRowsAtIndexPaths:@[indexPathToModify]
                              withRowAnimation:UITableViewRowAnimationFade];

        if (cellToHide && [self.cells containsObject:cellToHide]) {
            NSIndexPath *indexPathToHide = [NSIndexPath indexPathForRow:[self.cells indexOfObject:cellToHide]
                                                              inSection:indexPath.section];
            [self.cells removeObject:cellToHide];
            [self.tableView deleteRowsAtIndexPaths:@[indexPathToHide]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }

    } else {
        
        [self.cells removeObjectAtIndex:indexPathToModify.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPathToModify]
                              withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

@end
