//
//  CLSettingsCell.m
//  Partake
//
//  Created by Maikel on 08/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsCell.h"
#import "UIColor+CloverAdditions.h"


@interface CLSettingsCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgDetailIndicator;
@property (weak, nonatomic) IBOutlet UILabel *lblBadgeIcon;

@end


@implementation CLSettingsCell

+ (NSString *)reuseIdentifier {
    return @"tvcSettingsCell";
}

+ (UINib *)nib {
    return [UINib nibWithNibName:@"CLSettingsCell" bundle:nil];
}

#pragma mark - Configure Cell

- (void)configureCellWithDictionary:(NSDictionary *)dictionary {
    NSString *title = dictionary[@"title"];
    
    // title text
    _lblTitle.hidden = (title.length == 0);
    _lblTitle.text = title;
    
    // detail indicator
    _imgDetailIndicator.hidden = (title.length == 0);

    // badge icon
    NSNumber *badgeNumber = dictionary[@"badge"];
    if (badgeNumber && badgeNumber.intValue > 0) {
        _imgDetailIndicator.hidden = YES;
        _lblBadgeIcon.hidden = NO;
        _lblBadgeIcon.text = [badgeNumber stringValue];
        
    } else {
        _lblBadgeIcon.hidden = YES;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    // initialize badge icon label styling
    _lblBadgeIcon.layer.cornerRadius = 10.f;
    _lblBadgeIcon.layer.masksToBounds = YES;
    _lblBadgeIcon.backgroundColor = [UIColor primaryBrandColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
