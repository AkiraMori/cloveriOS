//
//  CLActivityDetailsRequestViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLAppearanceHelper.h"
#import "CLActivityDetailsPendingCell.h"
#import "CLActivityDetailsAcceptedCell.h"
#import "CLActivityDetailsReceivedCell.h"
#import "CLActivityDetailsAcceptedOwnerCell.h"
#import "CLActivityDetailsStatusRequestCell.h"
#import "CLActivityDetailsRequestViewController.h"
#import "CLChatService.h"
#import "CLAppDelegate.h"
#import "CLRequest+ModelController.h"
#import "CLReportViewController.h"

#define kCLBlockUser  @"Block User"
#define kCLReportUser @"Report User"

@interface CLActivityDetailsViewController ()

@property (weak,   nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CLActivity     *activity;
@property (strong, nonatomic) NSMutableArray *cells;

@property (strong, nonatomic) CLActivityDetailsStatusRequestCell *cellStatusRequest;

@property (strong, nonatomic) CLActivityDetailsPendingCell       *pendingCell;
@property (strong, nonatomic) CLActivityDetailsReceivedCell      *receivedCell;
@property (strong, nonatomic) CLActivityDetailsAcceptedCell      *acceptedCell;
@property (strong, nonatomic) CLActivityDetailsAcceptedOwnerCell *acceptedOwnerCell;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)configureCells;
- (void)loadFacebookMutualFriends;

@end

@implementation CLActivityDetailsRequestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self
                            action:@selector(loadActivity)
                  forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar-button-options"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showOptions)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOptionNotification)
                                                 name:kCLRequestOptionPerformedNotification
                                               object:nil];
    
    [self loadActivity];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCLRequestOptionPerformedNotification
                                                  object:nil];
}

#pragma mark - Utilities

- (void)loadActivity
{
    [[CLApiClient sharedInstance] activityWithId:self.activityId
                                    successBlock:^(NSArray *result) {
                                        
                                        DDLogInfo(@"Activity with ID: %@ load properly.", self.activityId);
                                        
                                        [self.refreshControl endRefreshing];
                                        
                                        self.activity = result.firstObject;
                                        
                                        [self insertStatusRequestCell];
                                        
                                        [self configureCells];
                                        
                                        [self.tableView reloadData];
                                        
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

- (void)showOptions
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirmation"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:kCLBlockUser, kCLReportUser, nil];
    
    [actionSheet showInView:self.view];
}

- (void)insertStatusRequestCell;
{
    [CLRequest requestForActivityId:self.activityId
                         withUserId:self.headerUser.userId
                withCompletionBlock:^(CLRequest *request) {
        
                               [self.pendingCell       configureCellWithDictionary:@{@"requestId": request.requestId}];
                               [self.receivedCell      configureCellWithDictionary:@{@"requestId": request.requestId}];
                               [self.acceptedCell      configureCellWithDictionary:@{@"requestId": request.requestId}];
                               [self.acceptedOwnerCell configureCellWithDictionary:@{@"requestId": request.requestId}];
                               
                               NSString *fbUserId     = self.headerUser.fbUserId;
                               NSString *requestId    = request.requestId;
                               NSString *activityId   = request.activityId;
                               NSString *activityName = request.activityName;
                               NSString *activityType = request.activityType;
                               
                               void (^startChatBlock)() = ^{
                                   
                                   if (!fbUserId) {
                                       return;
                                   }
                                   
                                   QBUUser *user = [[CLChatService sharedInstance] userWithFacebookID:fbUserId];
                                   
                                   if (user) {
                                       
                                       [self createAndOpenChatDialogWithUser:user.ID
                                                                   requestId:requestId
                                                                  activityId:activityId
                                                                activityName:activityName
                                                                activityType:activityType];
                                       
                                   } else {
                                       
                                       [[CLChatService sharedInstance] getUsersWithFacebookIDs:@[fbUserId] withCompletion:^(NSError *error, NSArray *results) {
                                           if (!error && results.count) {
                                               
                                               [self createAndOpenChatDialogWithUser:((QBUUser *)results.lastObject).ID
                                                                           requestId:requestId
                                                                          activityId:activityId
                                                                        activityName:activityName
                                                                        activityType:activityType];
                                               
                                           } else {
                                               
                                               DDLogError(@"Error fetching user data - %@", error);
                                               
                                               [UIAlertView showMessage:@"Failed to get user data. Please try again later" title:@"Error"];
                                               
                                           }
                                       }];
                                   }
                               };
                               
                               [self.receivedCell      setOnStartChat:startChatBlock];
                               [self.acceptedCell      setOnStartChat:startChatBlock];
                               [self.acceptedOwnerCell setOnStartChat:startChatBlock];
                               
                               if (request.requestState != nil && ![request.requestState isEqualToString:@""]) {
                                   
                                   NSString        *statusRequestString;
                                   
                                   UITableViewCell *optionsCell;
                                   
                                   if ([request.requestState isEqualToString:kCLStatusRequestPending] &&
                                       [request.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
                                       
                                       statusRequestString = [NSString stringWithFormat:@"Hang on... your request to %@ is still pending.",
                                                              self.activity.user.firstName];
                                       
                                       optionsCell = self.pendingCell;
                                       
                                   } else if ([request.requestState isEqualToString:kCLStatusRequestAccepted]) {
                                       
                                       if ([request.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
                                           
                                           statusRequestString = [NSString stringWithFormat:@"Woohoo! %@ accepted your request! Send a chat now to begin making plans!",
                                                                  self.activity.user.firstName];
                                           
                                           optionsCell = self.acceptedCell;
                                           
                                       } else if (![request.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
                                           
                                           statusRequestString = [NSString stringWithFormat:@"Well done! You accepted an invitation request."];
                                           
                                           optionsCell = self.acceptedOwnerCell;
                                           
                                       }
                                       
                                   } else if ([request.requestState isEqualToString:kCLStatusRequestPending] &&
                                              ![request.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
                                       
                                       statusRequestString = [NSString stringWithFormat:@"Great news! You received a request from %@.",
                                                              request.userName];
                                       
                                       optionsCell = self.receivedCell;
                                       
                                   }
                                   
                                   if (![self.cells containsObject:optionsCell]) {
                                       
                                       NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.cells.count
                                                                                   inSection:0];
                                       
                                       [self.cells insertObject:optionsCell
                                                        atIndex:self.cells.count];
                                       
                                       [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                                             withRowAnimation:UITableViewRowAnimationFade];
                                       
                                   }
                                   
                                   self.cellStatusRequest.height = [CLAppearanceHelper calculateHeightWithString:statusRequestString
                                                                                                      fontFamily:kCLPrimaryBrandFontText
                                                                                                        fontSize:12.f
                                                                                               boundingSizeWidth:self.tableView.width];
                                   
                                   [self.cellStatusRequest configureCellWithDictionary:@{@"statusRequest": statusRequestString}];
                                   
                                   if (![self.cells containsObject:self.cellStatusRequest]) {
                                       
                                       NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1
                                                                                   inSection:0];
                                       
                                       [self.cells insertObject:self.cellStatusRequest
                                                        atIndex:1];
                                       
                                       [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                                             withRowAnimation:UITableViewRowAnimationFade];
                                       
                                   }
                                   
                               }
                           }];
}

- (void)receiveOptionNotification
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)createAndOpenChatDialogWithUser:(NSInteger)userId
                              requestId:(NSString *)requestId
                             activityId:(NSString *)activityId
                           activityName:(NSString *)activityName
                           activityType:(NSString *)activityType
{
    [[CLChatService sharedInstance] createChatDialogWithUser:userId
                                                   requestId:requestId
                                                  activityId:activityId
                                                activityName:activityName
                                                activityType:activityType
                                              withCompletion:^(NSError *error, NSArray *results) {
                                                  
                                                  if (!error && results.count) {
                                                      
                                                      [[CLAppDelegate sharedInstance] openChatScreenWithDialog:results.lastObject];
                                                      
                                                  } else {
                                                      
                                                      DDLogError(@"Error creating chat dialog - %@", error);
                                                      
                                                      [UIAlertView showMessage:@"Failed to open chat dialog with user. Please try again later." title:@"Error"];
                                                      
                                                  }
                                              }];
    
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (![self.activity isLoggedUserOwner]) {
        
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kCLBlockUser]) {
            
            NSString *message = [NSString stringWithFormat:@"You are about to block %@ %@. If you do this you will not be able to see any information related to this user.",
                                 self.activity.user.firstName,
                                 self.activity.user.lastName];
            
            [UIAlertView showAlertWithTitle:@"Are you sure?"
                                    message:message
                                cancelTitle:@"Cancel"
                                acceptTitle:@"I'm Sure"
                         cancelButtonAction:nil
                               acceptAction:^{
                                   
                                   [self blockUserServerCall];
                                   
                               }];
            
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kCLReportUser]) {
            
           CLReportViewController *reportVC = [[CLReportViewController alloc] init];
           reportVC.fbIdToReport            = self.activity.user.fbUserId;
            
           [self.navigationController pushViewController:reportVC animated:YES];

        }
        
    }
}

- (void)blockUserServerCall
{
    [[CLApiClient sharedInstance] blockUserWithFbId:self.activity.user.fbUserId
                                       successBlock:^(NSArray *result) {
                                           
                                           NSString *message = [NSString stringWithFormat:@"%@ %@ was blocked.",
                                                                self.activity.user.firstName,
                                                                self.activity.user.lastName];
                                           
                                           DDLogInfo(@"Blocked User: %@", message);
                                           
                                           [RMessage showSuccessMessageWithTitle:message];
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:kCLBlockedUserNotification
                                                                                               object:nil];
                                           
                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                           
                                       } failureBlock:^(NSError *error) {
                                           
                                           DDLogError(@"");
                                           
                                           [UIAlertView showErrorMessageWithAcceptAction:^{
                                               
                                               [self blockUserServerCall];
                                               
                                           }];
                                           
                                       }];
}

@end
