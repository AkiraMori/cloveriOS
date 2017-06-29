//
//  CLSettingsNotificationsViewController.m
//  Partake
//
//  Created by Maikel on 08/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsNotificationsViewController.h"
#import "CLSettingsSwitchCell.h"
#import "CLSettingsManager.h"
#import "CLAppDelegate.h"

typedef enum {
    CLSettingsNotificationEmptyRow,
    CLSettingsNotificationInAppVibrationRow,
    CLSettingsNotificationPlaySoundRow,
    CLSettingsNotificationShowPreviewRow,
    CLSettingsNotificationPushNotificationRow,
} CLSettingsNotificationRow;

@interface CLSettingsNotificationsViewController () <UITableViewDataSource, UITableViewDelegate, CLSettingsSwitchCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CLSettingsNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"In-App Notifications";
    
    [_tableView registerNib:[CLSettingsSwitchCell nib] forCellReuseIdentifier:[CLSettingsSwitchCell reuseIdentifier]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLSettingsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLSettingsSwitchCell reuseIdentifier]];
    
    [cell configureCellWithDictionary:@{@"title" : [self titleForRow:(CLSettingsNotificationRow)indexPath.row],
                                        @"switch" : @([self valueForRow:(CLSettingsNotificationRow)indexPath.row])}];
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == CLSettingsNotificationEmptyRow) {
        return 80.f;
    }
    
    return 44.f;
}


#pragma mark - Settings Switch Cell Delegate

- (void)settingsSwitchCell:(CLSettingsSwitchCell *)cell valueChanged:(BOOL)value {
    switch ([_tableView indexPathForCell:cell].row) {
        case CLSettingsNotificationInAppVibrationRow:
            [CLSettingsManager sharedManager].vibrationEnabled = value;
            break;
            
        case CLSettingsNotificationPlaySoundRow:
            [CLSettingsManager sharedManager].soundEnabled = value;
            break;
            
        case CLSettingsNotificationShowPreviewRow:
            [CLSettingsManager sharedManager].previewEnabled = value;
            break;
            
        case CLSettingsNotificationPushNotificationRow:
            [CLSettingsManager sharedManager].pushAlertEnabled = value;
            [[CLAppDelegate sharedInstance] sendDeviceTokenToServer];
            break;
    }
}


#pragma mark - Misc

- (NSString *)titleForRow:(CLSettingsNotificationRow)row {
    switch (row) {
        case CLSettingsNotificationInAppVibrationRow:
            return @"In-App Vibration";
        case CLSettingsNotificationPlaySoundRow:
            return @"Play Sound";
        case CLSettingsNotificationShowPreviewRow:
            return @"Show Preview";
        case CLSettingsNotificationPushNotificationRow:
            return @"Push Notifications";
            
        default:
            return @"";
    }
}

- (BOOL)valueForRow:(CLSettingsNotificationRow)row {
    switch (row) {
        case CLSettingsNotificationInAppVibrationRow:
            return [CLSettingsManager sharedManager].vibrationEnabled;
        case CLSettingsNotificationPlaySoundRow:
            return [CLSettingsManager sharedManager].soundEnabled;
        case CLSettingsNotificationShowPreviewRow:
            return [CLSettingsManager sharedManager].previewEnabled;
        case CLSettingsNotificationPushNotificationRow:
            return [CLSettingsManager sharedManager].pushAlertEnabled;
            
        default:
            return NO;
    }
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
