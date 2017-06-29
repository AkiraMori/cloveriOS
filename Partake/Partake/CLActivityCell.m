//
//  ActivityCell.m
//  Partake
//
//  Created by Pablo Epíscopo on 3/2/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLActivityCell.h"
#import "NSDate+DateTools.h"
#import "CLActivityHelper.h"
#import "CLFacebookHelper.h"
#import "CLAppearanceHelper.h"
#import "CLLocationActivity.h"
#import "UIColor+CloverAdditions.h"
#import "CLActivity+ModelController.h"

@interface CLActivityCell ()

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) CLActivity  *activity;

@end

@implementation CLActivityCell

- (void)awakeFromNib
{
    /**
     *  Awake from nib.
     */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _avatarImageView.image = nil;
    
    [_avatarImageView sd_cancelCurrentImageLoad];
}

- (void)configureCellAppearanceWithData:(id)data
{
    self.indexPath = data;
    
    UIColor *indexColor          = [CLAppearanceHelper colorForIndexPath:data];
    UIImage *backgroundDropImage = [CLAppearanceHelper backgroundDropImageForIndexPath:data];
    
    [self.dashedLine setLineColor:indexColor];
    
    self.dashedLine.direction                = IPDashedLineViewDirectionHorizontalFromLeft;
    self.dashedLine.lengthPattern            = @[@3, @3];
    self.topSeparator.backgroundColor        = indexColor;
    self.bottomSeparator.backgroundColor     = indexColor;
    self.avatarImageView.borderColor         = [UIColor clearColor];
    self.avatarImageView.borderWidth         = 1.f;
    self.avatarBackgroundDropImageView.image = backgroundDropImage;
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    self.activity = dictionary[@"activity"];
    
    NSAssert(self.activity, @"Error: Missing some params.");
    
    NSString *nameAndAge   = [NSString stringWithFormat:@"%@, %@",   self.activity.user.firstName, [self.activity.user.age stringValue]];
    
    UIImage  *imageIcon    = [CLActivityHelper activityIconWithType:self.activity.type
                                                     isPrimaryColor:(self.indexPath.row % 2)];
    
    self.creatorNameAgeLabel.text     = nameAndAge;
    self.nameLabel.text               = self.activity.name;
    self.eventTypeIconImageView.image = imageIcon;
    self.timeLabel.text               = [CLActivityHelper stringFormatForActivityDateWithFromTime:self.activity.fromTime
                                                                                           toTime:self.activity.toTime];
    
    NSURL *url = [CLFacebookHelper profilePictureURLWithFacebookId:self.activity.user.fbUserId
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
    
    CGFloat  locationDistance = [self.activity distanceFromActiveUserInMiles];
    NSString *distance;
    
    if (locationDistance > 0) {
        
        NSNumberFormatter *fmt = [NSNumberFormatter new];
        [fmt setPositiveFormat:@"0.##"];
        
        distance = [[fmt stringFromNumber:@(locationDistance)] stringByAppendingString:@" mi"];
        
    } else {
        
        distance = @"0.0mi";
        
    }

    self.imgRepeatIcon.hidden = !self.activity.isRepeated;
    [self needsDistanceLayout];
    [self needsLikeButtonLayout];
}

- (void)needsDistanceLayout
{
    NSString *locationFull = [CLActivityHelper determineStringToShowWithLocation:self.activity.activityLocation];

    CGFloat  locationDistance = [self.activity distanceFromActiveUserInMiles];
    NSString *distance;
    
    if (locationDistance > 0) {
        
        NSNumberFormatter *fmt = [NSNumberFormatter new];
        [fmt setPositiveFormat:@"0.##"];
        
        distance = [[fmt stringFromNumber:@(locationDistance)] stringByAppendingString:@" mi"];
        
    } else {
        
        distance = @"0.0mi";
        
    }
    
    self.locationLabel.text = [NSString stringWithFormat:@"%@ - %@", locationFull, distance];
}

- (void)needsLikeButtonLayout {
    [self.btnLikes setTitle:[NSString stringWithFormat:@" %d", self.activity.likes.intValue]
                   forState:UIControlStateNormal];
    [self.btnLikes setImage:[UIImage imageNamed:self.activity.isLiked.boolValue ? @"activity-like-fill" : @"activity-like-empty"]
                   forState:UIControlStateNormal];
    [self.btnLikes setUserInteractionEnabled:!(self.activity.isLoggedUserOwner)];
}

- (IBAction)likeAction:(id)sender {
    BOOL like = !self.activity.isLiked.boolValue;
    // Update UI immediately
    self.activity.likes   = @(MAX(0, self.activity.likes.integerValue + (like ? 1 : -1)));
    self.activity.isLiked = @(like);
    [self needsLikeButtonLayout];
    // Save in the background
    [[CLApiClient sharedInstance] likeActivityWithId:self.activity.activityId
                                                like:like
                                        successBlock:^(NSArray *result) {
                                            
                                        } failureBlock:^(NSError *error) {
                                            NSLog(@"Error liking activity - %@", error.localizedDescription);
                                        }];
}

@end
