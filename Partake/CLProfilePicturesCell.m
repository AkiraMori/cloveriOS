//
//  CLProfilePicturesCellTableViewCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLProfilePicturesCell.h"
#import "CLCollectionViewReorderableMasterDetailLayout.h"
#import "CLProfileImageCell.h"


@interface CLProfilePicturesCell () <CLCollectionViewDelegateReorderableMasterDetailLayout, CLCollectionViewReorderableMasterDetailLayoutDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) NSMutableArray *imageUrls;
@property (assign, nonatomic) BOOL  editable;
@end

@implementation CLProfilePicturesCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    [_collectionView registerNib:[UINib nibWithNibName:@"CLProfileImageCell" bundle:nil]
      forCellWithReuseIdentifier:@"cvcProfileImage"];
    
    _collectionView.layer.cornerRadius = 16.f;
    _collectionView.layer.masksToBounds = YES;
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


#pragma mark - CLCellConfigurationProtocol Delegate Methods

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        _imageUrls = dictionary[@"pictures"];
        _editable = [dictionary[@"editable"] boolValue];
        
        [_collectionView reloadData];
    }
}

- (CGFloat)height {
    return ([UIScreen mainScreen].bounds.size.width - 10.f) * 2.f / 3.f + 16.f;
}


#pragma mark - CLCollectionViewDelegateReorderableMasterDetailLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MAX_IMAGE_COUNT;
}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *imageUrl = [_imageUrls objectAtIndex:fromIndexPath.item];

    [_imageUrls removeObjectAtIndex:fromIndexPath.item];
    [_imageUrls insertObject:imageUrl atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return toIndexPath.item < _imageUrls.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.item < _imageUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CLProfileImageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cvcProfileImage" forIndexPath:indexPath];

    if (indexPath.item < _imageUrls.count) {
        [cell configureCellWithDictionary:@{
                                            @"imageUrl"    : _imageUrls[indexPath.item],
                                            @"editable" : @(_editable)
                                            }];
    } else {
        [cell configureCellWithDictionary:nil];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.width - 20.f) / 3.f, (self.width - 20.f) / 3.f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < _imageUrls.count) {
        
        if ([self.delegate respondsToSelector:@selector(profilePicturesCell:DidTapRemoveAtIndex:)]) {
            [self.delegate profilePicturesCell:self DidTapRemoveAtIndex:indexPath.item];
        }
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(profilePicturesCellDidTapAddPicture:)]) {
            [self.delegate profilePicturesCellDidTapAddPicture:self];
        }
        
    }
}


#pragma mark - PUBLIC

- (void)removePhotoAtIndex:(NSInteger)index {

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    if (indexPath) {
        [_imageUrls removeObjectAtIndex:indexPath.item];
        [self.collectionView reloadData];
    }
}

- (void)addPhotoWithLink:(NSString *)link
{
    [_imageUrls addObject:link];
    [_collectionView reloadData];
}

@end
