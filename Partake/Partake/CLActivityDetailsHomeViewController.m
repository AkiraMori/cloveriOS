//
//  CLActivityDetailsHomeViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLAppearanceHelper.h"
#import "CLSendRequestViewController.h"
#import "CLActivityDetailsStatusRequestCell.h"
#import "CLActivityDetailsHomeViewController.h"

@interface CLActivityDetailsViewController ()

@property (weak,   nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CLActivity     *activity;
@property (strong, nonatomic) NSMutableArray *cells;

@property (strong, nonatomic) CLActivityDetailsStatusRequestCell *cellStatusRequest;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)configureCells;
- (void)loadFacebookMutualFriends;

@end

@implementation CLActivityDetailsHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self
                            action:@selector(loadActivity)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadActivity];
}

- (void)loadActivity
{
    [[CLApiClient sharedInstance] activityWithId:self.activityId
                                    successBlock:^(NSArray *result) {
                                        
                                        DDLogInfo(@"Activity with ID: %@ load properly.", self.activityId);
                                        
                                        [self.refreshControl endRefreshing];
                                        
                                        self.activity = result.firstObject;
                                        self.headerUser = self.activity.user;
                                        
                                        [self configureCells];
                                        
                                        [self.tableView reloadData];
                                        
                                        [self setRequestButtonStatus];
                                        
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                            
                                            [self loadFacebookMutualFriends];
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                                                            inSection:0]]
                                                                      withRowAnimation:UITableViewRowAnimationNone];
                                                
                                            });
                                        });
                                        
                                    } failureBlock:^(NSError *error) {
                                        
                                        DDLogError(@"Error loading activity with ID: %@", self.activityId);
                                        
                                    }];
}

#pragma mark - Request Methods

- (void)setRequestButtonStatus
{
    if (![self.activity isLoggedUserOwner]) {
        [CLRequest requestForActivityId:self.activityId
                             withUserId:self.headerUser.userId
                    withCompletionBlock:^(CLRequest *request) {
                        if (request != nil) {
                            
                            [self shouldBarButtonDisplayJoin:NO];
                            
                            [self insertStatusRequestCellWithStatusRequest:request.requestState];
                            
                        } else {
                            
                            [self shouldBarButtonDisplayJoin:YES];
                            
                        }
                    }];
    }
}

- (void)shouldBarButtonDisplayJoin:(BOOL)flag
{
    NSString *title;
    
    if (flag) {
        
        title = @"Send Request";
        
    } else {
        
        title = @"Sent";
        
    }
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(sendRequest:)];
    
    rightBarButtonItem.enabled = flag;
    
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem
                                      animated:YES];
}

- (void)insertStatusRequestCellWithStatusRequest:(NSString *)statusRequest
{
    if (statusRequest != nil &&
        ![statusRequest isEqualToString:@""] &&
        ![statusRequest isEqualToString:kCLStatusRequestReceived] &&
        ![statusRequest isEqualToString:kCLStatusRequestCancelled]) {
        
        NSString    *statusRequestString = @"";
        
        if ([statusRequest isEqualToString:kCLStatusRequestPending]) {
            
            statusRequestString = @"You have already requested to join this activity.";
            
        } else if ([statusRequest isEqualToString:kCLStatusRequestAccepted]) {
            
            statusRequestString = [NSString stringWithFormat:@"Woohoo! %@ accepted your request! Send a chat now to begin making plans!",
                                   self.activity.user.firstName];
            
        }
        
        self.cellStatusRequest.height = [CLAppearanceHelper calculateHeightWithString:statusRequestString
                                                                           fontFamily:kCLPrimaryBrandFontText
                                                                             fontSize:12.f
                                                                    boundingSizeWidth:self.tableView.width];
        
        [self.cellStatusRequest configureCellWithDictionary:@{@"statusRequest": statusRequestString}];
        
        if (self.cellStatusRequest && ![self.cells containsObject:self.cellStatusRequest]) {
            
            [self.cells insertObject:self.cellStatusRequest
                             atIndex:1];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1
                                                        inSection:0];
            if (!indexPath) {
                return;
            }
            
            [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
    }
}

- (void)sendRequest:(id)sender
{
    CLSendRequestViewController *sendRequestViewController = [CLSendRequestViewController new];
    
    sendRequestViewController.activity = self.activity;
    
    [sendRequestViewController updateBarButtonWithCompletion:^(BOOL flag) {
        
        [self shouldBarButtonDisplayJoin:flag];
        
        [self insertStatusRequestCellWithStatusRequest:kCLStatusRequestPending];
        
    }];
    
    CLNavigationController *navController = [[CLNavigationController alloc] initWithRootViewController:sendRequestViewController];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

@end
