
//
//  CLSettingsPreferencesViewController.m
//  Partake
//
//  Created by Maikel on 08/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsPreferencesViewController.h"
#import "CLFiltersTimeCell.h"
#import "CLSettingsPreferenceDistanceCell.h"
#import "CLCreateActivityFiltersGenderCell.h"
#import "CLLoggedUser.h"


#define kCLHeaderFooterHeight    30.f

#define METER_PER_MILE      1609.34f

static NSString * const kCLDistanceCellIdentifier        = @"DistanceCell";
static NSString * const kCLGenderCellIdentifier          = @"GenderCell";
static NSString * const kCLAgeCellIdentifier             = @"FiltersCell";

@interface CLSettingsPreferencesViewController ()
@property (strong, nonatomic) CLSettingsPreferenceDistanceCell  *distanceCell;
@property (strong, nonatomic) CLCreateActivityFiltersGenderCell *genderCell;
@property (strong, nonatomic) CLFiltersTimeCell                 *ageRangeCell;

@property (strong, nonatomic) NSArray *cells;

@property (assign, nonatomic) NSInteger distanceLimit;
@property (assign, nonatomic) NSInteger ageFrom;
@property (assign, nonatomic) NSInteger ageTo;
@property (copy, nonatomic) NSString *gender;
@end

@implementation CLSettingsPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadPreferences];
    
    [self loadCellNibs];
    
    self.distanceCell = [self.tableView dequeueReusableCellWithIdentifier:kCLDistanceCellIdentifier];
    self.genderCell   = [self.tableView dequeueReusableCellWithIdentifier:kCLGenderCellIdentifier];
    self.ageRangeCell = [self.tableView dequeueReusableCellWithIdentifier:kCLAgeCellIdentifier];
    
    self.cells = [NSMutableArray arrayWithObjects:self.distanceCell, self.genderCell, self.ageRangeCell, nil];
    
    [self configureCells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)loadCellNibs {
    [self.tableView registerNib:[CLSettingsPreferenceDistanceCell nib]
         forCellReuseIdentifier:kCLDistanceCellIdentifier];
    
    [self.tableView registerNib:[CLCreateActivityFiltersGenderCell nib]
         forCellReuseIdentifier:kCLGenderCellIdentifier];
    
    [self.tableView registerNib:[CLFiltersTimeCell nib]
         forCellReuseIdentifier:kCLAgeCellIdentifier];
}

- (void)configureCells {
    [self.distanceCell configureCellWithDictionary:@{@"distance" : @(self.distanceLimit)}];
    
    [self.distanceCell getSearchDistanceLimitWithCompletion:^(NSInteger distance) {
        self.distanceLimit = distance;
    }];
    
    
    [self.genderCell configureCellWithDictionary:@{@"gender": self.gender}];

    [self.genderCell getSegmentedControlValueWithCompletion:^(NSString *gender) {
        self.gender = gender;
    }];
    
    
    [self.ageRangeCell configureCellAppearanceWithData:@{
                                                         @"minValue": @(kCLAgeRangeMin),
                                                         @"maxValue": @(kCLAgeRangeMax),
                                                         @"showPlus": @(YES)
                                                         }];
    
    [self.ageRangeCell configureCellWithDictionary:@{
                                                     @"dayStart": @(self.ageFrom),
                                                     @"dayEnd"  : @(self.ageTo),
                                                     @"info"    : @"Age"
                                                     }];
    
    [self.ageRangeCell getDayStartDayEndValuesWithCompletion:^(NSInteger dayStart, NSInteger dayEnd) {
        self.ageFrom = dayStart;
        self.ageTo   = dayEnd;
        
        if (dayEnd == kCLAgeRangeMax) {
            self.ageTo = 100;
        }
    }];
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
    [self savePreferences];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Preferences

- (void)loadPreferences {
    CLLoggedUser *loggedUser = [[CLLoggedUser alloc] initWithUserId:[CLApiClient sharedInstance].loggedUser.userId];
    
    self.distanceLimit  = loggedUser.defaultLimitSearchResults  ? round(loggedUser.defaultLimitSearchResults.integerValue / METER_PER_MILE) : 40;
    self.gender         = loggedUser.defaultActivitiesCreatedBy ? loggedUser.defaultActivitiesCreatedBy             : @"both";
    self.ageFrom        = loggedUser.defaultActivitiesAgeFrom   ? loggedUser.defaultActivitiesAgeFrom.integerValue  : 19;
    self.ageTo          = loggedUser.defaultActivitiesAgeTo     ? loggedUser.defaultActivitiesAgeTo.integerValue    : 32;
}

- (void)savePreferences {
    
    [[CLApiClient sharedInstance] saveUserDefaultPreferences:self.distanceLimit * METER_PER_MILE
                                                   CreatedBy:self.gender
                                                     AgeFrom:self.ageFrom
                                                       AgeTo:self.ageTo
                                                successBlock:^(NSArray *results) {
                                                    
                                                    DDLogInfo(@"Success saving user default preferences");
                                                    
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kCLUserPreferencesUpdatedNotification object:nil];
                                                    
                                                } failureBlock:^(NSError *error) {
                                                    
                                                    DDLogError(@"Error: %@", error.description);
                                                    
                                                }];
}



#pragma mark - Table View
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = self.cells[indexPath.section];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = self.cells[indexPath.section];
    
    return cell.height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return kCLHeaderFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kCLHeaderFooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return [self genderHeaderView];
    }
    
    return [self emptyHeaderFooterView];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [self emptyHeaderFooterView];
}

- (UIView *)emptyHeaderFooterView {
    static UIView *emptyView = nil;
    
    if (!emptyView) {
        emptyView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, kCLHeaderFooterHeight)];
        emptyView.backgroundColor = [UIColor clearColor];
    }
    
    return emptyView;
}

- (UIView *)genderHeaderView {
    static UIView *headerView = nil;
    
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, kCLHeaderFooterHeight)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.f, 4.f, 240.f, 16.f)];
        titleLabel.font = [UIFont fontWithName:kCLPrimaryBrandFont size:13.f];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.text = @"Only show activities created by:";
        [headerView addSubview:titleLabel];
    }
    
    return headerView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
