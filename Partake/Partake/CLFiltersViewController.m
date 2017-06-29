//
//  FiltersViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 3/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLAppDelegate.h"
#import "CLActivityHelper.h"
#import "CLFiltersTimeCell.h"
#import "UIView+Positioning.h"
#import "CLFiltersActivityCell.h"
#import "CLFiltersViewableCell.h"
#import "CLFiltersViewController.h"
#import "UIAlertView+CloverAdditions.h"
#import "CLFiltersTableHeaderSection.h"
#import "UIViewController+CloverAdditions.h"

#define kCLRowHeightCellActivity 50.f
#define kCLRowHeightCellTime     102.f
#define kCLRowHeightCellViewable 60.f
#define kCLSectionHeaderHeight   28.f
#define kCLSectionFooterHeight   20.f

#define kCLSectionTitleTime     @"Within:"
#define kCLSectionTitleActivity @"Type of Activity:"
#define kCLSectionTitleViewable @"Created by:"

static NSString * const kCLFilterViewableCellIdentifier = @"FiltersViewableCell";
static NSString * const kCLFilterTimeCellIdentifier     = @"FiltersCell";
static NSString * const kCLFilterActivityCellIdentifier = @"FiltersActivityCell";

@interface CLFiltersViewController ()

@property (nonatomic) NSInteger dayStart;
@property (nonatomic) NSInteger dayEnd;
@property (nonatomic) NSInteger counter;

@property (strong, nonatomic) NSString       *viewableBy;
@property (strong, nonatomic) NSArray        *activitiesNames;
@property (strong, nonatomic) NSMutableArray *selectedIndex;
@property (strong, nonatomic) NSDictionary   *activitiesIcons;

@property (copy, nonatomic) void(^filteredBlock)(NSArray *);

@end

@implementation CLFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Filters";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *filterViewableCellNib = [UINib nibWithNibName:NSStringFromClass([CLFiltersViewableCell class])
                                                  bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:filterViewableCellNib
         forCellReuseIdentifier:kCLFilterViewableCellIdentifier];
    
    UINib *filterTimeCellNib = [UINib nibWithNibName:NSStringFromClass([CLFiltersTimeCell class])
                                              bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:filterTimeCellNib
         forCellReuseIdentifier:kCLFilterTimeCellIdentifier];
    
    UINib *filterActivityCellNib = [UINib nibWithNibName:NSStringFromClass([CLFiltersActivityCell class])
                                                  bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:filterActivityCellNib
         forCellReuseIdentifier:kCLFilterActivityCellIdentifier];
    
    self.activitiesNames = [CLActivityHelper activityTypes];
    self.activitiesIcons = [CLActivityHelper activityIconsWithActivityTypeKey];
    
    self.selectedIndex   = [NSMutableArray array];
    self.counter         = self.selectedIndex.count;
    self.dayStart        = 1;
    self.dayEnd          = 180;
    self.viewableBy      = @"everyone";
    
    [self requiredDismissModalButtonWithTitle:@"Cancel"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(performFilterAction:)];
}

- (void)performFilterAction:(id)sender
{
    if (self.selectedIndex.count == 0) {
        [UIAlertView showMessage:@"Please select at least one activity type" title:@"Error"];
        return;
    }
    
    NSDictionary *locationDic = [CLApiClient sharedInstance].loggedUser.locationsArray.lastObject;
    
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([locationDic[@"latitude"]  floatValue],
                                                                    [locationDic[@"longitude"] floatValue]);
    
    [self showSearchingProgressHUD];
    
    __block NSMutableArray *types = [NSMutableArray array];
    
    [self.selectedIndex enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        int       index = [obj intValue];
        NSString  *name = self.activitiesNames[index];
        
        [types addObject:name];
        
    }];
    
    [[CLApiClient sharedInstance] searchActivitiesWithTypes:types
                                                coordinates:coordinates
                                                 viewableBy:self.viewableBy
                                                   dayStart:self.dayStart
                                                     dayEnd:self.dayEnd
                                               successBlock:^(NSArray *result) {
                                                   
                                                   self.filteredBlock(result);
                                                   
                                                   [self dismissProgressHUD];
                                                   
                                                   [self dismissViewControllerAnimated:YES
                                                                            completion:nil];
                                                   
                                               } failureBlock:^(NSError *error) {
                                                   
                                                   [UIAlertView showMessage:@"Unable to perform search."
                                                                      title:@"Oh no! Something went wrong!"];
                                                   
                                                   [self dismissProgressHUD];
                                                   
                                                   [self dismissViewControllerAnimated:YES
                                                                            completion:nil];
                                                   
                                               }];
}

#pragma mark - TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLFiltersViewableCell *cellViewable = [tableView dequeueReusableCellWithIdentifier:kCLFilterViewableCellIdentifier];
    CLFiltersTimeCell     *cellTime     = [tableView dequeueReusableCellWithIdentifier:kCLFilterTimeCellIdentifier];
    CLFiltersActivityCell *cellActivity = [tableView dequeueReusableCellWithIdentifier:kCLFilterActivityCellIdentifier];
    
    cellViewable.selectionStyle = UITableViewCellSelectionStyleNone;
    cellTime.selectionStyle     = UITableViewCellSelectionStyleNone;
    cellActivity.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        
        [cellViewable configureCellWithDictionary:@{@"createdBy": self.viewableBy}];
        
        [cellViewable getSegmentedControlValueWithCompletion:^(NSString *viewableBy) {
            
            self.viewableBy = viewableBy;
            
        }];
        
        return cellViewable;
        
    } else if (indexPath.section == 1) {
        
        [cellTime configureCellAppearanceWithData:@{
                                                    @"minValue": @(1),
                                                    @"maxValue": @(180)
                                                    }];
        
        [cellTime configureCellWithDictionary:@{
                                                @"dayStart": @(self.dayStart),
                                                @"dayEnd"  : @(self.dayEnd),
                                                @"info"    : @"Days"
                                                }];
        
        [cellTime getDayStartDayEndValuesWithCompletion:^(NSInteger dayStart, NSInteger dayEnd) {
            
            self.dayStart = dayStart;
            self.dayEnd   = dayEnd;
            
        }];
        
        return cellTime;
        
    } else if (indexPath.section == 2) {
        
        [cellActivity configureCellAppearanceWithData:nil];
        
        NSString *key            = self.activitiesNames[indexPath.row];
        UIImage  *icon           = self.activitiesIcons[key];
        UIImage  *checkmarkIcon;
        
        NSPredicate *valuePredicate = [NSPredicate predicateWithFormat:@"self.intValue == %i", indexPath.row];
        
        if ([self.selectedIndex filteredArrayUsingPredicate:valuePredicate].count !=0) {
            
            checkmarkIcon = [UIImage imageNamed:@"filters-activity-check-tick"];
            
        } else {
            
            checkmarkIcon = [UIImage imageNamed:@"filters-activity-check-placeholder"];
            
        }
        
//        if (self.selectedIndex.count == 0) {
//            
//            checkmarkIcon = [UIImage imageNamed:@"filters-activity-check-tick"];
//            
//            [self.selectedIndex addObject:@(0)];
//            
//        }
        
        [cellActivity configureCellWithDictionary:@{
                                                    @"name":      key,
                                                    @"icon":      icon,
                                                    @"checkmark": checkmarkIcon
                                                    }];
        
        return cellActivity;
        
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        
        return 1;
        
    }
    
    return self.activitiesNames.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableVie
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kCLSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    if (section == 0) {
        
        title = kCLSectionTitleViewable;
        
    } else if (section == 1) {
        
        title = kCLSectionTitleTime;
        
    } else {
        
        title = kCLSectionTitleActivity;
        
    }
    
    return [[CLFiltersTableHeaderSection alloc] initWithTitle:title];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return kCLRowHeightCellViewable;
        
    } else if (indexPath.section == 1) {
        
        return kCLRowHeightCellTime;
        
    }
    
    return kCLRowHeightCellActivity;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        
        return kCLSectionFooterHeight;
        
    }
    
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                              0.f,
                                                              self.tableView.width,
                                                              kCLSectionFooterHeight)];
    
    footer.backgroundColor = [UIColor whiteColor];
    
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[self.tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[CLFiltersActivityCell class]]) {
        return;
    }
    
    CLFiltersActivityCell *filtersActivityCell = (CLFiltersActivityCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSNumber *indexRow = [NSNumber numberWithInteger:indexPath.row];
    UIImage  *accessoryImage;
    
    if ([self.selectedIndex containsObject:indexRow]) {
        
//        if (self.selectedIndex.count == 1) {
//            
//            return;
//            
//        }
        
        accessoryImage = [UIImage imageNamed:@"filters-activity-check-placeholder"];
        
        [self.selectedIndex removeObject:indexRow];
        
    } else {
        
        accessoryImage = [UIImage imageNamed:@"filters-activity-check-tick"];
        
        [self.selectedIndex addObject:indexRow];
        
    }
    
    filtersActivityCell.checkmarkImageView.image = accessoryImage;
}

- (void)getFilteredActivitiesWithCompletion:(void (^)(NSArray *results))completion
{
    self.filteredBlock = completion;
}

@end
