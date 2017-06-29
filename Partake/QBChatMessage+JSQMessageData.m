//
//  QBChatMessage+JSQMessageData.m
//  Partake
//
//  Created by Maikel on 04/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "QBChatMessage+JSQMessageData.h"
#import "CLImageCache.h"
#import <JSQMessagesViewController/JSQMessagesMediaPlaceholderView.h>
#import <JSQMessagesViewController/JSQPhotoMediaItem.h>

@implementation QBChatMessage (JSQMessageData)

- (BOOL)isMine {
    return self.senderID == [QBChat instance].currentUser.ID;
}

#pragma mark - JSQMessageData

- (NSString *)senderId {
    return [NSString stringWithFormat:@"%lu", self.senderID];
}

- (NSString *)senderDisplayName {
    return @"You";
}

- (NSDate *)date {
    return self.dateSent;
}

- (BOOL)isMediaMessage {
    return self.attachments.count > 0;
}

- (NSUInteger)messageHash {
    return self.ID.hash;
}

- (id<JSQMessageMediaData>)media {
    QBChatAttachment *attachment = self.attachments.firstObject;
    
    if (attachment) {
        UIImage *image = [CLImageCache imageForId:attachment.ID];
        
        if (image) {
            JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
            mediaItem.appliesMediaViewMaskAsOutgoing = [self isMine];
            
            return mediaItem;
        }
    }
    
    return self;
}


#pragma mark - JSQMessageMediaData

- (UIView *)mediaView {
    QBChatAttachment *attachment = self.attachments.firstObject;
    
    if (attachment) {
        UIImage *image = [CLImageCache imageForId:attachment.ID];
        
        if (image) {
            return [[UIImageView alloc] initWithImage:image];
        }
    }
    
    return nil;
}

- (CGSize)mediaViewDisplaySize {
    return CGSizeMake(200.f, 200.f);
}

- (UIView *)mediaPlaceholderView{
    return [JSQMessagesMediaPlaceholderView viewWithActivityIndicator];
}

- (NSUInteger)mediaHash {
    return ((QBChatAttachment *)self.attachments.firstObject).ID.hash;
}

@end
