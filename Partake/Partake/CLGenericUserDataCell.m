//
//  CLGenericUserDataCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLFacebookHelper.h"
#import "CLGenericUserDataCell.h"
#import "NSDictionary+CloverAdditions.h"

@implementation CLGenericUserDataCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _avatarImageView.image = nil;
    
    [_avatarImageView sd_cancelCurrentImageLoad];
}

- (void)configureCellAppearanceWithData:(id)data
{
    self.avatarImageView.borderColor            = [UIColor clearColor];
    self.avatarImageView.borderWidth            = 1.f;
    self.avatarImageView.userInteractionEnabled = NO;
    self.avatarImageView.backgroundColor        = [UIColor whiteColor];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        self.nameAndAgeLabel.text = [NSString stringWithFormat:@"%@, %li", dictionary[@"userFirstName"], [dictionary[@"userAge"] integerValue]];
        
        NSString *userId = dictionary[@"userFbId"];
        
        NSURL *url       = [CLFacebookHelper profilePictureURLWithFacebookId:userId
                                                                   imageType:CLFacebookImageTypeNormal];
        
        [_avatarImageView setImageUsingProgressViewRingWithURL:url
                                              placeholderImage:nil
                                                       options:0
                                                      progress:nil
                                                     completed:^(UIImage *image,
                                                                 NSError * error,
                                                                 SDImageCacheType cacheType,
                                                                 NSURL *imageURL) {
                                                         [self setNeedsLayout];
                                                     }
                                          progressPrimaryColor:nil
                                        progressSecondaryColor:nil
                                                      diameter:20.f
                                                         scale:YES];
        
    }
}

@end
