//
//  CLUsersViewController.m
//  Partake
//
//  Created by Maikel on 14/09/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLUsersViewController.h"
#import "CLRequestCell.h"
#import "CLCoreDataFactories.h"
#import "CLRequest+ModelController.h"
#import "CLChatService.h"
#import "CLAppDelegate.h"

#define kCLHeaderHeight 30.f
#define kCLRowHeight 90.f


@interface CLUsersViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *dataSource;
@end

@implementation CLUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Users";
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, kCLHeaderHeight)];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[CLRequestCell nib]
         forCellReuseIdentifier:[CLRequestCell reuseIdentifier]];
    
    self.refreshControl           = [UIRefreshControl new];
    self.refreshControl.tintColor = [UIColor primaryBrandColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(loadRequests)
                  forControlEvents:UIControlEventValueChanged];
    
    self.fetchedResultsController = [CLCoreDataFactories chattableRequestsWithFacebookId:[CLApiClient sharedInstance].loggedUser.fbUserId];
    self.fetchedResultsController.delegate = self;
    [self buildDataSource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadRequests)
                                                 name:kCLBlockedUserNotification
                                               object:nil];

    [self loadRequests];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCLBlockedUserNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark - TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLRequestCell reuseIdentifier]];
    
    [cell configureCellAppearanceWithData:indexPath];
    
    CLRequestCell *request = [self.dataSource objectAtIndex:indexPath.row];
    
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
    CLRequest *request = [self.dataSource objectAtIndex:indexPath.row];
    
    QBChatDialog *dialog = [[CLChatService sharedInstance] dialogWithRecipientFacebookID:request.theOtherUser.fbUserId];

    if (dialog) {

        [[CLAppDelegate sharedInstance] openChatScreenWithDialog:dialog];
        
    } else {

        QBUUser *user = [[CLChatService sharedInstance] userWithFacebookID:request.theOtherUser.fbUserId];
        
        if (user) {
            
            [[CLChatService sharedInstance] createChatDialogWithUser:user.ID
                                                           requestId:request.requestId
                                                          activityId:request.activityId
                                                        activityName:request.activityName
                                                        activityType:request.activityType
                                                      withCompletion:^(NSError *error, NSArray *dialogs) {
                if (!error && dialogs.count) {
                    
                    [[CLAppDelegate sharedInstance] openChatScreenWithDialog:dialogs.firstObject];
                    
                } else {
                    
                    DDLogError(@"Error creating chat dialog - %@", error);
                    
                    [UIAlertView showMessage:@"Chat request failed. Please try again later." title:@"Error"];
                    
                }
            }];
            
        } else {
            
            DDLogError(@"Error fetching chat user");
            
            [UIAlertView showMessage:@"Failed to get user information" title:@"Error"];
            
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - Fetched Results Controller Delegate

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
    [self buildDataSource];
    [self.tableView reloadData];
}


#pragma mark - Private Methods

- (void)loadRequests
{
    [[CLApiClient sharedInstance] requestsForLoggedUserWithSuccessBlock:^(NSArray *result) {
        
        DDLogInfo(@"Success fetching Requests - %lu items fetched", (unsigned long)result.count);
        
        [self.refreshControl endRefreshing];
        
        [self buildDataSource];
        
        NSMutableArray *facebookIDs = [NSMutableArray array];
        for (CLRequest *request in self.dataSource) {
            if (![[CLChatService sharedInstance] userWithFacebookID:request.theOtherUser.fbUserId]) {
                [facebookIDs addObject:request.theOtherUser.fbUserId];
            }
        }
        
        if (facebookIDs.count) {
            
            [[CLChatService sharedInstance] getUsersWithFacebookIDs:facebookIDs withCompletion:^(NSError *error, NSArray *users) {
                if (error) {
                    
                    DDLogError(@"Error fetching chat users with facebook IDs - %@", error);
                    
                    [UIAlertView showErrorMessageWithAcceptAction:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    
                } else {
                    
                    DDLogError(@"Success fetching chat users with facebook IDs");

                }
            }];
        }
    } failureBlock:^(NSError *error) {
        
        DDLogError(@"Error: %@", error.description);
        
        [self.refreshControl endRefreshing];
        
    }];
}

- (void)buildDataSource {
    NSMutableDictionary *dataSource = [NSMutableDictionary dictionary];
    NSArray *fetchedObjects = self.fetchedResultsController.fetchedObjects;
    for (CLRequest *request in fetchedObjects) {
        if (request.theOtherUser.fbUserId) {
            [dataSource setObject:request forKey:request.theOtherUser.fbUserId];
        }
    }
    
    self.dataSource = [dataSource allValues];
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
