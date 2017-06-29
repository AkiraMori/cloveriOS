//
//  CLGenericFlowCollectionViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLGenericFlowCollectionViewController.h"

@implementation CLGenericFlowCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nibHeader = [UINib nibWithNibName:NSStringFromClass([CLGenericHeaderCell   class])
                                      bundle:[NSBundle mainBundle]];
    
    UINib *nibCell   = [UINib nibWithNibName:NSStringFromClass([CLGenericUserDataCell class])
                                      bundle:[NSBundle mainBundle]];
    
    [self.collectionView registerNib:nibHeader
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:kCLHeaderIdentifier];
    
    [self.collectionView registerNib:nibCell
          forCellWithReuseIdentifier:kCLUserDataIdentifier];
    
    [self requiredDismissModalBackButton];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionViewLayout invalidateLayout];
}

#pragma mark UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(CLGenericUserDataCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.avatarImageView removeProgressViewRing];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objectsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CLGenericUserDataCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCLUserDataIdentifier
                                                                            forIndexPath:indexPath];
    
    if ([self.objectsArray[indexPath.row] isKindOfClass:[CLUser class]]) {
        
        CLUser *user = self.objectsArray[indexPath.row];
        
        [cell configureCellAppearanceWithData:nil];
        
        [cell configureCellWithDictionary:@{
                                            @"userFbId":      user.fbUserId,
                                            @"userFirstName": user.firstName,
                                            @"userAge":       user.age
                                            }];
        
    }
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayou referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.width, 50.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    double side = (self.view.width - 4) / 3 - 2;
    
    return CGSizeMake(side - 2, side);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 4, 4, 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.0;
}

@end
