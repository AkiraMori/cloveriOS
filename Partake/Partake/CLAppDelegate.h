//
//  AppDelegate.h
//  Partake
//
//  Created by Pablo Episcopo on 2/9/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "CLTabBarController.h"

@class QBUUser, QBChatDialog;

@interface CLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow           *window;
@property (strong, nonatomic) CLTabBarController *tabBarController;

@property (copy, nonatomic) NSString *currentDialogID;

+ (CLAppDelegate *)sharedInstance;

- (void)sendDeviceTokenToServer;

- (NSURL *)applicationDocumentsDirectory;

- (void)showLogin;
- (void)showTabBar;

- (void)openChatScreenWithDialog:(QBChatDialog *)dialog;

@end

