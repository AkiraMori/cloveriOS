//
//  CLChatViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLChatViewController.h"
#import "CLConstants.h"
#import "CLChatDialogCell.h"
#import "CLMessagesViewController.h"
#import "CLAppDelegate.h"
#import "CLQuickBloxManager.h"

#define kCLHeaderHeight 30.f
#define kCLRowHeight 90.f

@interface CLChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CLChatViewController

#pragma mark
#pragma mark ViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Chat";
    
    [self.tableView registerNib:[CLChatDialogCell nib]
         forCellReuseIdentifier:[CLChatDialogCell reuseIdentifier]];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, kCLHeaderHeight)];
    self.tableView.rowHeight = kCLRowHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dialogsUpdatedNotification)
                                                 name:kCLNotificationDialogsUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chatDidAccidentallyDisconnectNotification)
                                                 name:kCLNotificationChatDidAccidentallyDisconnect
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(groupDialogJoinedNotification)
                                                 name:kCLNotificationGroupDialogJoined
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bar_users"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(openUsers)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([QBSession currentSession].currentUser == nil){
        return;
    }
    
    if([CLChatService sharedInstance].dialogs == nil){
        // get dialogs
        [SVProgressHUD showWithStatus:@"Loading"];
    }else{
        [[CLChatService sharedInstance] sortDialogs];
        [self.tableView reloadData];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [[CLChatService sharedInstance] requestDialogsWithCompletionBlock:^{
        [weakSelf.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark Notifications

- (void)dialogsUpdatedNotification{
    [self.tableView reloadData];
}

- (void)chatDidAccidentallyDisconnectNotification{
    [self.tableView reloadData];
}

- (void)groupDialogJoinedNotification{
    [self.tableView reloadData];
}

- (void)willEnterForegroundNotification{
    [self.tableView reloadData];
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CLChatService sharedInstance].dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLChatDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLChatDialogCell reuseIdentifier]];
    
    QBChatDialog *chatDialog = [CLChatService sharedInstance].dialogs[indexPath.row];
    
    cell.tag  = indexPath.row;
    
    [cell configureCellAppearanceWithData:indexPath];
    
    [cell configureCellWithDictionary:@{
                                        @"dialog" : chatDialog
                                        }];    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[CLAppDelegate sharedInstance] openChatScreenWithDialog:[CLChatService sharedInstance].dialogs[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [UIAlertView showAlertWithTitle:@"Confirmation"
                                message:@"Are you sure you want to delete this chat?"
                            cancelTitle:@"No"
                            acceptTitle:@"Yes"
                     cancelButtonAction:^{
                         
                         tableView.editing = NO;
                         
                     } acceptAction:^{
                         
                        [[CLChatService sharedInstance] deleteDialog:[CLChatService sharedInstance].dialogs[indexPath.row] completion:^(NSError *error) {
                            if (error) {
                                
                                [UIAlertView showErrorMessageWithAcceptAction:^{
                                    tableView.editing = NO;
                                }];
                                
                            } else {
                                
                                [tableView reloadData];
                            }
                        }];
                    }];
    }
}

#pragma mark
#pragma mark Storyboard

- (void)openUsers {
    [self performSegueWithIdentifier:@"UserSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"UserSegue"]){
    }
}
@end
