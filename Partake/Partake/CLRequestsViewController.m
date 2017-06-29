//
//  ActivitiesViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLRequestCell.h"
#import "CLHomeViewController.h"
#import "UITableView+NXEmptyView.h"
#import "CLRequestEmptyTableView.h"
#import "CLRequestsViewController.h"
#import "CLActivityDetailsRequestViewController.h"
#import "CLRequest+ModelController.h"


#define kCLRowHeight 90.f

static NSString * const kCLRequestCellIdentifier = @"RequestCell";

@interface CLRequestsViewController ()

@property (strong, nonatomic) UISegmentedControl      *segmentedControl;
@property (strong, nonatomic) UIRefreshControl        *refreshControl;
@property (strong, nonatomic) CLRequestEmptyTableView *requestEmptyTableView;

@end

@implementation CLRequestsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Requests";
    
    self.requestEmptyTableView = [CLRequestEmptyTableView new];
    
    UITapGestureRecognizer *tapGestureNoRequests = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(loadRequests)];
    
    [self.requestEmptyTableView addGestureRecognizer:tapGestureNoRequests];
    
    self.tableView.tableHeaderView = [self generateTableHeaderForSegmentedControl];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.nxEV_emptyView  = self.requestEmptyTableView;
    
    UINib *requestCellNib = [UINib nibWithNibName:NSStringFromClass([CLRequestCell class])
                                           bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:requestCellNib
         forCellReuseIdentifier:kCLRequestCellIdentifier];
    
    self.refreshControl           = [UIRefreshControl new];
    self.refreshControl.tintColor = [UIColor primaryBrandColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(loadRequests)
                  forControlEvents:UIControlEventValueChanged];
    
    self.fetchedResultsController = [CLCoreDataFactories pendingRequestsWithFacebookId:[CLApiClient sharedInstance].loggedUser.fbUserId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadRequests)
                                                 name:kCLBlockedUserNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadRequests];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCLBlockedUserNotification
                                                  object:nil];
}

#pragma mark - TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:kCLRequestCellIdentifier];
    
    [cell configureCellAppearanceWithData:indexPath];
    
    CLRequestCell *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (request) {
        
        [cell configureCellWithDictionary:@{@"request": request}];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCLRowHeight;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(CLRequestCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.avatarImageView removeProgressViewRing];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLRequest *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"RequestsActivityDetailsSegue"
                              sender:@{@"request" : request}];
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - Private Methods

- (void)loadRequests
{
    [[CLApiClient sharedInstance] requestsForLoggedUserWithSuccessBlock:^(NSArray *result) {
        
        DDLogInfo(@"Success fetching Requests - %lu items fetched", (unsigned long)result.count);

        [self.refreshControl endRefreshing];
        
        [self filterChange];
        
    } failureBlock:^(NSError *error) {
        
        DDLogError(@"Error: %@", error.description);
        
        [self.refreshControl endRefreshing];
        
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationDidReadRequest object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CLActivityDetailsRequestViewController *activityDetailsRequestViewController = segue.destinationViewController;
    
    CLRequest *request = sender[@"request"];
    activityDetailsRequestViewController.headerUser = request.theOtherUser;
    activityDetailsRequestViewController.activityId = request.activityId;
    activityDetailsRequestViewController.footerText = request.requestNote;
    
    if ([request.activityCreator.userId isEqualToString:request.theOtherUser.userId]) {
        activityDetailsRequestViewController.footerTextTitle = [NSString stringWithFormat:@"Message sent to %@", request.theOtherUser.firstName];
    } else {
        activityDetailsRequestViewController.footerTextTitle = [NSString stringWithFormat:@"Message received from %@", request.theOtherUser.firstName];
    }
}

- (UIView *)generateTableHeaderForSegmentedControl
{
    UIView *header         = [UIView new];
    
    header.backgroundColor = [UIColor clearColor];
    header.frame           = CGRectMake(0.f,
                                        6.f,
                                        self.tableView.width,
                                        60.f);
    
    self.segmentedControl           = [UISegmentedControl new];
    self.segmentedControl.tintColor = [UIColor primaryBrandColor];
    self.segmentedControl.frame     = CGRectMake(13.f,
                                                 10.f,
                                                 (self.tableView.width - 26.f),
                                                 30.f);
    
    [self.segmentedControl insertSegmentWithTitle:@"Pending"
                                          atIndex:0
                                         animated:NO];
    
    [self.segmentedControl insertSegmentWithTitle:@"Confirmed"
                                          atIndex:1
                                         animated:NO];
    
    [self.segmentedControl insertSegmentWithTitle:@"Received"
                                          atIndex:2
                                         animated:NO];
    
    [self.segmentedControl addTarget:self
                              action:@selector(filterChange)
                    forControlEvents:UIControlEventValueChanged];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [header addSubview:self.segmentedControl];
    
    return header;
}

- (void)filterChange
{
    NSString *userFacebookId = [CLApiClient sharedInstance].loggedUser.fbUserId;
    
    switch (self.segmentedControl.selectedSegmentIndex) {
            
        case 0:
            self.fetchedResultsController = [CLCoreDataFactories pendingRequestsWithFacebookId:userFacebookId];
            break;
            
        case 1:
            self.fetchedResultsController = [CLCoreDataFactories acceptedRequestsWithFacebookId:userFacebookId];
            break;
            
        case 2:
            self.fetchedResultsController = [CLCoreDataFactories receivedRequestsWithFacebookId:userFacebookId];
            break;
            
    }
    
}

@end
