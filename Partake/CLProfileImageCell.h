//
//  CLProfileImageCell.h
//  Partake
//
//  Created by Maikel on 15/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCollectionViewCell.h"
#import "CLCellConfigurationProtocol.h"

@interface CLProfileImageCell : CLCollectionViewCell <CLCellConfigurationProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
