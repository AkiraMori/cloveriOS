//
//  CLProfilePicturesCellTableViewCell.h
//  Partake
//
//  Created by Pablo Episcopo on 4/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTableViewCell.h"
#import "CLCellConfigurationProtocol.h"

#define MAX_IMAGE_COUNT 6


@protocol CLProfilePicturesCellDelegate;


@interface CLProfilePicturesCell : CLTableViewCell <CLCellConfigurationProtocol>

@property (assign, nonatomic) id<CLProfilePicturesCellDelegate> delegate;

- (void)addPhotoWithLink:(NSString *)link;
- (void)removePhotoAtIndex:(NSInteger)index;

- (CGFloat)height;

@end


@protocol CLProfilePicturesCellDelegate <NSObject>

- (void)profilePicturesCellDidTapAddPicture:(CLProfilePicturesCell *)cell;
- (void)profilePicturesCell:(CLProfilePicturesCell *)cell DidTapRemoveAtIndex:(NSInteger)index;

@end