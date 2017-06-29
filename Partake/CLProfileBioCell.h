//
//  CLProfileBioCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLLabel.h"
#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLProfileBioCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *labelNameAge;
@property (weak, nonatomic) IBOutlet UILabel *labelGender;
@property (weak, nonatomic) IBOutlet CLLabel *labelBio;
@property (weak, nonatomic) IBOutlet UILabel *labelCharacterCount;

- (void)getAboutMeWithCompletion:(BOOL (^)(NSString *aboutMe))completion;

@end
