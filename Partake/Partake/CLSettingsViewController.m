//
//  CLSettingsViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsViewController.h"
#import "CLSettingsCell.h"
#import "CLEditProfileViewController.h"
#import "CLLabel.h"

static CGFloat const kCLSocialMediaPanelHeight = 120.f;


@interface CLSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    [_tableView registerNib:[CLSettingsCell nib] forCellReuseIdentifier:[CLSettingsCell reuseIdentifier]];
    _tableView.tableFooterView = [self tableViewFooterView];
}


#pragma mark - Actions

- (void)socialMediaAction:(id)sender {
    UIButton *socialButton = (UIButton *)sender;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[socialButton titleForState:UIControlStateReserved]]];
}


#pragma mark - Table View
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLSettingsCell reuseIdentifier]];
    
    NSString *title = @"";

    switch (indexPath.row) {
        case 1:
            title = @"About";
            break;
        case 2:
            title = @"Tell a Friend";
            break;
        case 4:
            title = @"Profile";
            break;
        case 5:
            title = @"Default Preferences";
            break;
        case 6:
            title = @"In-App Notifications";
            break;
        default:
            break;
    }
    
    [cell configureCellWithDictionary:@{@"title" : title}];
    
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
- (UIView *)tableViewFooterView {
    NSArray *metaData = @[
                          @{
                              @"name" : @"facebook",
                              @"icon" : @"social_facebook",
                              @"url"  : @"http://www.facebook.com/gopartake"
                              },
                          @{
                              @"name" : @"twitter",
                              @"icon" : @"social_twitter",
                              @"url"  : @"http://www.twitter.com/gopartake"
                              },
                          @{
                              @"name" : @"vimeo",
                              @"icon" : @"social_vimeo",
                              @"url"  : @"https://vimeo.com/partake"
                              },
                          @{
                              @"name" : @"youtube",
                              @"icon" : @"social_youtube",
                              @"url"  : @"https://www.youtube.com/channel/UCNl9hKWPi98QxGaTMowa-vA/videos"
                              },
                          @{
                              @"name" : @"instagram",
                              @"icon" : @"social_instagram",
                              @"url"  : @"http://www.instagram.com/gopartake"
                              }
                          ];

    CGFloat margin = 20.f;
    CGFloat padding = 10.f;
    CGFloat buttonWidth = (self.view.width - margin * 2 - padding * (metaData.count - 1)) / metaData.count;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width, kCLSocialMediaPanelHeight)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    CLLabel *label = [[CLLabel alloc] initWithFrame:CGRectMake(5.f, kCLSocialMediaPanelHeight - buttonWidth - 30.f, 100.f, 20.f)];
    label.textColor = [UIColor standardTextColor];
    label.font      = [UIFont  fontWithName:kCLPrimaryBrandFontText
                                       size:13.f];
    label.text      = @"Follow us:";
    
    [footerView addSubview:label];
    
    for (int i = 0; i < metaData.count; i++) {
        NSDictionary *data = metaData[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(margin + (buttonWidth + padding) * i,
                                    kCLSocialMediaPanelHeight - buttonWidth,
                                    buttonWidth, buttonWidth)];
        [button setImage:[UIImage imageNamed:data[@"icon"]] forState:UIControlStateNormal];
        [button setTitle:data[@"url"] forState:UIControlStateReserved];
        [button addTarget:self action:@selector(socialMediaAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [footerView addSubview:button];
    }
    
    return footerView;
}

#pragma mark Delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return kCLSocialMediaPanelHeight;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return 100.f;
            
        case 3:
            return 60.f;
            
        default:
            break;
    }
    
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1:
            [self performSegueWithIdentifier:@"AboutSegue" sender:nil];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"InviteSegue" sender:nil];
            break;
            
        case 4:
            [self showEditProfileScreen];
            break;
            
        case 5:
            [self performSegueWithIdentifier:@"PreferencesSegue" sender:nil];
            break;
            
        case 6:
            [self performSegueWithIdentifier:@"NotificationsSegue" sender:nil];
            break;
        default:
            break;
    }
}


#pragma mark - Misc

- (void)showEditProfileScreen {
    CLEditProfileViewController *profileVC = [[UIStoryboard storyboardWithName:@"CLProfileViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"CLEditProfileViewController"];

    NSManagedObjectContext *moc     = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    NSFetchRequest         *request = [NSFetchRequest new];
    
    NSEntityDescription    *entity  = [NSEntityDescription entityForName:@"CLUser"
                                                  inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId ==[c] %@", [CLApiClient sharedInstance].loggedUser.userId];
    
    [request    setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *array = [moc executeFetchRequest:request
                                        error:&error];
    
    if (array != nil && array.count > 0) {
        
        profileVC.user = [array firstObject];
        
    }
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end
