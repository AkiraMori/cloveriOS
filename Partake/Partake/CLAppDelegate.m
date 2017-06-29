//
//  AppDelegate.m
//  Partake
//
//  Created by Pablo Episcopo on 2/9/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <ShareKit/SHKConfiguration.h>
#import <Quickblox/Quickblox.h>
#import "CLShareKitConfigurator.h"
#import "CLAnalyticsHelper.h"

#import "CLHomeViewController.h"
#import "CLNavigationController.h"

#import "MTZWhatsNew.h"
#import "SDImageCache.h"
#import "CLAppDelegate.h"
#import "CLStartupController.h"
#import "CLLoginViewController.h"
#import "CLSettingsManager.h"
#import "CLUser+ModelController.h"
#import "CLChatService.h"
#import "CLMessagesViewController.h"
#import "CLQuickBloxManager.h"
#import "CLOnboardingController.h"
//#import "SHKFacebook.h"
#import "CLFacebookHelper.h"
#import "NSDate+DateTools.h"
#import "CLDateHelper.h"


#ifdef DEVELOPMENT
#import "FLEXManager.h"
#endif

@interface CLAppDelegate ()
@property (strong, nonatomic) CLOnboardingController *onboardingController;
@end

@implementation CLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef DEVELOPMENT    
    [CLAnalyticsHelper startAnalytics];
#endif

#ifdef DEVELOPMENT
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    
    [imageCache clearMemory];
    [imageCache clearDisk];
#endif
    
#ifndef DEBUG
//    [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
#endif

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    
    [MTZWhatsNew handleWhatsNew:nil];
    
    [CLStartupController kickoffWithOptions:launchOptions];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    BOOL forceLogout = [[[NSUserDefaults standardUserDefaults] valueForKey:@"force_log_out_2"] boolValue];
    
    if (!forceLogout) {
        
        //[[FBSession         activeSession] closeAndClearTokenInformation];
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logOut];
        [[CLApiClient       sharedInstance].loggedUser removeFromDisk];
        [self showOnboarding];
        
        [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"force_log_out_2"];
        
    } else if (![CLSettingsManager sharedManager].didShowOnboarding) {
    
        [self showOnboarding];

    } else {

            if ([[CLApiClient sharedInstance] isLoggedIn]) {
       
                [self showTabBar];
            } else {
        
                [self showLogin];
                
            }

        /**
         *  Register for Apple Push Notification
         */
#ifdef __IPHONE_8_0
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
#else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)];
#endif
    }

    /**
     *  FLEX stuff
     */
#ifdef DEVELOPMENT
    UITapGestureRecognizer *sixTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSixFingerQuadrupleTap:)];
    
    sixTapGesture.numberOfTapsRequired = 3;
    
    [self.window addGestureRecognizer:sixTapGesture];
#endif
    
    DefaultSHKConfigurator *configurator = [[CLShareKitConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //[SHKFacebook handleDidBecomeActive]; adam

    if([FBSDKAccessToken currentAccessToken]) {
        [self.window.rootViewController showProgressHUDWithStatus:@"Logging In..."];
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
                                                    
                                                    [self.window.rootViewController dismissProgressHUD];
                                                    
                                                    [[CLAppDelegate sharedInstance] showTabBar];
                                                    
                                                    // save first 6 profile photos as default
                                                    if (isNewUser) {
                                                        [self saveUserProfileDefaultsFromFacebook:bio];
                                                    }
                                                    
                                                } failureBlock:^(NSError *error) {
                                                    
                                                    DDLogError(@"Error: %@", error.description);
                                                    
                                                    [RMessage showErrorMessageWithTitle:@"Oh no! Something went wrong!"];
                                                    
                                                    
                                                    [self.window.rootViewController dismissProgressHUD];
                                                    
                                                }];
                 
             }
             else
             {
                 NSLog(@"error : %@",error);
             }
         }];
    }
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

- (void)applicationWillTerminate:(UIApplication *)application {
    //[SHKFacebook handleWillTerminate];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
} 

#pragma mark - Push Notifications

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
    
    if (self.onboardingController) {
        [self.onboardingController gotoNextPage];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }

    completionHandler();
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [CLSettingsManager sharedManager].deviceToken = deviceToken;
    
    DDLogInfo(@"Success registering for remote notification: device token: %@", deviceToken);

    [self sendDeviceTokenToServer];
    [[CLQuickBloxManager sharedManager] sendDeviceTokenToQuickBlox];
    
    
    if (self.onboardingController && self.onboardingController.currentPage == 0) {
        [self.onboardingController gotoNextPage];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Error registering for remote notification - %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    if (application.applicationState == UIApplicationStateActive) {

//        if ([CLSettingsManager sharedManager].vibrationEnabled) {
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//        }
//        
//        if ([CLSettingsManager sharedManager].soundEnabled) {
//            AudioServicesPlaySystemSound(1000);
//        }
//        
//        if ([CLSettingsManager sharedManager].previewEnabled) {
//            [RMessage showNotificationWithTitle:userInfo[@"alert"]];
//        }
        
        NSDictionary *additionalInfo = userInfo[QBMPushMessageAdditionalInfoKey];
        
        if ([additionalInfo isKindOfClass:[NSDictionary class]] && additionalInfo[@"dialog"]) {
            NSString *dialogID = additionalInfo[@"dialog"];
            if (dialogID && ![dialogID isEqualToString:_currentDialogID]) {
                [RMessage showNotificationWithTitle:userInfo[@"aps"][@"alert"]];
            }
        }
    }
}

- (void)sendDeviceTokenToServer
{
    NSString *deviceToken = [CLSettingsManager sharedManager].deviceTokenString;
    
    if (!deviceToken) {
        return;
    }
    
    if ([[CLApiClient sharedInstance] isLoggedIn]) {
        
        [[CLApiClient sharedInstance] registerDeviceToken:deviceToken
                                              enableAlert:[CLSettingsManager sharedManager].pushAlertEnabled
                                             successBlock:^{
                                                 DDLogInfo(@"Success register device token: %@", deviceToken);
                                             } failureBlock:^(NSError *error) {
                                                 DDLogError(@"Error registering device token: %@", error);
                                             }];
        
    } else {
        
        [self performSelector:@selector(sendDeviceTokenToServer) withObject:nil afterDelay:5.f];
        
    }
}


#pragma mark - Private Methods

/**
 *  This method shows the login screen
 */
- (void)showLogin
{
    self.window.rootViewController = [self loadOnboardingController];
}

/**
 *  This method shows the tab bar screen
 */
- (void)showTabBar
{
    self.onboardingController = nil;
    self.window.rootViewController = [self loadTabBarController];
}

/**
 *  This method shows the onboarding screen
 */
- (void)showOnboarding
{
    self.window.rootViewController = [self loadOnboardingController];
}

/**
 *  This method returns an new instance of Login View Controller
 *
 *  @return CLLoginViewController instance
 */
- (CLLoginViewController *)loadLoginViewController
{
    NSString *className = NSStringFromClass([CLLoginViewController class]);
    
    return [[self loadStoryboardWithClassName:className] instantiateInitialViewController];
}

/**
 *  This method returns an new instance of Login View Controller
 *
 *  @return CLTabBarController instance
 */
- (CLTabBarController *)loadTabBarController
{
    NSString *className = NSStringFromClass([CLTabBarController class]);
    
    self.tabBarController = [[self loadStoryboardWithClassName:className] instantiateInitialViewController];
    
    [self.tabBarController view];
    
    return self.tabBarController;
}

/**
 *  This method returns an new instance of Onboarding View Controller
 *
 *  @return CLOnboardingController instance
 */
- (CLOnboardingController *)loadOnboardingController
{
    NSString *className = NSStringFromClass([CLOnboardingController class]);
    
    self.onboardingController = [[self loadStoryboardWithClassName:className] instantiateInitialViewController];
    
    [self.onboardingController view];
    
    return self.onboardingController;
}

/**
 *  This method returns an storyboard loaded from class name parameter
 *
 *  @param className Name of the class to load from storyboard
 *
 *  @return an storyboard loaded from class name parameter
 */
- (UIStoryboard *)loadStoryboardWithClassName:(NSString *)className
{
    return [UIStoryboard storyboardWithName:className
                                     bundle:[NSBundle mainBundle]];
}

/**
 *  This method make an instance of the application object itself
 *  that remains ever while the app is alive
 *
 *  @return an instance of the application
 */
+ (CLAppDelegate *)sharedInstance
{
    return [[UIApplication sharedApplication] delegate];
}

- (NSURL *)applicationDocumentsDirectory
{
    /**
     *  The directory the application uses to store the Core Data store file.
     *  This code uses a directory named "com.codigodelsur.partake.Partake" in the
     * application's documents directory.
     */
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#ifdef DEVELOPMENT

- (void)handleSixFingerQuadrupleTap:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateRecognized) {
        
        /**
         *  This could also live in a handler for a keyboard shortcut, debug menu item, etc.
         */
        [[FLEXManager sharedManager] showExplorer];
    }
}

#endif


#pragma mark - Chat

- (void)openChatScreenWithDialog:(QBChatDialog *)dialog
{
    if (!dialog || !dialog.ID) {
        return;
    }
    
    if (_currentDialogID) {
        return;
    }
    
    [[CLChatService sharedInstance] addDialogs:@[dialog]];
    
    CLMessagesViewController *messageVC = [[CLMessagesViewController alloc] init];
    
    messageVC.chatDialog = dialog;
        
    CLNavigationController *navVC = [[CLNavigationController alloc] initWithRootViewController:messageVC];
    [self.tabBarController presentViewController:navVC animated:YES completion:nil];
}


@end
