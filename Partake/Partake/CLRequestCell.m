//
//  RequestCell.m
//  Partake
//
//  Created by Pablo Episcopo on 3/27/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLRequest.h"
#import "CLDateHelper.h"
#import "CLRequestCell.h"
#import "CLActivityHelper.h"
#import "NSDate+DateTools.h"
#import "CLFacebookHelper.h"
#import "CLAppearanceHelper.h"
#import "UIColor+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLRequest+ModelController.h"


@interface CLRequestCell ()

@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation CLRequestCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
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
        
        CLRequest *request = dictionary[@"request"];
        
        NSString *dayString   = [CLDateHelper    stringDayDateFromStringDate:request.activityDate];
        NSString *monthString = [CLDateHelper stringShortMonthFromStringDate:request.activityDate];
        
        CLUser *otherUser    = [request theOtherUser];
        NSString *nameAndAge = [NSString stringWithFormat:@"%@, %@", otherUser.firstName, [otherUser.age stringValue]];
        NSString *dateString = [NSString stringWithFormat:@"%@ / %@", dayString, monthString];
        
        UIImage  *imageIcon  = [CLActivityHelper activityIconWithType:request.activityType
                                                       isPrimaryColor:(self.indexPath.row % 2)];
        
        self.creatorNameAgeLabel.text     = nameAndAge;
        self.nameLabel.text               = request.activityName;
        self.dateLabel.text               = dateString;
        self.requestedTimeLabel.text      = [@"Request sent " stringByAppendingString:[request.requestCreatedAt timeAgoSinceNow].lowercaseString];
        self.eventTypeIconImageView.image = imageIcon;
        
        NSURL *url = [CLFacebookHelper profilePictureURLWithFacebookId:otherUser.fbUserId
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

@end
