//
//  CLCollectionViewCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/29/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCollectionViewCell.h"

@implementation CLCollectionViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)reuseIdentifier
{
    return [NSString stringWithFormat:@"cvc%@", NSStringFromClass([self class])];
}

@end
