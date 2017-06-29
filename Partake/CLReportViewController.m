//
//  CLReportViewController.m
//  Partake
//
//  Created by Maikel on 08/09/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLReportViewController.h"
#import "CLReportCommentsCell.h"
#import "CLFiltersActivityCell.h"
#import "CLReportsTableHeaderSection.h"


#define kCLRowHeightCellReason   50.f
#define kCLRowHeightCellComments 250.f
#define kCLSectionHeaderHeight   80.f
#define kCLSectionFooterHeight   0.f

#define kCLSectionTitleReason   @"Provide a reason for reporting this user:"
#define kCLSectionTitleComments @"Provide additional comments here:"


@interface CLReportViewController ()
@property (strong, nonatomic) NSArray        *reportReasons;
@property (assign, nonatomic) NSInteger     selectedIndex;
@property (strong, nonatomic) NSString       *reportComments;
@property (strong, nonatomic) CLReportCommentsCell *reportCommentsCell;
@end

@implementation CLReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Report";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerNib:[CLFiltersActivityCell nib]
         forCellReuseIdentifier:[CLFiltersActivityCell reuseIdentifier]];
    
    [self.tableView registerNib:[CLReportCommentsCell nib]
         forCellReuseIdentifier:[CLReportCommentsCell reuseIdentifier]];
    
    self.reportReasons   = [self ReportReasonTitles];
    self.selectedIndex   = 0;
    
    [self configureCells];
    [self requiredPopViewControllerBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Report"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(reportAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)reportAction
{
    [self.view endEditing:YES];
    
    [UIAlertView showAlertWithTitle:@"Are you sure you want to report this user?"
                            message:nil
                        cancelTitle:@"No"
                        acceptTitle:@"Yes"
                 cancelButtonAction:nil
                       acceptAction:^{
                           
                           [self reportUser];
                           
                       }];
}

- (void)reportUser
{
    [[CLApiClient sharedInstance] reportUserWithFbId:self.fbIdToReport
                                              reason:[self ReportReasonValues][self.selectedIndex]
                                            comments:self.reportComments
                                        successBlock:^(NSArray *result) {
                                            
                                            DDLogInfo(@"Success reporting user");
                                            
                                            [UIAlertView showMessage:@"Thank you for reporting this user. This user is now blocked from viewing your profile and will no longer be able to communicate with you."];

                                            [self.view endEditing:YES];
                                            
                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                            
                                        } failureBlock:^(NSError *error) {
                                            
                                            DDLogError(@"Error reporting user - %@", error.localizedDescription);
                                            
                                            [UIAlertView showErrorMessageWithAcceptAction:^{
                                                [self performSelector:@selector(reportUser) withObject:nil];
                                            }];
                                        }];
}

- (void)configureCells
{
    self.reportCommentsCell = [self.tableView dequeueReusableCellWithIdentifier:[CLReportCommentsCell reuseIdentifier]];
       
    __weak typeof(self) weakSelf = self;
    [self.reportCommentsCell getCommentTextWithCompletion:^(NSString *commentsText) {
        weakSelf.reportComments = commentsText;
    }];
}

#pragma mark - TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        CLFiltersActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLFiltersActivityCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configureCellAppearanceWithData:nil];
        
        NSString *key            = self.reportReasons[indexPath.row];
        UIImage  *checkmarkIcon;
        
        if (self.selectedIndex == indexPath.row) {
            
            checkmarkIcon = [UIImage imageNamed:@"filters-activity-check-tick"];
            
        } else {
            
            checkmarkIcon = [UIImage imageNamed:@"filters-activity-check-placeholder"];
            
        }
        
        [cell configureCellAppearanceWithData:@{
                                                @"hideIcon" : @YES
                                                }];
        
        [cell configureCellWithDictionary:@{
                                            @"name":      key,
                                            @"checkmark": checkmarkIcon
                                            }];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        
        return self.reportCommentsCell;
        
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        
        return 1;
        
    }
    
    return self.reportReasons.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableVie
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kCLSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    if (section == 0) {
        
        title = kCLSectionTitleReason;
        
    } else if (section == 1) {
        
        title = kCLSectionTitleComments;
        
    }
    
    return [[CLReportsTableHeaderSection alloc] initWithTitle:title];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return kCLRowHeightCellReason;
        
    } else if (indexPath.section == 1) {
        
        return kCLRowHeightCellComments;
        
    }
    
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kCLSectionFooterHeight;
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
    if (self.selectedIndex != indexPath.row) {
        
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:indexPath.section];
        
        self.selectedIndex = indexPath.row;
        
        [tableView reloadRowsAtIndexPaths:@[oldIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
}



#pragma mark - MISC

- (NSArray *)ReportReasonTitles
{
    return @[
             @"Inappropriate profile photos",
             @"Inappropriate messages",
             @"This user is harrassing or bullying me",
             @"Other"
             ];
}

- (NSArray *)ReportReasonValues
{
    return @[
             @"PHOTOS",
             @"MESSAGES",
             @"BULLYING",
             @"OTHER"
             ];
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
