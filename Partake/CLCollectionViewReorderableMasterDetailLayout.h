//
//  CLCollectionViewReorderableMasterDetailLayout.h
//  Partake
//
//  Created by Maikel on 15/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCollectionViewMasterDetailLayout.h"

@protocol CLCollectionViewReorderableMasterDetailLayoutDataSource <UICollectionViewDataSource>

@optional

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol CLCollectionViewDelegateReorderableMasterDetailLayout <UICollectionViewDelegateFlowLayout>

@optional

- (CGFloat)reorderingItemAlpha:(UICollectionView * )collectionview; //Default 0.
- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView; //Sorry, has not supported horizontal scroll.
- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView;

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

@end



@interface CLCollectionViewReorderableMasterDetailLayout : UICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<CLCollectionViewDelegateReorderableMasterDetailLayout> delegate;
@property (nonatomic, weak) id<CLCollectionViewReorderableMasterDetailLayoutDataSource> datasource;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;

@end
