//
//  CLOnboardingLocationViewController.m
//  Partake
//
//  Created by Maikel on 24/11/15.
//  Copyright © 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLOnboardingLocationViewController.h"
#import "CLOnboardingController.h"
#import "CLLocationManagerController.h"

@interface CLOnboardingLocationViewController () <CLLocationManagerControllerDelegate>

@end

@implementation CLOnboardingLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextAction:(id)sender {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [CLLocationManagerController sharedInstance].wdelegate = self;
        [[CLLocationManagerController sharedInstance] startNotify];
    } else {
        [self warnUserAndGoToNextPage];
    }
}

- (void)gotoNextPage
{
    CLOnboardingController *onboardingController = (CLOnboardingController *)self.parentViewController;
    [onboardingController gotoNextPage];
}

- (void)warnUserAndGoToNextPage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please enable location in the settings!" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self gotoNextPage];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - CLLocationManagerControllerDelegate

- (void)locationManagerController:(CLLocationManagerController *)manager didFailWithError:(NSError *)error {
    
}

- (void)locationManagerDidChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self gotoNextPage];
    } else {
        [self warnUserAndGoToNextPage];
    }
    
    NSLog(@"Status - %d", status);
}

- (void)locationManagerDidUpdateLocations {
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
