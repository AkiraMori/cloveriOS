//
//  CLFacebookAlbumCell.m
//  Partake
//
//  Created by Maikel on 17/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFacebookAlbumCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"


@interface CLFacebookAlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgCoverPicture;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;

@end

@implementation CLFacebookAlbumCell


#pragma mark - Cell Configure Protocol

- (void)configureCellWithDictionary:(NSDictionary *)dictionary {
    [_imgCoverPicture setImageUsingProgressViewRingWithURL:[NSURL URLWithString:dictionary[@"cover_picture"]]
                                          placeholderImage:nil
                                                   options:0
                                                  progress:nil
                                                 completed:nil
                                      progressPrimaryColor:nil
                                    progressSecondaryColor:nil
                                                  diameter:20.f
                                                     scale:1.f];
    
    _lblTitle.text = dictionary[@"name"];
    _lblCount.text = [dictionary[@"count"] stringValue];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
