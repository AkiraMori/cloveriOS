//
//  CLActivitiesCreatedViewController.m
//  Partake
//
//  Created by Pablo Epíscopo on 4/8/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLDateHelper.h"
#import "CLActivityHelper.h"
#import "CLActivityCreatedCell.h"
#import "UIColor+CloverAdditions.h"
#import "CLCreateActivityViewController.h"
#import "CLActivitiesCreatedViewController.h"
#import "CLCreateActivityNavigationController.h"
#import "CLCoreDataFactories.h"


#define kCLRowHeightCell 154.f

static NSString * const kCLActivityCellIdentifier = @"CreatedActivityCell";

@interface CLCreateActivityViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *contentsDataSource;

@end

@implementation CLActivitiesCreatedViewController {
    NSArray *dataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title                    = @"Create Activity";
    self.navigationItem.title     = @"Activities Created";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.fetchedResultsController = [CLCoreDataFactories loggedUserActivities];
    dataSource                    = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[CLCoreDataFactories predicateForUserActivities]];

    self.refreshControl           = [UIRefreshControl new];
    self.refreshControl.tintColor = [UIColor primaryBrandColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(loadLoggedUserActivities)
                  forControlEvents:UIControlEventValueChanged];
    
    UINib *createdActivityCellNib = [UINib nibWithNibName:NSStringFromClass([CLActivityCreatedCell class])
                                                   bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:createdActivityCellNib
         forCellReuseIdentifier:kCLActivityCellIdentifier];
    
    
    /* Right bar button item (Filter) */
    UIButton *newActivityButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [newActivityButton setImage:[UIImage imageNamed:@"bar-button-new-activity"] forState:UIControlStateNormal];
    [newActivityButton setTitle:@"Create" forState:UIControlStateNormal];
    [[newActivityButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
    [newActivityButton sizeToFit];
    [newActivityButton addTarget:self action:@selector(presentCreateActivityForm:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newActivityButton];
    
    // the space between the image and text
    CGFloat spacing = 3.0;
    CGFloat leftOffset = 20.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = newActivityButton.imageView.image.size;
    newActivityButton.titleEdgeInsets = UIEdgeInsetsMake(
                                                    0.0, - imageSize.width + leftOffset, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [newActivityButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: newActivityButton.titleLabel.font}];
    newActivityButton.imageEdgeInsets = UIEdgeInsetsMake(
                                                    - (titleSize.height + spacing), leftOffset, 0.0, - titleSize.width);
    
    // increase the content height to avoid clipping
    CGFloat edgeOffset = fabs(titleSize.height - imageSize.height) / 2.0;
    newActivityButton.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0);
    /*********************************/
    
    
    [self loadLoggedUserActivities];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kCLActivityDeletedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                                                                            withRowAnimation:UITableViewRowAnimationNone];
                                                      
                                                  }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadLoggedUserActivities];
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.navigationItem.rightBarButtonItem.enabled = (dataSource.count < kCLMaxActivitiesNumber);

    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLActivityCreatedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityCellIdentifier];
    
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    
    CLActivity *activity        = dataSource[indexPath.row];
    
    [cell configureCellAppearanceWithData:indexPath];
    
    [cell configureCellWithDictionary:@{@"activity": activity}];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCLRowHeightCell;
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLActivity *activity = dataSource[indexPath.row];
    
    CLCreateActivityNavigationController *navigationController = [CLCreateActivityNavigationController new];
    
    navigationController.viewControllers = @[navigationController.createActivityViewController];
    
    navigationController.isEditingActivity                                        = YES;
    navigationController.createActivityViewController.activityTitle               = activity.name;
    navigationController.createActivityViewController.activityDetails             = activity.details;
    navigationController.createActivityViewController.activityType                = activity.type;
    navigationController.createActivityFiltersViewController.viewableBy           = activity.visibility;
    navigationController.createActivityFiltersViewController.gender               = activity.gender;
    navigationController.createActivityFiltersViewController.dateString           = activity.activityDate;
    navigationController.createActivityFiltersViewController.endDateString        = activity.activityEndDate;
    navigationController.createActivityFiltersViewController.timeStartString      = activity.fromTime;
    navigationController.createActivityFiltersViewController.timeEndString        = activity.toTime;
    navigationController.createActivityFiltersViewController.locationHumanAddress = [CLActivityHelper determineStringToShowWithLocation:activity.activityLocation];
    navigationController.createActivityFiltersViewController.date                 = [CLDateHelper dateFromStringDate:activity.activityDate formatter:kCLDateFormatterYearMonthDayDashed];
    navigationController.createActivityFiltersViewController.endDate              = [CLDateHelper dateFromStringDate:activity.activityEndDate formatter:kCLDateFormatterYearMonthDayDashed];
    navigationController.createActivityFiltersViewController.ageFrom              = [activity.ageFilterFrom integerValue];
    navigationController.createActivityFiltersViewController.ageTo                = [activity.ageFilterTo integerValue];
    navigationController.createActivityFiltersViewController.timeStart            = [CLDateHelper dateForShortStyleFormatterWithStringDate:activity.fromTime];
    navigationController.createActivityFiltersViewController.timeEnd              = [CLDateHelper dateForShortStyleFormatterWithStringDate:activity.toTime];
    navigationController.createActivityFiltersViewController.attendeeValue        = [activity.isAtendeeVisible boolValue];
    navigationController.createActivityPreviewViewController.activityId           = activity.activityId;
    navigationController.createActivityPreviewViewController.locationId           = activity.activityLocation.locationId;
    
    [self.navigationController presentViewController:navigationController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - Utilities

- (IBAction)presentCreateActivityForm:(id)sender
{
    CLCreateActivityNavigationController *navigationController = [CLCreateActivityNavigationController new];
    
    navigationController.viewControllers = @[navigationController.createActivityViewController];
    
    [self.navigationController presentViewController:navigationController
                                            animated:YES
                                          completion:nil];
}

- (void)loadLoggedUserActivities
{
    NSString *userId = [CLApiClient sharedInstance].loggedUser.userId;
    
    [[CLApiClient sharedInstance] activitiesByUserId:userId
                                        successBlock:^(NSArray *result) {
                                            
                                            DDLogInfo(@"Success fetching Activities - %lu items fetched. For User ID: %@", (unsigned long)result.count, userId);
                                            
                                            [self.refreshControl endRefreshing];
                                            
                                        } failureBlock:^(NSError *error) {
                                            
                                            DDLogError(@"Error: %@", error.description);
                                            
                                            [self.refreshControl endRefreshing];
                                            
                                        }];
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{

}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    dataSource = controller.fetchedObjects;
    dataSource = [controller.fetchedObjects filteredArrayUsingPredicate:[CLCoreDataFactories predicateForUserActivities]];
    [self.tableView reloadData];
}

@end
