//
//  CLLoginViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLUser.h"
#import "CLDateHelper.h"
#import "CLAppDelegate.h"
#import "CLLoginViewController.h"
#import "CLFacebookHelper.h"
#import "CLUser+ModelController.h"
#import "CLWebViewController.h"
#import "NSDate+DateTools.h"

@interface CLLoginViewController () <FBSDKLoginButtonDelegate>

@property (weak, nonatomic) IBOutlet UIView      *infoView;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;

@end

@implementation CLLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.infoView.layer.cornerRadius = 3.f;
    
    self.facebookLoginButton.center             = self.view.center;
    self.facebookLoginButton.readPermissions = [CLFacebookHelper readPermissions];
    self.facebookLoginButton.publishPermissions = [CLFacebookHelper publishPermissions];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:YES];
}

#pragma mark - FBLoginButton Delegate Methods

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error
{
    if(error) {
        [RMessage showErrorMessageWithTitle:@"Could not connect to Facebook. Please try again."];
    }
    else if(result.isCancelled) {
        
    }
    else {
        if ([result.grantedPermissions containsObject:@"email"])
        {
            DDLogInfo(@"Permissions on Session: %@", result.grantedPermissions);
            [self getFBResult];
        }
    }
}

-(void)getFBResult
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        [self showProgressHUDWithStatus:@"Logging In..."];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, first_name, last_name, birthday, picture.type(large), email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id user, NSError *error) {
             if (!error)
             {
                 //NSLog(@"fb user info : %@",result);
                 DDLogInfo(@"Successful Facebook Login with ID: %@", user[@"id"]);
                 
                  
                 NSDate *dateOfBirth = [CLDateHelper dateFromStringDate:user[@"birthday"]
                  formatter:kCLDateFormatterMonthDayYear];
                  
                 NSNumber *age       = @([dateOfBirth yearsAgo]);
                  
                 NSString *bio       = ([[((NSDictionary *)user) allKeys] containsObject:@"bio"]) ? user[@"bio"] : @"";
                  
                 [[CLApiClient sharedInstance] loginWithFbId:user[@"id"]
                  fbToken:[[FBSDKAccessToken currentAccessToken] tokenString]
                  firstName:user[@"first_name"]
                  lastName:user[@"last_name"]
                  email:user[@"email"]
                  gender:user[@"gender"]
                  age:[age stringValue]
                  //                                        aboutMe:bio
                  successBlock:^(BOOL isNewUser, NSArray *result) {
                  
                  DDLogInfo(@"Successful Partake Login");
                  
                  [self dismissProgressHUD];
                  
                  [[CLAppDelegate sharedInstance] showTabBar];
                  
                  // save first 6 profile photos as default
                  if (isNewUser) {
                  [self saveUserProfileDefaultsFromFacebook:bio];
                  }
                  
                  } failureBlock:^(NSError *error) {
                  
                  DDLogError(@"Error: %@", error.description);
                  
                  [RMessage showErrorMessageWithTitle:@"Oh no! Something went wrong!"];
                  
                  
                  [self dismissProgressHUD];
                  
                  }];

             }
             else
             {
                 NSLog(@"error : %@",error);
             }
         }];
    }
}


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
            
            [[CLApiClient sharedInstance] editUserProfileAboutMe:bio
                                                        Pictures:pictures
                                                    successBlock:^(NSArray *results) {
                                                         
                                                        DDLogDebug(@"Success saving user profile photos - %@", results);
                                                        
                                                    } failureBlock:^(NSError *error) {
                                                         
                                                        DDLogError(@"Error saving user profile photos - %@", error.userInfo[@"error"]);
                                                         
                                                    }];
        }
        
    }];
}
@end
