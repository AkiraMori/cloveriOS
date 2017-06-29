//
//  CLAttendanceListViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/22/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLAttendanceListViewController.h"
#import "CLProfileViewController.h"


@implementation CLAttendanceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"People Attending";
    
    [self loadAttendances];
}

#pragma mark UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        CLGenericHeaderCell *headerCell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                             withReuseIdentifier:kCLHeaderIdentifier
                                                                                    forIndexPath:indexPath];
        
        if (self.objectsArray.count == 1) {
            headerCell.headerLabel.text = @"There is 1 person attending.";
        } else {
            headerCell.headerLabel.text = [NSString stringWithFormat:@"There are %li people attending.", self.objectsArray.count];
        }
        
        return headerCell;
    }
    
    return [UICollectionReusableView new];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CLProfileViewController *profileVC = [[UIStoryboard storyboardWithName:@"CLProfileViewController" bundle:nil] instantiateInitialViewController];
    profileVC.user = self.objectsArray[indexPath.item];
    
    [self.navigationController pushViewController:profileVC animated:YES];
}


#pragma mark - Utilities

- (void)loadAttendances
{
    [self showProgressHUDWithStatus:@"Loading Attendances..."];
    
    [[CLApiClient sharedInstance] attendanceListWithActivityId:self.activityId
                                                  successBlock:^(NSArray *result) {
                                                      
                                                      self.objectsArray = result;
                                                      
                                                      [self.collectionView reloadData];
                                                      
                                                      [self dismissProgressHUD];
                                                      
                                                      DDLogInfo(@"Attendances fetched: %li", result.count);
                                                      
                                                  }
                                                  failureBlock:^(NSError *error) {
                                                      
                                                      [UIAlertView showMessage:@"Could not load attendances."
                                                                         title:@"Sorry about that!"];
                                                      
                                                      [self dismissProgressHUD];
                                                      
                                                      DDLogError(@"%@", error.description);
                                                      
                                                  }];
}

@end
