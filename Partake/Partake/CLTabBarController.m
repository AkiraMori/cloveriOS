//
//  CLTabBarController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTabBar.h"
#import "CLTabBarController.h"
#import "CLChatViewController.h"
#import "CLSettingsViewController.h"
#import "CLRequestsViewController.h"
#import "CLCreateActivityViewController.h"
#import "CLQuickBloxManager.h"
#import "CLAnalyticsHelper.h"


@interface CLTabBarController ()

@property (strong, nonatomic) CLHomeViewController           *homeViewController;
@property (strong, nonatomic) CLRequestsViewController       *requestsViewController;
@property (strong, nonatomic) CLChatViewController           *chatViewController;
@property (strong, nonatomic) CLCreateActivityViewController *createActivityViewController;
@property (strong, nonatomic) CLSettingsViewController       *settingsViewController;

@end

@implementation CLTabBarController

+ (CLTabBarController *)sharedInstance
{
    static CLTabBarController * instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CLTabBarController new];
    });
    
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.homeViewController           = [[UIStoryboard storyboardWithName:NSStringFromClass([CLHomeViewController class])
                                                                   bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    self.requestsViewController       = [[UIStoryboard storyboardWithName:NSStringFromClass([CLRequestsViewController class])
                                                                   bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    self.chatViewController           = [[UIStoryboard storyboardWithName:NSStringFromClass([CLChatViewController class])
                                                                   bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    self.createActivityViewController = [[UIStoryboard storyboardWithName:NSStringFromClass([CLCreateActivityViewController class])
                                                                   bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    self.settingsViewController       = [[UIStoryboard storyboardWithName:NSStringFromClass([CLSettingsViewController class])
                                                                   bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    self.homeViewController.tabBarItem.image           = [UIImage imageNamed:@"home"];
    self.requestsViewController.tabBarItem.image       = [UIImage imageNamed:@"requests"];
    self.chatViewController.tabBarItem.image           = [UIImage imageNamed:@"chat"];
    self.createActivityViewController.tabBarItem.image = [UIImage imageNamed:@"create-activity"];
    self.settingsViewController.tabBarItem.image       = [UIImage imageNamed:@"settings"];
    
    [self.homeViewController           view];
    [self.requestsViewController       view];
    [self.chatViewController           view];
    [self.createActivityViewController view];
    [self.settingsViewController       view];
    
    self.homeNavigationController           = [[CLNavigationController alloc] initWithRootViewController:self.homeViewController];
    self.requestsNavigationController       = [[CLNavigationController alloc] initWithRootViewController:self.requestsViewController];
    self.chatNavigationController           = [[CLNavigationController alloc] initWithRootViewController:self.chatViewController];
    self.createActivityNavigationController = [[CLNavigationController alloc] initWithRootViewController:self.createActivityViewController];
    self.settingsNavigationController       = [[CLNavigationController alloc] initWithRootViewController:self.settingsViewController];
    
    self.viewControllers = @[
                             self.homeNavigationController,
                             self.requestsNavigationController,
                             self.chatNavigationController,
                             self.createActivityNavigationController,
                             self.settingsNavigationController
                             ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageBadge) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRequestBadge:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageBadge) name:kCLNotificationDidReadMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRequestBadge:) name:kCLNotificationDidReadRequest object:nil];
    
    [self refreshRequestBadge:nil];
    
    [[CLQuickBloxManager sharedManager] loginQuickBlox:^(NSError *error) {
        if (!error) {
            [[CLChatService sharedInstance] connect];
            [self refreshMessageBadge];
        }
    }];
    
    [self configureFlurryAnalytics];
}

- (CLHomeViewController *)homeViewControllerSharedInstance
{
    return self.homeViewController;
}


#pragma mark - Badge

- (void)refreshMessageBadge {
    [[CLQuickBloxManager sharedManager] getTotalUnreadMessagesCountWithCompletionBlock:^(NSUInteger count, NSError *error) {
        if (error || count == -1) {
            DDLogInfo(@"Error getting unread messages count - %@", error);
        } else {
            self.chatViewController.tabBarItem.badgeValue = count ? [NSString stringWithFormat:@"%d", (int)count] : nil;
        }
    }];
}

- (void)refreshRequestBadge:(NSNotification *)aNotification {
    if ([UIApplication sharedApplication].applicationIconBadgeNumber) {
        self.requestsViewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", (int)[UIApplication sharedApplication].applicationIconBadgeNumber];
    } else {
        self.requestsViewController.tabBarItem.badgeValue = nil;
    }
    
    if (self.selectedIndex == 1) {
        [self resetRequestBadge:[UIApplicationDidBecomeActiveNotification isEqualToString:aNotification.name]];
    }
}

- (void)resetRequestBadge:(BOOL)delay {
    if (![UIApplication sharedApplication].applicationIconBadgeNumber) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay ? 1.f : 0.f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        self.requestsViewController.tabBarItem.badgeValue = nil;
    });
    
    [[CLApiClient sharedInstance] resetUserBadgeInBackground];
}


#pragma mark - Analytics

- (void)configureFlurryAnalytics
{
    [CLAnalyticsHelper logPageViewsWithRootController:self];
    
    CLLoggedUser *loggedUser = [CLApiClient sharedInstance].loggedUser;
    if (loggedUser) {
        [CLAnalyticsHelper logUserDetails:loggedUser];
    }
}
@end
