//
//  CLCollectionViewMasterDetailLayout.h
//  Partake
//
//  Created by Maikel on 15/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CLCollectionViewMasterDetailLayoutStyleSquare CGSizeZero

@protocol CLCollectionViewDelegateMasterDetailLayout <UICollectionViewDelegateFlowLayout>

@optional

// Number of items in a group of master-detail cells. Defaults to 5.
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInGroupsInSection:(NSInteger)section;
// Size of the master cell in a group. Defaults to automatically growing square!
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section;

- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView;

@end

@protocol CLCollectionViewMasterDetailLayoutDatasource <UICollectionViewDataSource>

@end

@interface CLCollectionViewMasterDetailLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<CLCollectionViewDelegateMasterDetailLayout> delegate;
@property (nonatomic, weak) id<CLCollectionViewMasterDetailLayoutDatasource> datasource;
@property (nonatomic, assign, readonly) CGSize largeCellSize;
@property (nonatomic, assign, readonly) CGSize smallCellSize;

- (CGFloat)contentHeight;

@end
