//
//  CLChatService.m
//  Partake
//
//  Created by Maikel on 03/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLChatService.h"
#import "CLConstants.h"
#import "RMessage+PartakeAdditions.h"
#import "CLSettingsManager.h"
#import "CLQuickBloxManager.h"


typedef void(^CompletionBlock)();
typedef void(^CompletionBlockWithResult)(NSArray *);


@interface CLChatService () <QBChatDelegate>
@property (copy) CompletionBlock loginCompletionBlock;
@property (copy) CompletionBlock getDialogsCompletionBlock;
@end


@implementation CLChatService

#pragma mark
#pragma mark Init

+ (instancetype)sharedInstance
{
    static id instance_ = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    
    return instance_;
}

- (id)init
{
    self = [super init];
    
    if (self){
        [[QBChat instance] addDelegate:self];
        
        [self setupChatConfiguration];
        
        [self registerNotifications];
        
        self.messages = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    [self unregisterNotifications];
}

- (void)setupChatConfiguration
{
    [QBSettings setAutoReconnectEnabled   :YES];
    [QBSettings setStreamResumptionEnabled:YES];
    [QBSettings setKeepAliveInterval      :30];
}

- (void)registerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(connect)    name:UIApplicationWillEnterForegroundNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(disconnect) name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [notificationCenter addObserver:self selector:@selector(disconnect) name:UIApplicationWillTerminateNotification       object:nil];
}

- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark
#pragma mark Login/Logout

- (void)connect
{
    QBUUser *currentUser = [CLQuickBloxManager sharedManager].currentUser;
    
    if (currentUser) {
        currentUser.password = [QBSession currentSession].sessionDetails.token;

        [[QBChat instance] connectWithUser:currentUser completion:nil];
    }
}

- (void)disconnect
{
    [[QBChat instance] disconnectWithCompletionBlock:nil];
}

- (BOOL)isConnected
{
    return [QBChat instance].isConnected;
}


#pragma mark
#pragma mark Send message

- (BOOL)sendMessage:(NSString *)messageText toDialog:(QBChatDialog *)dialog
{
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = messageText;
    [message setCustomParameters:[@{@"save_to_history": @YES} mutableCopy]];
    
    if(dialog.type == QBChatDialogTypePrivate){
        // save message to inmemory db
        [self addMessage:message forDialogId:dialog.ID];
    }
    
    // update dialog
    dialog.lastMessageUserID = [QBSession currentSession].currentUser.ID;
    dialog.lastMessageText = messageText;
    dialog.lastMessageDate = message.dateSent;
    
    [self sendPushMessage:[NSString stringWithFormat:@"%@: %@", [CLApiClient sharedInstance].loggedUser.firstName, messageText]
                 toDialog:dialog];
    
    // send a message
    [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        NSLog(@"Error sending messsage - %@", error);
    }];
    
    return YES;
}

- (BOOL)sendMediaMessage:(NSString *)mediaType
                  fileID:(NSInteger)fileID
                toDialog:(QBChatDialog *)dialog
{
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text           = @"Posted an image";
    
    QBChatAttachment *attachment = QBChatAttachment.new;
    attachment.type              = mediaType;
    attachment.ID                = [NSString stringWithFormat:@"%lu", fileID]; // use 'ID' property to store an ID of a file in Content or CustomObjects modules

    [message setAttachments:@[attachment]];
    [message setCustomParameters:[@{@"save_to_history": @YES} mutableCopy]];
    
    if(dialog.type == QBChatDialogTypePrivate){
        // save message to inmemory db
        [self addMessage:message forDialogId:dialog.ID];
    }
    
    // update dialog
    dialog.lastMessageUserID = [QBSession currentSession].currentUser.ID;
    dialog.lastMessageText = @"Posted an image";
    dialog.lastMessageDate = message.dateSent;
    
    [self sendPushMessage:[NSString stringWithFormat:@"%@ posted a new image", [CLApiClient sharedInstance].loggedUser.firstName]
                 toDialog:dialog];
    
    // send a message
    [dialog sendMessage:message completionBlock:nil];
    
    return YES;
}

- (void)sendPushMessage:(NSString *)message
               toDialog:(QBChatDialog *)dialog
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
    [aps setObject:message forKey:QBMPushMessageAlertKey];
    [payload setObject:aps forKey:QBMPushMessageApsKey];
    [payload setObject:@{@"dialog" : dialog.ID} forKey:QBMPushMessageAdditionalInfoKey];
    
    QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
    [QBRequest sendPush:pushMessage toUsers:[NSString stringWithFormat:@"%lu", (unsigned long)dialog.recipientID] successBlock:^(QBResponse *response, QBMEvent *event) {
        // Successful response with event
        DDLogInfo(@"Success sending push notification");
    } errorBlock:^(QBError *error) {
        // Handle error
        DDLogError(@"Sending push notification failed");
    }];
}

#pragma mark - 
#pragma mark Create dialogs

- (void)createChatDialogWithUser:(NSInteger)userId
                       requestId:(NSString *)requestId
                      activityId:(NSString *)activityId
                    activityName:(NSString *)activityName
                    activityType:(NSString *)activityType
                  withCompletion:(void(^)(NSError *error, NSArray *results))completionBlock
{
    NSAssert(userId,       @"You must provide user id to chat with.");
    NSAssert(requestId,    @"You must provide request id in order to create chat dialog");
    NSAssert(activityId,   @"You must provide activity id in order to create chat dialog");
    NSAssert(activityName, @"You must provide activity name in order to create chat dialog");
    NSAssert(activityType, @"You must provide activity type in order to create chat dialog");

    // should not try to create dialog when there's no dialogs synced. (to avoid duplicate)
    [self requestDialogsWithCompletionBlock:^{
        
        // if there's already a dialog with the user, just return it
        QBChatDialog *dialog = [self dialogWithRecipientID:userId];
        if (dialog) {
            
            if (completionBlock) {
                completionBlock(nil, @[dialog]);
            }
        
            if (![requestId isEqualToString:dialog.data[@"request_id"]]) {
                [self updateDialog:dialog
                         requestId:requestId
                        activityId:activityId
                      activityName:activityName
                      activityType:activityType];
            }
            
        } else {
            
            dialog             = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
            dialog.occupantIDs = @[@(userId)];
            dialog.data        = @{
                                   @"class_name"    : @"dialog_details",
                                   @"request_id"    : requestId,
                                   @"activity_id"   : activityId,
                                   @"activity_name" : activityName,
                                   @"activity_type" : activityType
                                   };
            
            [QBRequest createDialog:dialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                
                DDLogInfo(@"Success creating dialog with user - %d", (int)userId);
                
                createdDialog.data = dialog.data;
                [self.dialogs addObject:createdDialog];
                
                if (completionBlock) {
                    completionBlock(nil, @[createdDialog]);
                }
                
                [self updateDialog:createdDialog
                         requestId:requestId
                        activityId:activityId
                      activityName:activityName
                      activityType:activityType];
                
            } errorBlock:^(QBResponse *response) {
                
                DDLogError(@"Error creating dialog with user - %d\nError - %@", (int)userId, response.error.error);
                
                if (completionBlock) {
                    completionBlock(response.error.error, nil);
                }
                
            }];

        }
        
    }];
}

- (void)deleteDialog:(QBChatDialog *)dialog
          completion:(void(^)(NSError *error))completionBlock
{
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:dialog.ID]
                        forAllUsers:NO successBlock:^(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs
                                                      ) {
                            
                            DDLogInfo(@"Success deleting a chat dialog - %@", response);
                            
                            [self.dialogs removeObject:dialog];
                            
                            if (completionBlock) {
                                completionBlock(nil);
                            }
                            
                        } errorBlock:^(QBResponse *response) {
                            
                            DDLogError(@"Error deleting a chat dialog - %@", response);
                            
                            if (completionBlock) {
                                completionBlock(response.error.error);
                            }
                            
                        }];
}

- (void)updateDialog:(QBChatDialog *)dialog
           requestId:(NSString *)requestId
          activityId:(NSString *)activityId
        activityName:(NSString *)activityName
        activityType:(NSString *)activityType
{
    dialog.data = @{
                    @"class_name"    : @"dialog_details",
                    @"request_id"    : requestId,
                    @"activity_id"   : activityId,
                    @"activity_name" : activityName,
                    @"activity_type" : activityType
                    };
    
    [QBRequest updateDialog:dialog successBlock:^(QBResponse *response, QBChatDialog *updatedDialog) {
        
        DDLogInfo(@"Success updating dialog");
        
        [self.dialogs removeObject:dialog];
        [self.dialogs addObject:updatedDialog];
        
    } errorBlock:^(QBResponse *response) {
        
        DDLogError(@"Error updating dialog - %@", response.error);
        
    }];
}

#pragma mark Request dialogs

- (void)requestDialogsWithCompletionBlock:(void(^)())completionBlock
{
    self.getDialogsCompletionBlock = completionBlock;
    NSMutableDictionary *extendedRequest = @{@"type" : @(QBChatDialogTypePrivate)}.mutableCopy;

    QBResponsePage *pageDialogs = [QBResponsePage responsePageWithLimit:100 skip:0];
    [QBRequest dialogsForPage:pageDialogs extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *pageResponseDialogs) {
        
        // save dialogs in memory
        //
        self.dialogs = [NSMutableArray arrayWithArray:dialogObjects];
        
        // join all group dialogs
        //
        [self joinAllDialogs];
        
        // get dialogs' users
        //
        if([dialogsUsersIDs allObjects].count == 0){
            if(self.getDialogsCompletionBlock != nil){
                self.getDialogsCompletionBlock();
                self.getDialogsCompletionBlock = nil;
            }
        }else{
            QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
            [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:page
                       successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                           
                           if(page.totalEntries > page.perPage){
                               // TODO: implement pagination
                               
                           }
                           
                           self.users = [users mutableCopy];
                           
                           if(self.getDialogsCompletionBlock != nil){
                               self.getDialogsCompletionBlock();
                               self.getDialogsCompletionBlock = nil;
                           }
                           
                       } errorBlock:nil];
        }
        
    } errorBlock:nil];
}

- (void)requestDialogUpdateWithId:(NSString *)dialogId completionBlock:(void(^)())completionBlock{
    self.getDialogsCompletionBlock = completionBlock;
    
    [QBRequest dialogsForPage:nil
              extendedRequest:@{@"_id": dialogId}
                 successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
                     
                     BOOL found = NO;
                     NSArray *dialogsCopy = [NSArray arrayWithArray:self.dialogs];
                     for(QBChatDialog *dialog in dialogsCopy){
                         if([dialog.ID isEqualToString:dialogId]){
                             [self.dialogs removeObject:dialog];
                             found = YES;
                             break;
                         }
                     }
                     
                     QBChatDialog *updatedDialog = dialogObjects.firstObject;
                     [self.dialogs insertObject:updatedDialog atIndex:0];
                     
                     if(!found){
                         [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:nil
                                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                                        
                                        [_users addObjectsFromArray:users];

                                        self.users = _users;
                                        
                                        if(self.getDialogsCompletionBlock != nil){
                                            self.getDialogsCompletionBlock();
                                            self.getDialogsCompletionBlock = nil;
                                        }
                                        
                                    } errorBlock:nil];
                     }else{
                         if(self.getDialogsCompletionBlock != nil){
                             self.getDialogsCompletionBlock();
                             self.getDialogsCompletionBlock = nil;
                         }
                     }
                     
                 } errorBlock:nil];
}

- (void)joinAllDialogs
{
    for(QBChatDialog *dialog in self.dialogs){
        if(dialog.type != QBChatDialogTypePrivate){
            [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
                NSLog(@"Dialog joined");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationGroupDialogJoined object:nil];
            }];
        }
    }
}

- (void)getUsersWithFacebookIDs:(NSArray *)facebookIDs withCompletion:(void(^)(NSError *, NSArray *))completionBlock {
    
    [QBRequest usersWithFacebookIDs:facebookIDs page:nil successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        
        [self addUsers:users];
        
        if (completionBlock) {
            completionBlock(response.error.error, users);
        }
        
    } errorBlock:^(QBResponse *response) {

        if (completionBlock) {
            completionBlock(response.error.error, nil);
        }
        
    }];
}

#pragma mark
#pragma mark Local storage

- (QBUUser *)userWithID:(NSInteger)userID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", @(userID)];
    return [_users filteredArrayUsingPredicate:predicate].lastObject;
}

- (QBUUser *)userWithFacebookID:(NSString *)facebookID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID LIKE[cd] %@", facebookID];
    return [_users filteredArrayUsingPredicate:predicate].lastObject;
}

- (QBChatDialog *)dialogWithID:(NSString *)dialogID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID LIKE[cd] %@", dialogID];
    return [_dialogs filteredArrayUsingPredicate:predicate].lastObject;
}

- (QBChatDialog *)dialogWithRecipientID:(NSInteger)recipientID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recipientID == %@", @(recipientID)];
    return [_dialogs filteredArrayUsingPredicate:predicate].lastObject;
}

- (QBChatDialog *)dialogWithRecipientFacebookID:(NSString *)facebookID
{
    QBUUser *recipient = [self userWithFacebookID:facebookID];
    if (recipient) {
        return [self dialogWithRecipientID:recipient.ID];
    }
    
    return nil;
}

- (void)addUsers:(NSArray *)users
{
    if (!_users) {
        _users = [users mutableCopy];
        return;
    }
    
    NSMutableArray *userIds = [NSMutableArray array];
    for (QBUUser *user in users) {
        [userIds addObject:@(user.ID)];
    }
    
    NSArray *usersToDelete = [_users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID IN %@", userIds]];
    [_users removeObjectsInArray:usersToDelete];
    [_users addObjectsFromArray:users];
}

- (void)addDialogs:(NSArray *)dialogs
{
    if (!_dialogs) {
        _dialogs = [dialogs mutableCopy];
        return;
    }
    
    NSMutableArray *dialogIds = [NSMutableArray array];
    for (QBChatDialog *dialog in dialogs) {
        [dialogIds addObject:dialog.ID];
    }
    
    NSArray *dialogsToDelete = [_dialogs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID IN %@", dialogIds]];
    [_dialogs removeObjectsInArray:dialogsToDelete];
    [_dialogs addObjectsFromArray:dialogs];
}

- (NSMutableArray *)messagsForDialogId:(NSString *)dialogId
{
    if (!dialogId.length) {
        return nil;
    }
    NSMutableArray *messages = [self.messages objectForKey:dialogId];
    if(messages == nil){
        messages = [NSMutableArray array];
        [self.messages setObject:messages forKey:dialogId];
    }
    
    return messages;
}

- (void)addMessages:(NSArray *)messages forDialogId:(NSString *)dialogId
{
    if (!dialogId.length) {
        return;
    }
    
    NSMutableArray *messagesArray = [self.messages objectForKey:dialogId];
    if(messagesArray != nil){
    
        NSMutableArray *messageIds = [NSMutableArray array];
        for (QBChatMessage *message in messages) {
            [messageIds addObject:message.ID];
        }
        
        NSArray *messagesToDelete = [messagesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID IN[cd] %@", messageIds]];
        
        [messagesArray removeObjectsInArray:messagesToDelete];
        [messagesArray addObjectsFromArray:messages];
        
        [self sortMessages:messagesArray];
    }else{
        messagesArray = [messages mutableCopy];
        
        [self sortMessages:messagesArray];
        
        [self.messages setObject:messagesArray forKey:dialogId];
    }
}

- (void)addMessage:(QBChatMessage *)message forDialogId:(NSString *)dialogId
{
    if (!dialogId.length) {
        return;
    }
    
    if (message) {
        [self addMessages:@[message] forDialogId:dialogId];
    }
}


#pragma mark
#pragma mark QBChatDelegate

- (void)chatDidReconnect
{
    // reconnected to chat
    if(self.dialogs.count > 0){
        // join all group dialogs
        //
        [self joinAllDialogs];
        
#if DEVELOPMENT
        [RMessage showNotificationWithTitle:@"Alert"
                                    subtitle:@"You are online again!"
                                        type:RMessageTypeWarning
                              customTypeName:nil
                                    callback:nil];
#endif
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationChatDidReconnect object:nil];
    }
    
    if([self.delegate respondsToSelector:@selector(chatDidLogin)]){
        [self.delegate chatDidLogin];
    }
    
    NSLog(@"chatDidLogin");
}

- (void)chatDidConnect
{
    NSLog(@"chatDidConnect");
}

- (void)chatDidAccidentallyDisconnect
{
    NSLog(@"chatDidAccidentallyDisconnect");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationChatDidAccidentallyDisconnect object:nil];
    
#if DEVELOPMENT
    [RMessage showNotificationWithTitle:@"Alert"
                                subtitle:@"You have lost the Internet connection"
                                    type:RMessageTypeWarning
                          customTypeName:nil
                                callback:nil];
#endif
    
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    [self processMessage:message];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID
{
    [self processMessage:message];
}

- (void)processMessage:(QBChatMessage *)message{
    NSString *dialogId = message.dialogID;
    
    // save message to local storage
    //
    [self addMessage:message forDialogId:dialogId];
    
    // update dialogs in a local storage
    //
    QBChatDialog *dialog = [self dialogWithID:dialogId];
    if(dialog != nil){
        dialog.lastMessageUserID = message.senderID;
        dialog.lastMessageText = message.text;
        dialog.lastMessageDate = message.dateSent;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationDialogsUpdated object:nil];
    }else{
        [self requestDialogUpdateWithId:dialogId completionBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationDialogsUpdated object:nil];
        }];
    }
    
    // notify observers
    BOOL processed = NO;
    if ([self.delegate respondsToSelector:@selector(chatDidReceiveMessage:)]){
        processed = [self.delegate chatDidReceiveMessage:message];
    }
    
    if (!processed) {
        if ([CLSettingsManager sharedManager].previewEnabled){
            NSString *newMessage = message.text;
            
            [RMessage showNotificationWithTitle:@"New message"
                                        subtitle:newMessage
                                            type:RMessageTypeNormal
                                  customTypeName:nil
                                        callback:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationDidReadMessage object:nil];
    }
}


#pragma mark
#pragma mark Utils

- (void)sortDialogs
{
    [self.dialogs sortUsingComparator:^NSComparisonResult(QBChatDialog *obj1, QBChatDialog *obj2) {
        NSDate *first = obj1.lastMessageDate;
        NSDate *second = obj2.lastMessageDate;
        return [second compare:first];
    }];
}

- (void)sortMessages:(NSMutableArray *)messages
{
    [messages sortUsingComparator:^NSComparisonResult(QBChatMessage *obj1, QBChatMessage *obj2) {
        NSDate *first = obj2.dateSent;
        NSDate *second = obj1.dateSent;
        return [second compare:first];
    }];
}

@end
