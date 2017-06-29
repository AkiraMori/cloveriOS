//
//  CLChatService.h
//  Partake
//
//  Created by Maikel on 03/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>


@protocol CLChatServiceDelegate <NSObject>
- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message;
- (void)chatDidLogin;
@end

@interface CLChatService : NSObject

@property (readonly) BOOL isConnected;

@property (nonatomic, strong) NSMutableArray      *users;
@property (nonatomic, strong) NSMutableArray      *dialogs;
@property (nonatomic, strong) NSMutableDictionary *messages;

@property (weak) id<CLChatServiceDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)connect;
- (void)disconnect;

- (void)addUsers:(NSArray *)users;
- (QBUUser *)userWithID:(NSInteger)userID;
- (QBUUser *)userWithFacebookID:(NSString *)facebookID;

- (void)addDialogs:(NSArray *)dialogs;
- (QBChatDialog *)dialogWithID:(NSString *)dialogID;
- (QBChatDialog *)dialogWithRecipientID:(NSInteger)recipientID;
- (QBChatDialog *)dialogWithRecipientFacebookID:(NSString *)facebookID;

- (NSMutableArray *)messagsForDialogId:(NSString *)dialogId;
- (void)addMessages:(NSArray *)messages forDialogId:(NSString *)dialogId;
- (void)addMessage:(QBChatMessage *)message forDialogId:(NSString *)dialogId;

- (void)getUsersWithFacebookIDs:(NSArray *)facebookIDs withCompletion:(void(^)(NSError *, NSArray *))completionBlock;

- (void)createChatDialogWithUser:(NSInteger)userId
                       requestId:(NSString *)requestId
                      activityId:(NSString *)activityId
                    activityName:(NSString *)activityName
                    activityType:(NSString *)activityType
                  withCompletion:(void(^)(NSError *error, NSArray *results))completionBlock;

- (void)requestDialogsWithCompletionBlock:(void(^)())completionBlock;
- (void)requestDialogUpdateWithId:(NSString *)dialogId completionBlock:(void(^)())completionBlock;

- (void)deleteDialog:(QBChatDialog *)dialog
          completion:(void(^)(NSError *error))completionBlock;

- (BOOL)sendMessage:(NSString *)messageText toDialog:(QBChatDialog *)dialog;
- (BOOL)sendMediaMessage:(NSString *)mediaType
                  fileID:(NSInteger)fileID
                toDialog:(QBChatDialog *)dialog;

- (void)sortDialogs;

@end