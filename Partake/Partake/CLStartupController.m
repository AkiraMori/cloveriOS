//
//  StartupController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "CLConstants.h"
#import "SDImageCache.h"
#import "CLStartupController.h"
#import "FileFunctionLevelFormatter.h"
#import "CLAppearanceHelper.h"

@implementation CLStartupController

+ (void)kickoffWithOptions:(NSDictionary *)options
{
    setenv("XcodeColors", "YES", 0);
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [[DDTTYLogger sharedInstance] setLogFormatter:[FileFunctionLevelFormatter new]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
#if TARGET_OS_IPHONE
    UIColor *errorColor   = [UIColor colorWithRed:0.93 green:0.4 blue:0.32 alpha:1];
    UIColor *debugColor   = [UIColor colorWithRed:0.78 green:0.8 blue:0.8 alpha:1];
    UIColor *warningColor = [UIColor colorWithRed:1 green:0.71 blue:0.31 alpha:1];
    UIColor *infoColor    = [UIColor colorWithRed:0.27 green:0.65 blue:0.78 alpha:1];
    UIColor *verboseColor = [UIColor colorWithRed:0.75 green:0.56 blue:0.74 alpha:1];
#endif
    
    [[DDTTYLogger sharedInstance] setForegroundColor:debugColor
                                     backgroundColor:nil
                                             forFlag:DDLogFlagDebug];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:errorColor
                                     backgroundColor:nil
                                             forFlag:DDLogFlagError];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:warningColor
                                     backgroundColor:nil
                                             forFlag:DDLogFlagWarning];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:infoColor
                                     backgroundColor:nil
                                             forFlag:DDLogFlagInfo];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:verboseColor
                                     backgroundColor:nil
                                             forFlag:DDLogFlagVerbose];
    
    DDLogError(@"ERROR");
    DDLogDebug(@"DEBUGGING");
    DDLogWarn(@"WARNING");
    DDLogInfo(@"INFO");
    DDLogVerbose(@"VERBOSE");
    
    [self setupDatabase];
    [self setupRestkit];
    
    [CLAppearanceHelper setupRMessageViewAppearance];
}

#pragma mark - Setup DB

+ (void)setupDatabase
{
    [CLDatabaseManager sharedInstance];
}

#pragma mark - Setup Networking

+ (void)setupRestkit
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    RKLogConfigureByName("RestKit/Network*", RKLogLevelError);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelError);
    
    [CLApiClient sharedInstance];
}

//    *** THIS SHOULD BE AT THE END OF setupRestkit method ***
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self initialSeed];
//    });

//+ (void)initialSeed
//{
//    /**
//     *  Persistent Guest Token per Installation.
//     */
//    CLPerson *guest = [CLCoreDataFactories guestPerson];
//
//    [[CLApiClient sharedInstance] setAuthGuestToken:guest.personToken];
//}

//+ (void)setupNotifications:(UIApplication *)application
//{
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                    UIUserNotificationTypeBadge |
//                                                    UIUserNotificationTypeSound);
//
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                             categories:nil];
//
//    [application registerUserNotificationSettings:settings];
//    [application registerForRemoteNotifications];
//}

@end
