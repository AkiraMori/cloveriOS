//
//  CLProfileHeaderCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLProfileHeaderCell.h"

@interface CLProfileHeaderCell ()

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;

@end


@implementation CLProfileHeaderCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


#pragma mark - CLCellConfiguration

- (void)configureCellWithDictionary:(NSDictionary *)dictionary {
    _editView.hidden = [dictionary[@"editable"] boolValue];
    
    _lblTimestamp.text = dictionary[@"timestamp"];
}

#pragma mark - Actions

- (void)setReportAction:(id)target selector:(SEL)selector {
    [_btnReport addTarget:target
                   action:selector
         forControlEvents:UIControlEventTouchUpInside];
}


@end
