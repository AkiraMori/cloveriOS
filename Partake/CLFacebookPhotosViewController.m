//
//  CLFacebookPhotosViewController.m
//  Partake
//
//  Created by Maikel on 16/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFacebookPhotosViewController.h"
#import "CLProfileImageCell.h"
#import "UIViewController+SVProgressHUD.h"


@interface CLFacebookPhotosViewController ()
@property (strong, nonatomic) NSArray *dataSource;
@end


@implementation CLFacebookPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Photos";
    
    [self.collectionView registerNib:[CLProfileImageCell nib]
          forCellWithReuseIdentifier:[CLProfileImageCell reuseIdentifier]];
    
    if (self.facebookAlbumId) {
        [self loadPhotosInBackground];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotosInBackground
{
    [self showProgressHUDWithStatus:nil];
    
    //request photos from the profile album
    
    FBSDKGraphRequest *requestPhotos = [[FBSDKGraphRequest alloc]
                                        initWithGraphPath:[NSString stringWithFormat:@"%@/photos", self.facebookAlbumId]
                                        parameters:nil
                                        HTTPMethod:@"GET"];
    [requestPhotos startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                id resultPhotos,
                                                NSError *errorPhotos) {
        [self dismissProgressHUD];
        
        if (errorPhotos) {
            
            NSLog(@"Error fetching facebook profile photos - %@", errorPhotos.userInfo[@"error"]);
            
        } else {
            
            NSMutableArray *photos = [NSMutableArray array];
            for (NSDictionary *photoNode in resultPhotos[@"data"]) {
                [photos addObject:[CLProfilePhoto photoWithFacebookPhotoNode:photoNode]];
            }
            
            _dataSource = photos;
            
            [self.collectionView reloadData];
        }
    }];
}


#pragma mark - UICollectionView
#pragma mark Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CLProfileImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CLProfileImageCell reuseIdentifier] forIndexPath:indexPath];
    
    CLProfilePhoto *profilePhoto = _dataSource[indexPath.item];
    NSString *link = profilePhoto.source;
    
    [cell configureCellWithDictionary:@{@"imageUrl" : link ? link : @""}];
    
    return cell;
}

#pragma mark - Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPhoto = _dataSource[indexPath.item];
    [self performSegueWithIdentifier:@"SelectedPhotoSegue" sender:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
