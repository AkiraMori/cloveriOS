//
//  CLOnboardingFacebookViewController.m
//  Partake
//
//  Created by Maikel on 24/11/15.
//  Copyright © 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLOnboardingFacebookViewController.h"
#import "CLOnboardingController.h"
#import "CLUser.h"
#import "CLDateHelper.h"
#import "CLAppDelegate.h"
#import "CLFacebookHelper.h"
#import "CLUser+ModelController.h"
#import "CLWebViewController.h"
#import "NSDate+DateTools.h"


@interface CLOnboardingFacebookViewController () <FBSDKLoginButtonDelegate, CLLocationManagerControllerDelegate>
@end

@implementation CLOnboardingFacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextAction:(id)sender {
    //__weak typeof(self) weakSelf = self;
    /* adam
    if ([FBSession.activeSession isOpen] && _onboardingController.shouldRerequestPermissions) {
        [FBSession.activeSession requestNewReadPermissions:[CLFacebookHelper readPermissions] completionHandler:^(FBSession *session, NSError *error) {
            [weakSelf loginViewDidOpenSessionWithError:error];
        }];
    } else {
        [FBSession openActiveSessionWithReadPermissions:[CLFacebookHelper readPermissions]
                                           allowLoginUI:YES
                                     fromViewController:nil
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if ([session isOpen] || status == FBSessionStateClosedLoginFailed) {
                                              [weakSelf loginViewDidOpenSessionWithError:error];
                                          }
                                      }];
    }
    */
}


#pragma mark - FBSDKLoginButton Delegate Methods
/*
- (void)loginViewDidOpenSessionWithError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    
    if (error) {
        [self loginView:nil handleError:error];
    } else {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {
                [weakSelf loginView:nil handleError:error];
            } else {
                [weakSelf loginViewFetchedUserInfo:nil user:result];
            }
        }];
    }
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    DDLogInfo(@"Successful Facebook Login with ID: %@", user[@"id"]);
    DDLogInfo(@"Permissions on Session: %@", FBSession.activeSession.permissions);
    
    NSString *errMsg = nil;
    if (![FBSession.activeSession.permissions containsObject:@"email"]) {
        errMsg = @"You must provide your email address to continue with the login process.";
    } else if (![FBSession.activeSession.permissions containsObject:@"user_birthday"]) {
        errMsg = @"You must provide your birth date to continue with the login process.";
    }
    
    if (errMsg) {
        [RMessage showErrorMessageWithTitle:errMsg];
        
        _onboardingController.shouldRerequestPermissions = YES;
        
        [self closeAction];
        
        return;
    }
    
    [self showProgressHUDWithStatus:@"Logging In..."];
    
    NSDate *dateOfBirth = [CLDateHelper dateFromStringDate:user[@"birthday"]
                                                 formatter:kCLDateFormatterMonthDayYear];
    
    if ( !user[@"gender"] || !dateOfBirth ) {
        [RMessage showErrorMessageWithTitle:@"Your birthday or gender information is missing from your Facebook profile and will appear on Partake with the default setting. You will be unable to see activities created by other users until you update your Facebook profile."];
    }
    
    NSNumber *age       = @([dateOfBirth yearsAgo]);
    
    NSString *bio       = ([[((NSDictionary *)user) allKeys] containsObject:@"bio"]) ? user[@"bio"] : @"";
    
    [[CLApiClient sharedInstance] loginWithFbId:user[@"id"]
                                        fbToken:[FBSession activeSession].accessTokenData.accessToken
                                      firstName:user[@"first_name"]
                                       lastName:user[@"last_name"]
                                          email:user[@"email"]
                                         gender:user[@"gender"]
                                            age:[age stringValue]
                                   successBlock:^(BOOL isNewUser, NSArray *result) {
                                       
                                       DDLogInfo(@"Successful Partake Login");
                                       
                                       [self dismissProgressHUD];
                                       
                                       if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                                           [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                                           [CLLocationManagerController sharedInstance].wdelegate = self;
                                           [[CLLocationManagerController sharedInstance] startNotify];
                                       } else {
                                           [self warnUserAndGoToNextPage];
                                       }
                                       
                                       // save first 6 profile photos as default
                                       if (isNewUser) {
                                           [self saveUserProfileDefaultsFromFacebook:bio];
                                       }
                                       
                                   } failureBlock:^(NSError *error) {
                                       
                                       DDLogError(@"Error: %@", error.description);
                                       
                                       [RMessage showErrorMessageWithTitle:@"Oh no! Something went wrong!"];
                                       
                                       [FBSession.activeSession closeAndClearTokenInformation];
                                       
                                       [self dismissProgressHUD];
                                       
                                       [self closeAction];
                                       
                                   }];
}
*/
- (void)warnUserAndGoToNextPage {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please enable location in the settings!" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self askForNotificationPermission];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)askForNotificationPermission {

    [self dismissViewControllerAnimated:NO completion:^{
    
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:
             [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)];
        }

    }];
}
/*
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    DDLogError(@"Error: %@", error.fberrorUserMessage);
    
    [RMessage showErrorMessageWithTitle:@"Could not connect to Facebook. Please try again."];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [self closeAction];
}
*/
- (IBAction)privacyPolicyAction:(id)sender {
    
    UIStoryboard *storyboard   = [UIStoryboard storyboardWithName:@"CLSettingsViewController" bundle:nil];
    CLWebViewController *webVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([CLWebViewController class])];
    
    webVC.title                            = @"Privacy Policy";
    webVC.URL                              = kCLPartakePrivacyPolicyPageURL;
    webVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(closeAction)];
    
    CLNavigationController *navigationController = [[CLNavigationController alloc] initWithRootViewController:webVC];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveUserProfileDefaultsFromFacebook:(NSString *)bio {
    [CLFacebookHelper getUserProfilePhotosWithCompletion:^(NSArray *photos) {
        
        if (photos.count) {
            
            NSMutableArray *pictures = [NSMutableArray array];
            for (int i = 0; i < MIN(photos.count, 6); i++) {
                CLProfilePhoto *profilePhotoObject = photos[i];
                [pictures addObject:profilePhotoObject.source];
            }
            
//            [self uploadPhotosToS3:photos successBlock:nil];
            
            
            
            [[CLApiClient sharedInstance] editUserProfileAboutMe:bio
                                                        Pictures:pictures
                                                    successBlock:^(NSArray *results) {
                                                        
                                                        DDLogDebug(@"Success saving user profile photo URLs to DB - %@", results);
                                                        
                                                    } failureBlock:^(NSError *error) {
                                                        
                                                        DDLogError(@"Error saving user profile photo URLs to DB - %@", error.userInfo[@"error"]);
                                                        
                                                    }];
        }
        
    }];
}


#pragma mark - CLLocationManagerControllerDelegate

- (void)locationManagerController:(CLLocationManagerController *)manager didFailWithError:(NSError *)error {
    
}

- (void)locationManagerDidChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self askForNotificationPermission];
    } else {
        [self warnUserAndGoToNextPage];
    }
    
    NSLog(@"Status - %d", status);
}

- (void)locationManagerDidUpdateLocations {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self askForNotificationPermission];
    } else {
        [self warnUserAndGoToNextPage];
    }
}


- (void)uploadPhotosToS3:(NSArray *)photos successBlock:(void (^)(NSError* error))completion {
    // Define errors to be processed when everything is complete.
    // One error per service; in this example we'll have two
    //__block NSError *uploadError = nil;
    
    // Create the dispatch group
//    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    NSDate *methodStart = [NSDate date];
    
    for (NSUInteger i = 0; i < MIN(photos.count, 6); i++) {
        
        //CLProfilePhoto *profilePhotoObject = photos[i];
        
//        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePhotoObject.source]];

        
        // Start the first service
//        dispatch_group_enter(dispatchGroup);
//        [ startWithCompletion:^(ConfigResponse *results, NSError* error) {
//            uploadError = error;
//            dispatch_group_leave(dispatchGroup);
//        }];
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);
    
//    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(),^{
//        completion(uploadError);
//    });
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
