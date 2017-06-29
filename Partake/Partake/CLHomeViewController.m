//
//  CLHomeViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#ifdef DEVELOPMENT
#import "CLAppDelegate.h"
#endif

#import "CLConstants.h"
#import "CLDateHelper.h"
#import "CLActivityCell.h"
#import "NSDate+DateTools.h"
#import "CLActivityHelper.h"
#import "UIView+Positioning.h"
#import "CLHomeViewController.h"
#import "CLHomeEmptyTableView.h"
#import "CLNavigationTitleView.h"
#import "CLNavigationController.h"
#import "CLHomeTableHeaderSection.h"
#import "UITableView+NXEmptyView.h"
#import "CLFiltersViewController.h"
#import "CLResultsTableController.h"
#import "UIAlertView+CloverAdditions.h"
#import "CLLocationServiceDisableView.h"
#import "CLActivityDetailsViewController.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "NSFetchedResultsController+CloverAdditions.h"
#import "CLFacebookHelper.h"
#import "CLProfilePhoto.h"

#import "CLAmazonManager.h"


@import CoreLocation;

#define kCLTableHeaderHeight 35.f
#define kCLRowHeight         90.f
#define kCLResultsRowHeight  54.f

#define kCLNumberOfSections     3
#define kCLSectionTitleToday    @"Today"
#define kCLSectionTitleTomorrow @"Tomorrow"

static NSString * const kCLActivityCellIdentifier = @"ActivityCell";

@interface CLHomeViewController ()

@property (strong, nonatomic) CLHomeEmptyTableView          *homeEmptyTableView;
@property (strong, nonatomic) CLLocationServiceDisableView  *locationServiceDisableView;
@property (strong, nonatomic) CLFiltersViewController       *filtersViewController;

@property (strong, nonatomic) NSDictionary *dictionaryActivities;

@property (strong, nonatomic) UISearchController       *searchController;
@property (strong, nonatomic) CLResultsTableController *resultsTableController;

@property (strong, nonatomic) NSTimer               *locationTimer;
@property (strong, nonatomic) UIRefreshControl      *refreshControl;
@property (strong, nonatomic) CLNavigationTitleView *navigationTitleView;

@property (nonatomic) CLLocationCoordinate2D *myLastLocation;
@property (nonatomic) CLLocationAccuracy     *myLastLocationAccuracy;

@property (nonatomic) BOOL searchControllerWasActive;
@property (nonatomic) BOOL searchControllerSearchFieldWasFirstResponder;
@property (nonatomic) BOOL flagActivitiesFirstTimeFetch;

@end

@implementation CLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadActivities) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadActivities) name:kCLUserPreferencesUpdatedNotification    object:nil];
    
    self.title = @"Home";
    
    self.resultsTableController                    = [CLResultsTableController new];
    self.resultsTableController.tableView.delegate = self;
    self.resultsTableController.tableView.y        = 44.f;
    
    self.searchController                                  = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.delegate                         = self;
    self.searchController.searchBar.delegate               = self;
    self.searchController.searchBar.searchBarStyle         = UISearchBarStyleMinimal;
    self.searchController.searchBar.placeholder            = @"Search Activities";
    self.searchController.searchBar.tintColor              = [UIColor standardTextColor];
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    [self.searchController.searchBar sizeToFit];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.definesPresentationContext      = YES;
    
    self.refreshControl                  = [UIRefreshControl new];
    self.refreshControl.tintColor        = [UIColor primaryBrandColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(reloadActivities)
                  forControlEvents:UIControlEventValueChanged];
    
    self.homeEmptyTableView         = [CLHomeEmptyTableView         new];
    self.locationServiceDisableView = [CLLocationServiceDisableView new];
    
    UITapGestureRecognizer *tapGestureNoActivities    = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(loadActivities)];
    
    UITapGestureRecognizer *tapGestureLocationService = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(goToSettings)];
    
    [self.homeEmptyTableView         addGestureRecognizer:tapGestureNoActivities];
    [self.locationServiceDisableView addGestureRecognizer:tapGestureLocationService];
    
    UINib *activityCellNib = [UINib nibWithNibName:NSStringFromClass([CLActivityCell class])
                                            bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:activityCellNib
         forCellReuseIdentifier:kCLActivityCellIdentifier];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.nxEV_emptyView  = self.homeEmptyTableView;
    
    
    /* Right bar button item (Filter) */
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [filterButton setImage:[UIImage imageNamed:@"bar-button-filter"] forState:UIControlStateNormal];
    [filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [[filterButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
    [filterButton sizeToFit];
    [filterButton addTarget:self action:@selector(showFilters:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    
    // the space between the image and text
    CGFloat spacing = 3.0;
    CGFloat leftOffset = 20.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = filterButton.imageView.image.size;
    filterButton.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width + leftOffset, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [filterButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: filterButton.titleLabel.font}];
    filterButton.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), leftOffset, 0.0, - titleSize.width);
    
    // increase the content height to avoid clipping
    CGFloat edgeOffset = fabs(titleSize.height - imageSize.height) / 2.0;
    filterButton.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0);
    /*********************************/
    

    self.fetchedResultsController          = [CLCoreDataFactories allActivitiesInRange];
    self.flagActivitiesFirstTimeFetch      = YES;
    self.locationServiceDisableView.hidden = YES;
    
    self.navigationTitleView      = [[CLNavigationTitleView alloc] initWithTitle:@"Activities Nearby"
                                                                        subtitle:@"Filtered"
                                                                  subtitleHidden:YES];
    
    self.navigationItem.titleView = self.navigationTitleView;
    
    [CLLocationManagerController sharedInstance].wdelegate = self;
    
    [[CLLocationManagerController sharedInstance] startNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadActivities)
                                                 name:kCLBlockedUserNotification
                                               object:nil];
    
#ifdef DEVELOPMENT
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(logoutAction)];
#endif
}

#ifdef DEVELOPMENT

- (void)logoutAction
{
//    [CLAmazonManager sharedInstance];
//    [CLAmazonManager downloadFileFromS3:nil];
//    [CLAmazonManager uploadFileToS3];
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    [manager logOut];
    //[[FBSession         activeSession] closeAndClearTokenInformation];
    [[CLApiClient       sharedInstance].loggedUser removeFromDisk];
    [[CLAppDelegate     sharedInstance] showLogin];
}

#endif

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.navigationController.view.subviews containsObject:self.locationServiceDisableView]) {
        
        self.locationServiceDisableView.frame = self.view.frame;
        
        [self.navigationController.view insertSubview:self.locationServiceDisableView
                                         belowSubview:self.navigationController.navigationBar];
        
    }
    
    if (self.searchController.searchBar.text.length > 0) {
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
        self.navigationController.navigationBar.translucent = YES;
        
    }

    [self searchBarShouldEnable];
    
    if ([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                            message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.searchControllerWasActive) {
        
        self.searchController.active   = self.searchControllerWasActive;
        self.searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            
            [self.searchController.searchBar becomeFirstResponder];
            
            _searchControllerSearchFieldWasFirstResponder = NO;
            
        }
    }
    
    [self loadActivities];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.refreshControl endRefreshing];
    
    [[CLApiClient sharedInstance] cancelAllRequests];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCLBlockedUserNotification
                                                  object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (![searchBar isEqual:@""]) {
        
        [self showSearchingProgressHUD];
        
        NSDictionary *dic = [CLApiClient sharedInstance].loggedUser.locationsArray.lastObject;
        
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([dic[@"latitude"]  floatValue],
                                                                        [dic[@"longitude"] floatValue]);
        
        [[CLApiClient sharedInstance] searchActivitiesWithText:searchBar.text
                                                   coordinates:coordinates
                                                         limit:10
                                                        offset:0
                                                  successBlock:^(NSArray *result) {
                                                      
                                                      if (result.count > 0) {
                                                          
                                                          self.resultsTableController.filteredActivities = result;
                                                          
                                                          [self.resultsTableController.tableView reloadData];
                                                          
                                                      } else {
                                                          /**
                                                           *  Do Something!
                                                           */
                                                      }
                                                      
                                                      [self dismissProgressHUD];
                                                      
                                                  }
                                                  failureBlock:^(NSError *error) {
                                                      
                                                      DDLogError(@"Error while searching.");
                                                      
                                                      [self dismissProgressHUD];
                                                      
                                                  }];
    }
    
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultsTableController.filteredActivities = nil;
    
    [self.resultsTableController.tableView reloadData];
}

#pragma mark - UISearchController Delegate Methods

- (void)willPresentSearchController:(UISearchController *)searchController
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:YES];
    
    self.navigationController.navigationBar.translucent = YES;
    
    [self.searchController.searchBar setSearchBarStyle:UISearchBarStyleDefault];
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:YES];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self.searchController.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
}

#pragma mark - UITableView DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCLActivityCellIdentifier];
    
    [cell configureCellAppearanceWithData:indexPath];
    
    CLActivity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (activity) {
        
        [cell configureCellWithDictionary:@{@"activity": activity}];
        
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        
        NSString   *sectionTitle;
        CLActivity *activity = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                   inSection:section]];
        
        NSDate *date = [CLDateHelper dateFromStringDate:activity.activityDate
                                              formatter:kCLDateFormatterISO8601];
        
        if ([[NSDate date] compare:date] == NSOrderedDescending) {
            date = [NSDate date];
        }
        
        if ([date isToday]) {
            
            sectionTitle = kCLSectionTitleToday;
            
        } else if ([date isTomorrow]) {
            
            sectionTitle = kCLSectionTitleTomorrow;
            
        } else {
            
            sectionTitle = [CLDateHelper stringForSectionWithStringDate:activity.activityDate];
            
        }
        
        return [[CLHomeTableHeaderSection alloc] initWithTitle:sectionTitle];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        
        return kCLRowHeight;
        
    }
    
    return kCLResultsRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        
        return kCLTableHeaderHeight;
        
    }
    
    return 0.f;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(CLActivityCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        
        [cell.avatarImageView removeProgressViewRing];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLActivity *activity = (tableView == self.tableView) ? [self.fetchedResultsController objectAtIndexPath:indexPath] : self.resultsTableController.filteredActivities[indexPath.row];
    
    [self performSegueWithIdentifier:@"HomeActivityDetailsSegue"
                              sender:@{@"activityId": activity.activityId}];
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - CLLocationManagerController Delegate Methods

- (void)locationManagerDidUpdateLocations
{
    [self reloadVisibleCells];
    
    if (self.locationTimer) {
        return;
    }
    
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                          target:self
                                                        selector:@selector(restartLocationUpdates)
                                                        userInfo:nil
                                                         repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(stopLocationDelayBySomeSeconds)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)locationManagerController:(CLLocationManagerController *)manager didFailWithError:(NSError *)error
{
    /**
     *  We could not get your location. Please tap again. [FEATURE]
     */
    
    DDLogInfo(@"Location manager did fail with error: %@", error.localizedFailureReason);
    
    [self dismissProgressHUD];
    
    [self.refreshControl endRefreshing];
}

- (void)locationManagerDidChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [self locationServiceDisableViewShouldAppear:NO];
        
        if ([CLApiClient sharedInstance].loggedUser.locationsArray.count > 0) {
            
            [self loadActivities];
            
        } else {
            
            if (self.flagActivitiesFirstTimeFetch) {
                
                [self showProgressHUDWithStatus:@"Getting Your Location..."];
                
            }
            
            [[CLLocationManagerController sharedInstance] startNotify];
            
        }
        
    } else if (status == kCLAuthorizationStatusDenied) {
        
        [self locationServiceDisableViewShouldAppear:YES];
        
    }
}

#pragma mark - Private Methods

- (void)restartLocationUpdates
{
    if (self.locationTimer) {
        
        [self.locationTimer invalidate];
        self.locationTimer = nil;
        
    }
    
    [[CLLocationManagerController sharedInstance] startNotify];
}

- (void)stopLocationDelayBySomeSeconds
{
    [self loadActivities];

    if (self.flagActivitiesFirstTimeFetch) {
        
        self.flagActivitiesFirstTimeFetch = NO;
        
    }
    
    [[CLLocationManagerController sharedInstance] stopUpdatingLocation];
    
    [self dismissProgressHUD];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CLActivityDetailsViewController *activityDetailsController = segue.destinationViewController;
    
    activityDetailsController.activityId = sender[@"activityId"];
}

- (void)goToSettings
{
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    [[UIApplication sharedApplication] openURL:settingsURL];
}

- (void)reloadActivities
{
    if (self.filtersViewController || self.searchController.searchBar.text.length) {
        
        self.fetchedResultsController = [CLCoreDataFactories allActivities];
        
        self.filtersViewController    = nil;
        
        [self.navigationTitleView showSubtitle:NO];
        
    }
    
    [self loadActivities];
}

- (void)loadActivities
{
    if (self.filtersViewController || self.searchController.searchBar.text.length) {
        
        [self.refreshControl endRefreshing];
        
        return;
    }
    
    if ([CLApiClient sharedInstance].loggedUser.locationsArray.count > 0) {
        
        NSDictionary *dic = [CLApiClient sharedInstance].loggedUser.locationsArray.lastObject;
        
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([dic[@"latitude"]  floatValue],
                                                                        [dic[@"longitude"] floatValue]);
        
        [[CLApiClient sharedInstance] activitiesWithCoordinates:coordinates
                                                   successBlock:^(NSArray *result) {
                                                       
                                                       DDLogInfo(@"Success fetching Activities - %lu items fetched", (unsigned long)result.count);
                                                       self.fetchedResultsController = [CLCoreDataFactories allActivities];

                                                       [self searchBarShouldEnable];
                                                       [self    reloadVisibleCells];
                                                       
                                                       [self.refreshControl endRefreshing];
                                                       
                                                   } failureBlock:^(NSError *error) {
                                                       
                                                       DDLogError(@"Error: %@", error.description);
                                                       
                                                       if (error.code != -999) {
//                                                           [RMessage showErrorMessageWithTitle:@"Could not load activities."];
                                                       }
                                                       
                                                       [self reloadVisibleCells];
                                                       
                                                       [self.refreshControl endRefreshing];
                                                       
                                                   }];
    } else {
        
        [[CLLocationManagerController sharedInstance] startNotify];
        
    }
}

- (void)locationServiceDisableViewShouldAppear:(BOOL)flag
{
    self.locationServiceDisableView.hidden = !flag;
    self.tableView.scrollEnabled           = !flag;
}

- (void)searchBarShouldEnable
{
    self.searchController.searchBar.userInteractionEnabled = YES;
    
    if (![self.tableView.nxEV_emptyView isHidden]) {
        
        self.searchController.searchBar.userInteractionEnabled = NO;
        
    }
}

- (void)reloadVisibleCells
{
//    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(CLActivityCell *cell, NSUInteger idx, BOOL *stop) {
//        
//        [cell needsDistanceLayout];
//        
//    }];
    [self.tableView reloadData];
}

- (void)showFilters:(id)sender
{
    if (!self.filtersViewController) {
        
        self.filtersViewController = [CLFiltersViewController new];
        
        __weak typeof(self) weakSelf = self;
        
        [self.filtersViewController getFilteredActivitiesWithCompletion:^(NSArray *results) {

            if (results.count > 0) {
                
                weakSelf.fetchedResultsController = [CLCoreDataFactories allActivitiesInScratch];
                
                [weakSelf.navigationTitleView showSubtitle:YES];
                
            } else {
                
                [UIAlertView showMessage:nil
                                   title:@"There are no activities matching your filter settings. Please change your filter settings and try again."];
                
//                self.fetchedResultsController = [CLCoreDataFactories allActivities];
                weakSelf.filtersViewController = nil;
                
                [weakSelf.navigationTitleView showSubtitle:NO];

            }
            
        }];
        
    }
    
    CLNavigationController *navController = [[CLNavigationController alloc] initWithRootViewController:self.filtersViewController];
    
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

@end
