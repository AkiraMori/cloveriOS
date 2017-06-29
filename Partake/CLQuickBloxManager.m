//
//  CLQuickBloxManager.m
//  Partake
//
//  Created by Maikel on 03/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLQuickBloxManager.h"
#import "CLConstants.h"
#import "CLSettingsManager.h"
#import "CLChatService.h"


@implementation CLQuickBloxManager

#pragma mark - Singleton Methods

+ (id)sharedManager {
    static CLQuickBloxManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Manager Lifecycle Methods

- (id)init {
    self = [super init];
    
    if (self) {
        [self setupQuickBloxConfiguration];
    }
    
    return self;
}

- (void)setupQuickBloxConfiguration
{
    [QBSettings setApplicationID:kCLQuickBloxApplicationId];
    [QBSettings setAuthKey      :kCLQuickBloxServiceKey];
    [QBSettings setAuthSecret   :kCLQuickBloxServiceSecret];
    [QBSettings setAccountKey   :kCLQuickBloxAccountKey];
    [QBSettings setLogLevel     :QBLogLevelNothing];
}


#pragma mark - PUBLIC

- (void)loginQuickBlox:(void(^)(NSError *error))completion
{
    NSString *accessToken = [CLApiClient sharedInstance].loggedUser.fbUserToken;
    if (!accessToken.length) {
        return;
    }
    [QBRequest logInWithSocialProvider:@"facebook" accessToken:accessToken accessTokenSecret:nil successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        DDLogInfo(@"QuickBlox login success - %@", response);

        _currentUser = user;
        
        [self sendDeviceTokenToQuickBlox];
        
        if (completion) {
            completion(nil);
        }
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        DDLogError(@"Error logging in QuickBlox chat - %@", response.error);
        
        if (completion) {
            completion(response.error.error);
        }
    }];
}

- (void)sendDeviceTokenToQuickBlox
{
    NSData *deviceToken = [CLSettingsManager sharedManager].deviceToken;
    
    if (!deviceToken) {
        return;
    }
    
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [QBRequest registerSubscriptionForDeviceToken:deviceToken uniqueDeviceIdentifier:deviceIdentifier
                                     successBlock:^(QBResponse *response, NSArray *subscriptions) {
                                         DDLogInfo(@"Success registering device token to QuickBlox - %@", response);
                                     } errorBlock:^(QBError *error) {
                                         DDLogError(@"Error registering device token to QuickBlox - %@", error.error);
                                     }];
}

- (void)getTotalUnreadMessagesCountWithCompletionBlock:(void(^)(NSUInteger count, NSError *error))completion
{
    if (!_currentUser) {
        if (completion) {
            completion(-1, [self errorWithCode:400 Message:@"Not logged In"]);
        }
        
        return;
    }
    
    [QBRequest totalUnreadMessageCountForDialogsWithIDs:[NSSet set] successBlock:^(QBResponse * _Nonnull response, NSUInteger count, NSDictionary<NSString *,id> * _Nullable dialogs) {
       
        if (completion) {
            completion(count, nil);
        }
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        if (completion) {
            completion(-1, response.error.error);
        }
    }];
}


#pragma mark - Misc

- (NSError *)errorWithCode:(NSInteger)errorCode
                   Message:(NSString *)errMsg
{
    return [NSError errorWithDomain:kCLQuickBloxErrorDomain
                               code:errorCode
                           userInfo:@{
                                      @"error" : errMsg
                                      }];
}

@end
