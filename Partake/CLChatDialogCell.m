//
//  CLChatDialogCell.m
//  Partake
//
//  Created by Maikel on 03/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLChatDialogCell.h"
#import "IPDashedLineView.h"
#import "APAvatarImageView.h"
#import "CLAppearanceHelper.h"
#import "CLChatService.h"
#import "CLFacebookHelper.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "CLActivityHelper.h"
#import "CLDateHelper.h"


@interface CLChatDialogCell ()
@property (weak, nonatomic) IBOutlet UILabel *topSeparator;
@property (weak, nonatomic) IBOutlet UILabel *bottomSeparator;
@property (weak, nonatomic) IBOutlet UILabel *recipientNameAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dialogNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageSenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageTextLabel;

@property (weak, nonatomic) IBOutlet IPDashedLineView  *dashedLine;
@property (weak, nonatomic) IBOutlet APAvatarImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UIImageView *dialogIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarBackgroundDropImageView;

@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation CLChatDialogCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _avatarImageView.image = nil;
    
    [_avatarImageView sd_cancelCurrentImageLoad];
}


#pragma mark - Cell Configuration

- (void)configureCellAppearanceWithData:(id)data
{
    self.indexPath = data;
    
    UIColor *indexColor          = [CLAppearanceHelper colorForIndexPath:data];
    UIImage *backgroundDropImage = [CLAppearanceHelper backgroundDropImageForIndexPath:data];
    
    self.dashedLine.direction                = IPDashedLineViewDirectionHorizontalFromLeft;
    self.dashedLine.lengthPattern            = @[@3, @3];
    self.dashedLine.lineColor                = indexColor;
    self.topSeparator.backgroundColor        = indexColor;
    self.bottomSeparator.backgroundColor     = indexColor;
    self.avatarImageView.borderColor         = [UIColor clearColor];
    self.avatarImageView.borderWidth         = 1.f;
    self.avatarBackgroundDropImageView.image = backgroundDropImage;
}


- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        QBChatDialog *chatDialog = dictionary[@"dialog"];
        QBUUser *recipient       = [[CLChatService sharedInstance] userWithID:chatDialog.recipientID];

        NSString *recipientName = [recipient.fullName componentsSeparatedByString:@" "].firstObject;
        
        if (!recipientName) {
            recipientName = recipient.login;
        }
        
        if (!recipientName) {
            recipientName = [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID];
        }
        
        self.recipientNameAgeLabel.text  = chatDialog.data[@"activity_name"];
        self.dialogNameLabel.text        = [CLDateHelper timeElapsedStringFromDate:chatDialog.lastMessageDate];
        self.lastMessageTextLabel.text   = chatDialog.lastMessageText;
        self.lastMessageSenderLabel.text = ([QBChat instance].currentUser.ID == chatDialog.lastMessageUserID) ? @"You:" : [NSString stringWithFormat:@"%@:", recipientName];
        self.dialogIconImageView.image   = [CLActivityHelper activityIconWithType:chatDialog.data[@"activity_type"]
                                                                   isPrimaryColor:(self.indexPath.row % 2)];
        
        NSURL *url = [CLFacebookHelper profilePictureURLWithFacebookId:recipient.facebookID
                                                             imageType:CLFacebookImageTypeNormal];
        
        [_avatarImageView setImageUsingProgressViewRingWithURL:url
                                              placeholderImage:nil
                                                       options:0
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                         [self setNeedsLayout];
                                                     }
                                          progressPrimaryColor:nil
                                        progressSecondaryColor:nil
                                                      diameter:20.f
                                                         scale:YES];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
