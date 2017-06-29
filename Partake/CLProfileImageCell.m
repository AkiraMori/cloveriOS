//
//  CLProfileImageCell.m
//  Partake
//
//  Created by Maikel on 15/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLProfileImageCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "UIColor+CloverAdditions.h"

@interface CLProfileImageCell ()
@property (weak, nonatomic) IBOutlet UIView *removeView;
@end

@implementation CLProfileImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        _imageView.alpha = .7f;
    }else {
        _imageView.alpha = 1.f;
    }
}


#pragma mark - CLCellConfigurationProtocol Delegate Methods

- (void)configureCellWithDictionary:(NSDictionary *)dictionary {
    NSString *imageUrl = dictionary[@"imageUrl"];
    NSString *imageName = dictionary[@"imageName"];
    
    if (imageUrl) {
        
        [_imageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageUrl]
                                        placeholderImage:nil
                                                 options:0
                                                progress:nil
                                               completed:nil
                                    progressPrimaryColor:nil
                                  progressSecondaryColor:nil
                                                diameter:20.f
                                                   scale:YES];
        
    } else if (imageName) {
        
        _imageView.image = [UIImage imageNamed:imageName];
        
    } else {
        
        _imageView.image = [UIImage imageNamed:@"profile_picture_empty"];
        
    }
    
    _removeView.hidden = ![dictionary[@"editable"] boolValue];
}
@end
