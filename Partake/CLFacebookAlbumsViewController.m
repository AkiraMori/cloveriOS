//
//  CLFacebookAlbumsViewController.m
//  Partake
//
//  Created by Maikel on 16/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFacebookAlbumsViewController.h"
#import "CLFacebookAlbumCell.h"
#import "CLFacebookHelper.h"
#import "UIViewController+SVProgressHUD.h"
#import "CLFacebookPhotosViewController.h"


@interface CLFacebookAlbumsViewController ()
@property (copy, nonatomic) NSArray *dataSource;
@end

@implementation CLFacebookAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.rowHeight = 60.f;
    [self.tableView registerNib:[CLFacebookAlbumCell nib] forCellReuseIdentifier:[CLFacebookAlbumCell reuseIdentifier]];
    
    [self showProgressHUDWithStatus:nil];

    [self loadUserFacebookAlbumsInBackground];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserFacebookAlbumsInBackground
{
    //request albums
    FBSDKGraphRequest *requestAlbums = [[FBSDKGraphRequest alloc]
                                        initWithGraphPath:@"me/albums"
                                        parameters:nil
                                        HTTPMethod:@"GET"];
    [requestAlbums startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                id resultAlbums,
                                                NSError *error) {
        [self dismissProgressHUD];

        _dataSource = resultAlbums[@"data"];
        [self.tableView reloadData];
    }];
    /* adam
    FBRequest *requestAlbums = [FBRequest requestForGraphPath:@"me/albums"];
    
    [requestAlbums startWithCompletionHandler:^(FBRequestConnection *connection, id resultAlbums, NSError *errorAlbums) {
        
        [self dismissProgressHUD];
        
        _dataSource = resultAlbums[@"data"];
        [self.tableView reloadData];

    }];
     */
}

#pragma mark - UITableView
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLFacebookAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLFacebookAlbumCell reuseIdentifier]];
    
    NSDictionary *albumNode = _dataSource[indexPath.row];
    
    NSString *coverPictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=thumbnail", albumNode[@"id"]];
    [cell configureCellWithDictionary:@{
                                        @"cover_picture" : coverPictureUrl,
                                        @"name" : albumNode[@"name"],
                                        @"count" : albumNode[@"count"]
                                        }];
    return cell;
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PhotosSegue" sender:_dataSource[indexPath.row]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"PhotosSegue"]) {
        CLFacebookPhotosViewController *photoVC = segue.destinationViewController;
        photoVC.facebookAlbumId = sender[@"id"];
    }
}


@end
