//
//  CLSettingsAboutViewController.m
//  Partake
//
//  Created by Maikel on 08/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsAboutViewController.h"
#import "CLSettingsCell.h"
#import "CLWebViewController.h"
#import "CLAppDelegate.h"


@interface CLSettingsAboutViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end



@implementation CLSettingsAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"About";

    [_tableView registerNib:[CLSettingsCell nib] forCellReuseIdentifier:[CLSettingsCell reuseIdentifier]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (void)deactivateAccountAction {
    [UIAlertView showAlertWithTitle:nil
                            message:@"Are you sure you want to deactivate your account? All your activities data will be removed."
                        cancelTitle:@"No"
                        acceptTitle:@"Yes"
                 cancelButtonAction:nil
                       acceptAction:^{
                           [[CLApiClient sharedInstance] deactivateUserAccountWithSuccessBlock:^{
                               
                               DDLogInfo(@"Success destroying user account, resetting local data");
                               
                               //[[FBSession         activeSession] closeAndClearTokenInformation];
                               FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
                               [manager logOut];
                               
                               [[CLApiClient       sharedInstance].loggedUser removeFromDisk];
                               [[CLApiClient       sharedInstance] removeInstance];
                               [[CLDatabaseManager sharedInstance] flushDatabase];
                               [[CLDatabaseManager sharedInstance] removeInstance];
                               [[CLAppDelegate     sharedInstance] showLogin];
                               
                           } failureBlock:^(NSError *error) {
                               
                               DDLogError(@"Failed destroying user account - %@", error.localizedDescription);
                               
                               if (error) {
                                   [UIAlertView showErrorMessageWithAcceptAction:nil];
                               }
                               
                           }];
                       }];
}

#pragma mark - Table View
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLSettingsCell reuseIdentifier]];
    
    NSString *title = @"";
    
    switch (indexPath.row) {
        case 1:
            title = @"FAQ";
            break;
        case 2:
            title = @"Terms of Service";
            break;
        case 3:
            title = @"Privacy Policy";
            break;
        case 4:
            title = @"Rate App";
            break;
        case 5:
            break;
        case 7:
            title = @"Deactivate Account";
            break;
        default:
            break;
    }
    
    [cell configureCellWithDictionary:@{@"title" : title}];
//                                        @"badge" : (indexPath.row == 4) ? @(2) : @(0)}];
    
    return cell;
}

#pragma mark Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return 60.f;
            
        case 6:
            return 160.f;
            
        default:
            break;
    }
    
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1:
            [self performSegueWithIdentifier:@"FAQSegue" sender:nil];
            break;

        case 2:
            [self performSegueWithIdentifier:@"TSSegue" sender:nil];
            break;

        case 3:
            [self performSegueWithIdentifier:@"PPSegue" sender:nil];
            break;

        case 4:
            [self openAppStoreReviewPage];
            break;
            
        case 5:
            [self openAppStoreReviewPage];
            break;
            
        case 7:
            [self deactivateAccountAction];
            break;
            
        default:
            break;
    }
}

- (void)openAppStoreReviewPage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kCLPartakeAppStoreURL]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FAQSegue"]) {
        CLWebViewController *webVC = segue.destinationViewController;
        webVC.title = @"FAQ";
        webVC.URL = kCLPartakeFAQPageURL;
        
    } else if ([segue.identifier isEqualToString:@"TSSegue"]) {
        CLWebViewController *webVC = segue.destinationViewController;
        webVC.title = @"Terms of Service";
        webVC.URL = kCLPartakeTermsOfServicePageURL;
        
    } else if ([segue.identifier isEqualToString:@"PPSegue"]) {
        CLWebViewController *webVC = segue.destinationViewController;
        webVC.title = @"Privacy Policy";
        webVC.URL = kCLPartakePrivacyPolicyPageURL;
    }
}


@end
