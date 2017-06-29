//
//  CLActivityDetailsHeaderCell.m
//  Partake
//
//  Created by Pablo Episcopo on 3/5/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFacebookHelper.h"
#import "CLActivity+ModelController.h"
#import "CLActivityDetailsHeaderCell.h"
#import "NSDictionary+CloverAdditions.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"

@interface CLActivityDetailsHeaderCell ()

@property (strong, nonatomic) CLUser *user;

@end

@implementation CLActivityDetailsHeaderCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureCellAppearanceWithData:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _avatarImageView.image = nil;
    
    [_avatarImageView sd_cancelCurrentImageLoad];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellAppearanceWithData:(id)data
{
    self.avatarImageView.borderColor            = [UIColor clearColor];
    self.avatarImageView.borderWidth            = 1.f;
    self.avatarImageView.userInteractionEnabled = YES;
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary;
{
    if ([dictionary hasKeys]) {
        
        self.user            =   dictionary[@"user"];
        
        NSString *userFirstName  = self.user.firstName;
        NSString *userAge        = [self.user.age stringValue];
        
        NSURL *url               = [CLFacebookHelper profilePictureURLWithFacebookId:self.user.fbUserId
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
        
        self.nameAndAgeLabel.text = [NSString stringWithFormat:@"%@, %@", userFirstName, userAge];
        
        self.pointsLabel.text = [NSString stringWithFormat:@"%d", self.user.points.intValue];
    }
}

- (void)updateMutualFriendsWithCounter:(NSInteger)counter
{
    NSString *stringMutualFriends = @"No Mutual Friends";
    
    if ([self.user.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
        
        stringMutualFriends = @"Activity Owner";
        
    } else if (counter > 0) {
        
        NSString *aux = (counter == 1) ? @"Mutual Friend" : @"Mutual Friends";
        
        stringMutualFriends = [NSString stringWithFormat:@"%li %@", (long)counter, aux];
        
    } else {
        
        stringMutualFriends = @"No Mutual Friends";
        
    }
    
    self.mutualFriendsLabel.text = stringMutualFriends;
}

@end
