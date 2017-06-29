//
//  CLMessagesViewController.m
//  Partake
//
//  Created by Maikel on 04/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLMessagesViewController.h"
#import "CLSettingsManager.h"
#import "QBChatMessage+JSQMessageData.h"
#import "JSQMessages.h"
#import "CLChatService.h"
#import "UIColor+CloverAdditions.h"
#import "RMessage+PartakeAdditions.h"
#import "CLImageCache.h"
#import "CLAppDelegate.h"

@interface CLMessagesViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLChatServiceDelegate>

@property (strong, nonatomic) QBUUser *recipient;

@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *downloadingMediaIds;
@end


@implementation CLMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recipient = [[CLChatService sharedInstance] userWithID:_chatDialog.recipientID];

    self.title = [_recipient.fullName componentsSeparatedByString:@" "].firstObject;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(closeAction)];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(loadMoreAction) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = [NSString stringWithFormat:@"%lu", [QBChat instance].currentUser.ID];
    self.senderDisplayName = @"You";
    
    /**
     *  Initialize styling data
     */
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage imageNamed:@"bubble_bg"]
                                                                                                         capInsets:UIEdgeInsetsMake(40.f, 5.f, 5.f, 10.f)];
    self.outgoingBubbleImageData = [bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor primaryBrandColor]];
    self.incomingBubbleImageData = [bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor secondaryBrandColor]];
    
    /**
     *  Set a maximum height for the input toolbar
     */
    self.inputToolbar.maximumHeight               = 150;
    self.inputToolbar.contentView.backgroundColor = [UIColor colorWithRed:0.34 green:0.35 blue:0.35 alpha:1];
    self.inputToolbar.contentView.leftBarButtonItem.tintColor  = [UIColor whiteColor];
    self.inputToolbar.contentView.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"Dealloc Messages View Controller");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [CLAppDelegate sharedInstance].currentDialogID = self.chatDialog.ID;
    [CLChatService sharedInstance].delegate = self;
    
    [self syncMessages:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [CLAppDelegate sharedInstance].currentDialogID = nil;
    [CLChatService sharedInstance].delegate = nil;
}

#pragma mark - Actions

- (void)closeAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadMoreAction {
    [self syncMessages:YES];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    if ([CLSettingsManager sharedManager].soundEnabled) {
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
    }

    BOOL sent = [[CLChatService sharedInstance] sendMessage:text toDialog:_chatDialog];

    if(!sent){
        [RMessage showErrorMessageWithTitle:@"Please check your internet connection"];
        return;
    }
    
    [self finishSendingMessageAnimated:YES];
}

- (void)sendImageMessage:(UIImage *)image
{
    // Upload a file to the Content module
    NSData *imageData = UIImageJPEGRepresentation(image, .8f);
    
    [QBRequest TUploadFile:imageData fileName:@"image.jpg" contentType:@"image/jpg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
        
        /**
         *  Sending a media message. Should do at least followings:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        if ([CLSettingsManager sharedManager].soundEnabled) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
        }
    
        [[CLChatService sharedInstance] sendMediaMessage:@"image" fileID:uploadedBlob.ID toDialog:_chatDialog];
        
        [imageData writeToFile:[CLImageCache imagePathForId:uploadedBlob.ID] atomically:YES];
        
        [self finishSendingMessageAnimated:YES];
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        // handle progress
    } errorBlock:^(QBResponse *response) {
        DDLogError(@"Error uploading image - %@", response.error);
    }];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Send Photo"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.dataSource objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.dataSource objectAtIndex:indexPath.item];
    
    return [self.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.dataSource objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.dataSource objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.dataSource objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.dataSource objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}



#pragma mark - Chat

- (void)syncMessages:(BOOL)loadPrevious
{
    NSArray *messages = [[CLChatService sharedInstance] messagsForDialogId:_chatDialog.ID];
    
    NSDate *lastMessageDateSent  = nil;
    NSDate *firstMessageDateSent = nil;
    
    if (messages.count > 0) {
        lastMessageDateSent  = ((QBChatMessage *)[messages lastObject]).dateSent;
        firstMessageDateSent = ((QBChatMessage *)[messages firstObject]).dateSent;
    }
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    if (loadPrevious) {
        if (firstMessageDateSent != nil) {
            extendedRequest[@"date_sent[lte]"] = @([firstMessageDateSent timeIntervalSince1970]-1);
        }
    } else {
        if (lastMessageDateSent != nil) {
            extendedRequest[@"date_sent[gte]"] = @([lastMessageDateSent timeIntervalSince1970]+1);
        }
    }
    extendedRequest[@"sort_desc"] = @"date_sent";
    
    __weak __typeof(self) weakSelf = self;
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
    [QBRequest messagesWithDialogID:_chatDialog.ID
                    extendedRequest:extendedRequest
                            forPage:page
                       successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
                           
                           if (messages.count > 0) {
                               [[CLChatService sharedInstance] addMessages:messages forDialogId:_chatDialog.ID];
                               
                               [self downloadImagesForMessages:messages];
                           }
                           
                           if (loadPrevious) {
                               
                               NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                               [formatter setDateFormat:@"MMM d, h:mm a"];
                               NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                               NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                                           forKey:NSForegroundColorAttributeName];
                               NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                               weakSelf.refreshControl.attributedTitle = attributedTitle;
                               
                               [weakSelf.refreshControl endRefreshing];
                               
                               [weakSelf.collectionView reloadData];
                               
                           } else {
                               
                               [weakSelf finishReceivingMessage];
                               
                           }
                           
                           [QBRequest markMessagesAsRead:[NSSet set] dialogID:_chatDialog.ID successBlock:nil errorBlock:nil];
                           [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationDidReadMessage object:nil];
                           
                       } errorBlock:^(QBResponse *response) {
                           
                       }];
}

#pragma mark Chat Service Delegate

- (void)chatDidLogin {
    [self syncMessages:NO];
}

- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message
{
    NSString *dialogId = message.dialogID;
    
    if(![_chatDialog.ID isEqualToString:dialogId]){
        return NO;
    }
    
    [self downloadImagesForMessages:@[message]];
    
    [self finishReceivingMessage];
    
    [QBRequest markMessagesAsRead:[NSSet setWithObjects:message, nil] dialogID:dialogId successBlock:nil errorBlock:nil];

    return YES;
}


#pragma mark - Photo Message

- (void)onTakePhoto {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController* imgPickerController = [[UIImagePickerController alloc] init];
        imgPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imgPickerController.allowsEditing = YES;
        
        imgPickerController.delegate = self;
        
        [self presentViewController:imgPickerController animated:YES completion:nil];
    }
}

- (void)onChoosePhotoFromLibrary {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController* imgPickerController = [[UIImagePickerController alloc] init];
        imgPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPickerController.delegate = self;
        imgPickerController.allowsEditing = YES;
        
        [self presentViewController:imgPickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *tmpImage = info[UIImagePickerControllerEditedImage];
    
    [self sendImageMessage:tmpImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self onTakePhoto];
            break;
            
        case 1:
            [self onChoosePhotoFromLibrary];
            break;
            
        case 2:
            break;
    }
}


#pragma mark - MISC

- (NSArray *)dataSource {
    return [[CLChatService sharedInstance] messagsForDialogId:_chatDialog.ID];
}

- (void)downloadImagesForMessages:(NSArray *)messages
{
    static NSMutableArray *downloadedIds = nil;
    
    if (!downloadedIds) {
        downloadedIds = [NSMutableArray array];
    }
    
    for (QBChatMessage *message in messages) {
        for (QBChatAttachment *attachment in message.attachments) {
            if ([downloadedIds containsObject:attachment.ID]) {
                continue;
            }
            
            [downloadedIds addObject:attachment.ID];
            
            // download file by ID
            [QBRequest downloadFileWithID:[attachment.ID integerValue]
                             successBlock:^(QBResponse *response, NSData *fileData) {

                                 [fileData writeToFile:[CLImageCache imagePathForIdString:attachment.ID] atomically:YES];
                                 
                                 [self.collectionView reloadData];

                             } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
                             } errorBlock:^(QBResponse *response) {
                                 
                                 DDLogError(@"Error downloading image %@\n%@", attachment.ID, response.error);
                                 
                                 // Start downloading again
                                 [downloadedIds removeObject:attachment.ID];
                                 
                             }];
        }
    }
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
