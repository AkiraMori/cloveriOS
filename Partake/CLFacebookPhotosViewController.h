//
//  CLFacebookPhotosViewController.h
//  Partake
//
//  Created by Maikel on 16/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCollectionViewController.h"

@interface CLFacebookPhotosViewController : CLCollectionViewController

@property (copy, nonatomic) NSString *facebookAlbumId;

@property (strong, nonatomic) CLProfilePhoto *selectedPhoto;

@end
