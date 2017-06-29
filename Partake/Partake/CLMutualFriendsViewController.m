//
//  CLMutualFriendsViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLMutualFriendsViewController.h"
#import "CLFacebookHelper.h"

@implementation CLMutualFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Mutual Friends";
    
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
        switch (self.objectsArray.count) {
            case 0:
                headerCell.headerLabel.text = [NSString stringWithFormat:@"You have no mutual friends with %@",
                                               self.activityOwnerFirstName];
                break;
                
            case 1:
                headerCell.headerLabel.text = [NSString stringWithFormat:@"You have 1 mutual friend with %@",
                                               self.activityOwnerFirstName];
                break;
                
            default:
                headerCell.headerLabel.text = [NSString stringWithFormat:@"You have %li mutual friends with %@",
                                               self.objectsArray.count,
                                               self.activityOwnerFirstName];
                break;
        }
        
        return headerCell;
    }
    
    return [UICollectionReusableView new];
}

#pragma mark - Utilities

- (void)loadAttendances
{
    [self showProgressHUDWithStatus:@"Loading Friends..."];
    
    [CLFacebookHelper facebookMutualFriendForFacebookId:self.activityOwnerFbId
                                           successBlock:^(NSArray *result) {
                                               
                                               self.objectsArray = result;
                                               
                                               [self.collectionView reloadData];
                                               
                                               [self dismissProgressHUD];
                                               
                                               DDLogInfo(@"Attendances fetched: %li", result.count);
                                               
                                           } failureBlock:^(NSError *error) {
                                               
                                               [UIAlertView showMessage:@"Could not load mutual friends."
                                                                  title:@"Sorry about that!"];
                                               
                                               [self dismissProgressHUD];
                                               
                                               DDLogError(@"%@", error.description);
                                               
                                           }];
}

@end
