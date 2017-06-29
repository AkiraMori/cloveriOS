//
//  CLEditProfileViewController.m
//  Partake
//
//  Created by Maikel on 21/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLEditProfileViewController.h"
#import "CLProfileBioCell.h"
#import "CLAppearanceHelper.h"
#import "CLProfileHeaderCell.h"
#import "CLProfilePicturesCell.h"
#import "CLFacebookPhotosViewController.h"
#import "UIAlertView+CloverAdditions.h"
#import "CLDateHelper.h"


static NSString * const kCLProfileHeaderCellIdentifier   = @"CLProfileHeaderCell";
static NSString * const kCLProfilePicturesCellIdentifier = @"CLProfilePicturesCell";
static NSString * const kCLProfileBioCellIdentifier      = @"CLProfileBioCell";


@interface CLEditProfileViewController () <CLProfilePicturesCellDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelHeader;

@property (strong, nonatomic) CLProfileHeaderCell   *headerCell;
@property (strong, nonatomic) CLProfilePicturesCell *picturesCell;
@property (strong, nonatomic) CLProfileBioCell      *bioCell;

@property (strong, nonatomic) NSArray *cells;

@property (strong, nonatomic) NSMutableArray *pictures;
@property (strong, nonatomic) NSString       *aboutMe;

@property (assign, nonatomic) BOOL  editable;

@end


@implementation CLEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.title = @"Edit Profile";
    
    self.editable = [[CLApiClient sharedInstance].loggedUser.userId isEqualToString:self.user.userId];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *headerCellNib   = [UINib nibWithNibName:NSStringFromClass([CLProfileHeaderCell class])
                                            bundle:[NSBundle mainBundle]];
    
    UINib *picturesCellNib = [UINib nibWithNibName:NSStringFromClass([CLProfilePicturesCell class])
                                            bundle:[NSBundle mainBundle]];
    
    UINib *bioCellNib      = [UINib nibWithNibName:NSStringFromClass([CLProfileBioCell class])
                                            bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:headerCellNib
         forCellReuseIdentifier:kCLProfileHeaderCellIdentifier];
    
    [self.tableView registerNib:picturesCellNib
         forCellReuseIdentifier:kCLProfilePicturesCellIdentifier];
    
    [self.tableView registerNib:bioCellNib
         forCellReuseIdentifier:kCLProfileBioCellIdentifier];
    
    self.headerCell   = [self.tableView dequeueReusableCellWithIdentifier:kCLProfileHeaderCellIdentifier];
    self.picturesCell = [self.tableView dequeueReusableCellWithIdentifier:kCLProfilePicturesCellIdentifier];
    self.bioCell      = [self.tableView dequeueReusableCellWithIdentifier:kCLProfileBioCellIdentifier];
    
    if (self.user) {
        
        NSString *timestampString = [NSString stringWithFormat:@"Active %@", [CLDateHelper timeElapsedStringFromDate:self.user.updatedAt]];
        
        [self.headerCell configureCellWithDictionary:@{
                                                       @"editable"  : @(_editable),
                                                       @"timestamp" : timestampString
                                                       }];
        
        [self.headerCell setReportAction:self selector:@selector(reportAction)];
        
        _pictures = [NSMutableArray arrayWithArray:self.user.pictures];
        [self.picturesCell configureCellWithDictionary:@{@"pictures": _pictures,
                                                         @"editable": @(_editable)}];
        self.picturesCell.delegate = self;
        
        [self.bioCell configureCellAppearanceWithData:@{
                                                        @"editable" : @(YES)
                                                        }];
        [self.bioCell configureCellWithDictionary:@{
                                                    @"firstName": self.user.firstName,
                                                    @"age":       self.user.age,
                                                    @"gender":    self.user.gender,
                                                    @"aboutMe":   self.user.aboutMe,
                                                    }];
        
        [self.bioCell getAboutMeWithCompletion:^BOOL(NSString *aboutMe) {
            if (aboutMe.length > kCLMaxNoteLength) {
                return NO;
            }
            
            self.aboutMe = aboutMe;
            return YES;
        }];
        
    }
    
    self.cells = @[
                   self.headerCell,
                   self.picturesCell,
                   self.bioCell
                   ];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
    if (_editable) {
        // check if pictures array has been changed or about me has been changed
        if (![_pictures isEqualToArray:self.user.pictures] ||
            ![_aboutMe isEqualToString:self.user.aboutMe]) {
            [self saveUserProfile];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reportAction {
    
}


#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.cells[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.cells[indexPath.row];
    
    if ([cell isKindOfClass:[CLProfileBioCell class]]) {
        
//        return [CLAppearanceHelper calculateHeightWithString:self.user.aboutMe
//                                                  fontFamily:kCLPrimaryBrandFontText
//                                                    fontSize:12.f
//                                           boundingSizeWidth:self.tableView.width];
        return 200.f;
        
    }
    
    return cell.height;
}


#pragma mark - CLProfilePicturesCell Delegate

- (void)profilePicturesCellDidTapAddPicture:(CLProfilePicturesCell *)cell {
    if (!_editable) {
        return;
    }
    
    if (_pictures.count < 6) {
        
        [self performSegueWithIdentifier:@"FacebookAlbumsSegue" sender:nil];
        
    } else {
        
        [UIAlertView showMessage:@"Please delete one or more photos above and try again!"
                           title:@"Maximum number reached."];
        
    }
}

- (void)profilePicturesCell:(CLProfilePicturesCell *)cell DidTapRemoveAtIndex:(NSInteger)index {
    if (index < _pictures.count) {
        if (_pictures.count <= 1) {
            
            [UIAlertView showMessage:@"Sorry, You are required to have at least one photo."];
            
        } else {
            
            [UIAlertView showAlertWithTitle:@"Delete this photo?"
                                    message:@"Are you sure you want to delete this photo?"
                                cancelTitle:@"Cancel"
                                acceptTitle:@"Delete"
                         cancelButtonAction:nil
                               acceptAction:^{
                                   [cell removePhotoAtIndex:index];
                               }];
        }
    }
}


#pragma mark - Misc

- (void)saveUserProfile {
    if (!_editable) {
        return;
    }
    
    [[CLApiClient sharedInstance] editUserProfileAboutMe:_aboutMe Pictures:_pictures successBlock:^(NSArray *results) {
        
        DDLogDebug(@"Success saving user profile photos - %@", results);
        
    } failureBlock:^(NSError *error) {
        
        DDLogError(@"Error saving user profile photos - %@", error.userInfo[@"error"]);
        
    }];
}


#pragma mark - Navigation

- (IBAction)unwindToProfile:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"SelectedPhotoSegue"]) {
        CLFacebookPhotosViewController *photosVC = segue.sourceViewController;
        
        if (![_pictures containsObject:photosVC.selectedPhoto.source]) {
            [self.picturesCell addPhotoWithLink:photosVC.selectedPhoto.source];
        }
    }
}


@end
