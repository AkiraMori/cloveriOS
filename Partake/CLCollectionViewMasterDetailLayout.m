//
//  CLCollectionViewMasterDetailLayout.m
//  Partake
//
//  Created by Maikel on 15/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCollectionViewMasterDetailLayout.h"

@interface CLCollectionViewMasterDetailLayout()

@property (nonatomic, assign) NSInteger numberOfCells;
@property (nonatomic, assign) CGFloat numberOfLines;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat sectionSpacing;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGRect oldRect;
@property (nonatomic, strong) NSArray *oldArray;
@property (nonatomic, strong) NSMutableArray *largeCellSizeArray;
@property (nonatomic, strong) NSMutableArray *smallCellSizeArray;

@end

@implementation CLCollectionViewMasterDetailLayout

#pragma mark - Over ride flow layout methods

- (void)prepareLayout
{
    [super prepareLayout];
    
    //collection view size
    _collectionViewSize = self.collectionView.bounds.size;
    //some values
    _itemSpacing = 0;
    _lineSpacing = 0;
    _sectionSpacing = 0;
    _insets = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        _itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        _lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        _sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        _insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
}

- (CGFloat)contentHeight
{
    CGFloat contentHeight = 0;
    NSInteger numberOfSections = self.collectionView.numberOfSections;
    CGSize collectionViewSize = self.collectionView.bounds.size;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
    CGFloat sectionSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    CGFloat itemSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    CGFloat lineSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
       lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    
    contentHeight += insets.top + insets.bottom + sectionSpacing * (numberOfSections - 1);
    
    CGFloat lastSmallCellHeight = 0;
    for (NSInteger i = 0; i < numberOfSections; i++) {
        CGFloat groupSize = [self _groupSizeInSection:i];
        NSInteger numberOfGroups = ceil((CGFloat)[self.collectionView numberOfItemsInSection:i] / groupSize);
        
        CGFloat largeCellSideLength = ((groupSize - 1.f) * (collectionViewSize.width - insets.left - insets.right) - itemSpacing) / groupSize;
        CGFloat smallCellSideLength = (largeCellSideLength - itemSpacing * (groupSize - 2.f)) / (groupSize - 1.f);
        CGSize largeCellSize = CGSizeMake(largeCellSideLength, largeCellSideLength);
        CGSize smallCellSize = CGSizeMake(smallCellSideLength, smallCellSideLength);
        
        if ([self.delegate respondsToSelector:@selector(collectionView:sizeForLargeItemsInSection:)]) {
            if (!CGSizeEqualToSize([self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:i], CLCollectionViewMasterDetailLayoutStyleSquare)) {
                largeCellSize = [self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:i];
                smallCellSize = CGSizeMake(collectionViewSize.width - largeCellSize.width - itemSpacing - insets.left - insets.right,
                                           (largeCellSize.height - itemSpacing * (groupSize - 2.f)) / (groupSize - 1.f));
            }
        }
        lastSmallCellHeight = smallCellSize.height;
        CGFloat largeCellHeight = largeCellSize.height;
        CGFloat lineHeight = numberOfGroups * (largeCellHeight + lineSpacing) - lineSpacing;
        contentHeight += lineHeight;
    }
    
    NSInteger numberOfItemsInLastSection = [self.collectionView numberOfItemsInSection:numberOfSections -1];
    NSInteger groupSizeInLastSection = [self _groupSizeInSection:numberOfSections - 1];
    
    if ((numberOfItemsInLastSection - 1) % groupSizeInLastSection == 0 &&
        (numberOfItemsInLastSection - 1) % (groupSizeInLastSection * 2) != 0) {
        contentHeight -= lastSmallCellHeight + itemSpacing;
    }
    
    return contentHeight;
}

- (void)setDelegate:(id<CLCollectionViewDelegateMasterDetailLayout>)delegate
{
    self.collectionView.delegate = delegate;
}

- (id<CLCollectionViewDelegateMasterDetailLayout>)delegate
{
    return (id<CLCollectionViewDelegateMasterDetailLayout>)self.collectionView.delegate;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(_collectionViewSize.width, [self contentHeight]);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    _oldRect = rect;
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger numberOfCellsInSection = [self.collectionView numberOfItemsInSection:i];
        for (NSInteger j = 0; j < numberOfCellsInSection; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }
        }
    }
    _oldArray = attributesArray;
    return  attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger groupSize = [self _groupSizeInSection:indexPath.section];
    
    //cellSize
    CGFloat largeCellSideLength = ((groupSize - 1.f) * (_collectionViewSize.width - _insets.left - _insets.right) - _itemSpacing) / groupSize;
    CGFloat smallCellSideLength = (largeCellSideLength - _itemSpacing * (groupSize - 2.f)) / (groupSize - 1.f);
    _largeCellSize = CGSizeMake(largeCellSideLength, largeCellSideLength);
    _smallCellSize = CGSizeMake(smallCellSideLength, smallCellSideLength);
    if ([self.delegate respondsToSelector:@selector(collectionView:sizeForLargeItemsInSection:)]) {
        if (!CGSizeEqualToSize([self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:indexPath.section], CLCollectionViewMasterDetailLayoutStyleSquare)) {
            _largeCellSize = [self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:indexPath.section];
            _smallCellSize = CGSizeMake(_collectionViewSize.width - _largeCellSize.width - _itemSpacing - _insets.left - _insets.right,
                                        (_largeCellSize.height - _itemSpacing * (groupSize - 2.f)) / (groupSize - 1.f));
        }
    }
    
    if (!_largeCellSizeArray) {
        _largeCellSizeArray = [NSMutableArray array];
    }
    if (!_smallCellSizeArray) {
        _smallCellSizeArray = [NSMutableArray array];
    }
    _largeCellSizeArray[indexPath.section] = [NSValue valueWithCGSize:_largeCellSize];
    _smallCellSizeArray[indexPath.section] = [NSValue valueWithCGSize:_smallCellSize];
    
    //section height
    CGFloat sectionHeight = 0;
    for (NSInteger i = 0; i <= indexPath.section - 1; i++) {
        NSInteger groupSizeInSection = [self _groupSizeInSection:i];
        NSInteger cellsCount = [self.collectionView numberOfItemsInSection:i];
        CGFloat largeCellHeight = [_largeCellSizeArray[i] CGSizeValue].height;
        CGFloat smallCellHeight = [_smallCellSizeArray[i] CGSizeValue].height;
        NSInteger lines = ceil((CGFloat)cellsCount / groupSizeInSection);
        sectionHeight += lines * (_lineSpacing + largeCellHeight) + _sectionSpacing;
        if ((cellsCount - 1) % groupSizeInSection == 0 &&
            (cellsCount - 1) % (groupSizeInSection * 2) != 0) {
            sectionHeight -= smallCellHeight + _itemSpacing;
        }
    }
    if (sectionHeight > 0) {
        sectionHeight -= _lineSpacing;
    }

    NSInteger line = indexPath.item / groupSize;
    CGFloat lineSpaceForIndexPath = _lineSpacing * line;
    CGFloat lineOriginY = _largeCellSize.height * line + sectionHeight + lineSpaceForIndexPath + _insets.top;
    CGFloat rightSideLargeCellOriginX = _collectionViewSize.width - _largeCellSize.width - _insets.right;
    CGFloat rightSideSmallCellOriginX = _collectionViewSize.width - _smallCellSize.width - _insets.right;
    
    if (indexPath.item % (groupSize * 2) == 0) {
        attribute.frame = CGRectMake(_insets.left, lineOriginY, _largeCellSize.width, _largeCellSize.height);
    }else if ((indexPath.item + 1) % (groupSize * 2) == 0) {
        attribute.frame = CGRectMake(rightSideLargeCellOriginX, lineOriginY, _largeCellSize.width, _largeCellSize.height);
    }else if (line % 2 == 0) {
        attribute.frame =CGRectMake(rightSideSmallCellOriginX, lineOriginY + (_smallCellSize.height + _itemSpacing) * ((indexPath.item % groupSize) - 1),
                                    _smallCellSize.width, _smallCellSize.height);
    }else {
        attribute.frame =CGRectMake(_insets.left, lineOriginY + (_smallCellSize.height + _itemSpacing) * (indexPath.item % groupSize),
                                    _smallCellSize.width, _smallCellSize.height);
    }
    return attribute;
}

#pragma mark - PRIVATE

- (NSInteger)_groupSizeInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:numberOfItemsInGroupsInSection:)]) {
        return [self.delegate collectionView:self.collectionView numberOfItemsInGroupsInSection:section];
    }
    
    return 5;
}

@end
