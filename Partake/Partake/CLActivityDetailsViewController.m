//
//  CLActivityViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 3/4/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLLabel.h"
#import "CLConstants.h"
#import "CLFacebookHelper.h"
#import "CLLocationActivity.h"
#import "UIView+Positioning.h"
#import "CLAppearanceHelper.h"
#import "CLHomeViewController.h"
#import "CLNavigationController.h"
#import "CLProfileViewController.h"
#import "CLActivityDetailsInfoCell.h"
#import "CLActivityDetailsHeaderCell.h"
#import "CLMutualFriendsViewController.h"
#import "CLAttendanceListViewController.h"
#import "CLActivityDetailsViewController.h"
#import "CLActivityDetailsDescriptionCell.h"
#import "UIViewController+CloverAdditions.h"
#import "CLActivityDetailsStatusRequestCell.h"
#import "CLDateHelper.h"
#import "CLActivityHelper.h"

#import "CLActivityDetailsPendingCell.h"
#import "CLActivityDetailsAcceptedCell.h"
#import "CLActivityDetailsReceivedCell.h"
#import "CLActivityDetailsAcceptedOwnerCell.h"

#import <ShareKit/ShareKit.h>
//#import <ShareKit/SHKFacebook.h>
#import <ShareKit/SHKTwitter.h>

#define kCLActivityDetailsAttendanceCellTag    1001
#define kCLActivityDetailsAttendanceSegue   @"ActivityDetailsAttendanceSegue"
#define kCLActivityDetailsProfileSegue      @"ActivityDetailsProfileSegue"

static NSString * const kCLActivityDetailsAttendanceCellIdentifier    = @"ActivityDetailsAttendanceCellIdentifier";
static NSString * const kCLActivityDetailsHeaderCellIdentifier        = @"ActivityDetailsHeader";
static NSString * const kCLActivityDetailsInfoCellIdentifier          = @"ActivityDetailsInfo";
static NSString * const kCLActivityDetailsDescriptionCellIdentifier   = @"ActivityDetailsDescription";
static NSString * const kCLActivityDetailsStatusRequestCellIdentifier = @"ActivityDetailsStatusRequest";

static NSString * const kCLActivityDetailsPendingCellIdentifier       = @"ActivityDetailsPendingCellIdentifier";
static NSString * const kCLActivityDetailsReceivedCellIdentifier      = @"ActivityDetailsReceivedCellIdentifier";
static NSString * const kCLActivityDetailsAcceptedCellIdentifier      = @"ActivityDetailsAcceptedCellIdentifier";
static NSString * const kCLActivityDetailsAcceptedOwnerCellIdentifier = @"ActivityDetailsAcceptedOwnerCellIdentifier";

@interface CLActivityDetailsViewController ()

@property (weak,   nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CLActivity     *activity;
@property (strong, nonatomic) NSMutableArray *cells;

@property (strong, nonatomic) UITableViewCell                    *cellAttendance;
@property (strong, nonatomic) CLActivityDetailsHeaderCell        *cellDetailsHeader;
@property (strong, nonatomic) CLActivityDetailsInfoCell          *cellDetailsInfo;
@property (strong, nonatomic) CLActivityDetailsDescriptionCell   *cellDetailsDescription;
@property (strong, nonatomic) CLActivityDetailsStatusRequestCell *cellStatusRequest;

@property (strong, nonatomic) CLActivityDetailsPendingCell       *pendingCell;
@property (strong, nonatomic) CLActivityDetailsReceivedCell      *receivedCell;
@property (strong, nonatomic) CLActivityDetailsAcceptedCell      *acceptedCell;
@property (strong, nonatomic) CLActivityDetailsAcceptedOwnerCell *acceptedOwnerCell;

@property (strong, nonatomic) UITableViewController *tableViewController;
@property (strong, nonatomic) UIRefreshControl      *refreshControl;

@end

@implementation CLActivityDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Activity";
    
    [self requiredPopViewControllerBackButton];
    
    UINib *activityHeaderCellNib        = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsHeaderCell        class])
                                                         bundle:[NSBundle mainBundle]];
    
    UINib *activityInfoCellNib          = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsInfoCell          class])
                                                         bundle:[NSBundle mainBundle]];
    
    UINib *activityDescriptionCellNib   = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsDescriptionCell   class])
                                                         bundle:[NSBundle mainBundle]];
    
    UINib *activityStatusRequestCellNib = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsStatusRequestCell class])
                                                         bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:activityHeaderCellNib        forCellReuseIdentifier:kCLActivityDetailsHeaderCellIdentifier];
    [self.tableView registerNib:activityInfoCellNib          forCellReuseIdentifier:kCLActivityDetailsInfoCellIdentifier];
    [self.tableView registerNib:activityDescriptionCellNib   forCellReuseIdentifier:kCLActivityDetailsDescriptionCellIdentifier];
    [self.tableView registerNib:activityStatusRequestCellNib forCellReuseIdentifier:kCLActivityDetailsStatusRequestCellIdentifier];
    
    self.cellDetailsHeader        = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsHeaderCellIdentifier];
    self.cellDetailsInfo          = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsInfoCellIdentifier];
    self.cellDetailsDescription   = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsDescriptionCellIdentifier];
    self.cellAttendance           = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsAttendanceCellIdentifier];
    self.cellStatusRequest        = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsStatusRequestCellIdentifier];
    
    UINib *pendingCellCellNib       = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsPendingCell       class])
                                                     bundle:[NSBundle mainBundle]];
    
    UINib *receivedCellCellNib      = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsReceivedCell      class])
                                                     bundle:[NSBundle mainBundle]];
    
    UINib *acceptedCellCellNib      = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsAcceptedCell      class])
                                                     bundle:[NSBundle mainBundle]];
    
    UINib *acceptedOwnerCellCellNib = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsAcceptedOwnerCell class])
                                                     bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:pendingCellCellNib
         forCellReuseIdentifier:kCLActivityDetailsPendingCellIdentifier];
    
    [self.tableView registerNib:receivedCellCellNib
         forCellReuseIdentifier:kCLActivityDetailsReceivedCellIdentifier];
    
    [self.tableView registerNib:acceptedCellCellNib
         forCellReuseIdentifier:kCLActivityDetailsAcceptedCellIdentifier];
    
    [self.tableView registerNib:acceptedOwnerCellCellNib
         forCellReuseIdentifier:kCLActivityDetailsAcceptedOwnerCellIdentifier];
    
    self.pendingCell       = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsPendingCellIdentifier];
    self.receivedCell      = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsReceivedCellIdentifier];
    self.acceptedCell      = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsAcceptedCellIdentifier];
    self.acceptedOwnerCell = [self.tableView dequeueReusableCellWithIdentifier:kCLActivityDetailsAcceptedOwnerCellIdentifier];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.cells = [NSMutableArray arrayWithArray:@[
                                                  self.cellDetailsHeader,
                                                  self.cellDetailsInfo,
                                                  self.cellDetailsDescription
                                                  ]];
    
    self.refreshControl           = [UIRefreshControl new];
    self.refreshControl.tintColor = [UIColor primaryBrandColor];
    
    self.tableViewController                = [UITableViewController new];
    self.tableViewController.tableView      = self.tableView;
    self.tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didShareOnTwitter)
                                                 name:SHKSendDidFinishNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableView DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cellDetailsHeader.selectionStyle      = UITableViewCellSelectionStyleNone;
    self.cellDetailsInfo.selectionStyle        = UITableViewCellSelectionStyleNone;
    self.cellDetailsDescription.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cellAttendance.selectionStyle         = UITableViewCellSelectionStyleNone;
    
    return self.cells[indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.cells[indexPath.row];
    
    if ([cell isKindOfClass:[CLActivityDetailsDescriptionCell class]]) {
        
        return [CLAppearanceHelper calculateHeightWithString:self.footerText
                                                  fontFamily:kCLPrimaryBrandFontText
                                                    fontSize:12.f
                                           boundingSizeWidth:self.tableView.width] + 24.f;
        
    }
    
    return cell.height;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[CLActivityDetailsHeaderCell class]]) {
        
        CLActivityDetailsHeaderCell *wcell = (CLActivityDetailsHeaderCell *)cell;
        
        [wcell.avatarImageView removeProgressViewRing];
        
    }
}


#pragma mark - Share Activity

- (void)showShareAlertController
{
    __weak typeof(self) weakSelf = self;
    
    [SHK setRootViewController:self];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Share on Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf shareActivityOnFacebook];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Share on Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SHKTwitter shareItem:[weakSelf shareItemForTwitter]];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Your activity has been shared successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [self updatePointAfterSharingOnPlatform:kCLSharePlatformFacebook];
}

- (void)shareActivityOnFacebook
{
    if([FBSDKAccessToken currentAccessToken]) {
        /*NSDate *activityDate = [CLDateHelper dateFromStringDate:self.activity.activityDate formatter:kCLDateFormatterISO8601];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMMM dd',' YYYY";
        
        NSDictionary *params = @{
                                 @"app_id"      : [CLFacebookHelper facebookAppId],
                                 @"name"        : self.activity.name ? self.activity.name : @"",
                                 @"caption"     : [NSString stringWithFormat:@"%@, %@ @ %@",
                                                   [CLActivityHelper stringFormatForActivityDateWithFromTime:self.activity.fromTime
                                                                                                      toTime:self.activity.toTime],
                                                   [dateFormatter stringFromDate:activityDate],
                                                   self.activity.activityLocation.formattedAddress],
                                 @"picture"     : kCLPartakeAppLogoURL,
                                 @"description" : self.activity.details ? self.activity.details : @"",
                                 @"link"        : kCLPartakeShareURL,
                                 };*/
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:kCLPartakeShareURL];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
    }
    /* adam
    FBSession *session = [FBSession activeSession];
    if (session.isOpen) {
     
        session.fromViewController = self;
     
        [FBWebDialogs presentFeedDialogModallyWithSession:session parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if (error) {
                NSLog(@"Error sharing via feed dialog - %@", error);
            } else if (result == FBWebDialogResultDialogCompleted) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Your activity has been shared successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                [self updatePointAfterSharingOnPlatform:kCLSharePlatformFacebook];
            }
        }];
    } else {
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:NO fromViewController:self completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Error opening facebook. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                [self shareActivityOnFacebook];
            }
        }];
    }
     */
}

- (SHKItem *)shareItemForFacebook
{
    NSURL *url = [NSURL URLWithString:kCLPartakeAppStoreURL];
    SHKItem *shareItem = [SHKItem URL:url
                                title:@"CHECK OUT MY ACTIVITY ON PARTAKE"
                          contentType:SHKURLContentTypeWebpage];
    
    shareItem.URLPictureURI = [NSURL URLWithString:kCLPartakeAppLogoURL];
    
    NSMutableString *text = [NSMutableString string];
    
    [text appendString:[NSString stringWithFormat:@"WHAT: %@\n", self.activity.name]];
    
    NSDate *activityDate = [CLDateHelper dateFromStringDate:self.activity.activityDate formatter:kCLDateFormatterISO8601];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM dd',' YYYY";
    
    [text appendString:[NSString stringWithFormat:@"WHEN: %@ - %@\n",
                        [dateFormatter stringFromDate:activityDate],
                        [CLActivityHelper stringFormatForActivityDateWithFromTime:self.activity.fromTime
                                                                           toTime:self.activity.toTime]]];
    
    [text appendString:[NSString stringWithFormat:@"WHERE: %@\n\n", self.activity.activityLocation.formattedAddress]];

    [text appendString:[NSString stringWithFormat:@"DETAILS: %@", self.activity.details]];
    
    shareItem.text = text;
    
    return shareItem;
}

- (SHKItem *)shareItemForTwitter
{
    NSString *title = @"Checkout my activity on Partake:";
    
    // Show activity details, abbreviated if necessary
    NSInteger textMaxLen = 140 - title.length - kCLPartakeAppStoreURL.length - 4;
    NSString *text = self.activity.details;
    if (text.length > textMaxLen) {
        text = [NSString stringWithFormat:@"%@%@", [text substringToIndex:textMaxLen-3], @"..."];
    }
    
    NSURL *url = [NSURL URLWithString:kCLPartakeAppStoreURL];
    SHKItem *shareItem = [SHKItem URL:url
                                title:[NSString stringWithFormat:@"%@ %@ | ", title, text]
                          contentType:SHKURLContentTypeWebpage];

    shareItem.URLPictureURI = [NSURL URLWithString:kCLPartakeAppLogoURL];

    return shareItem;
}

- (void)didShareOnTwitter {
    [self updatePointAfterSharingOnPlatform:kCLSharePlatformTwitter];
}

- (void)updatePointAfterSharingOnPlatform:(NSString *)platform
{
    [[CLApiClient sharedInstance] userDidShare:self.activityId on:platform successBlock:^(NSArray *result) {
        [self configureCells];
    } failureBlock:^(NSError *error) {
        
    }];
}

#pragma mark - Utilities

- (void)configureCells
{
    if (self.activity) {
        if (!self.headerUser) {
            self.headerUser = self.activity.user;
        }
        [self.cellDetailsHeader configureCellWithDictionary:@{@"user": self.headerUser}];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(showUserProfile)];
        
        [self.cellDetailsHeader.avatarImageView addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *tapGestureMutualFriends = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                  action:@selector(showMutualFriendViewController)];
        
        [self.cellDetailsHeader.mutualFriendsImageView addGestureRecognizer:tapGestureMutualFriends];
        
        [self.cellDetailsInfo configureCellWithDictionary:@{@"activity": self.activity}];

        if (!self.footerText) {
            self.footerText = self.activity.details;
        }
        if (!self.footerTextTitle) {
            self.footerTextTitle = @"Activity Details";
        }
        [self.cellDetailsDescription configureCellWithDictionary:@{
                                                                   @"title" : self.footerTextTitle,
                                                                   @"activityDetails": self.footerText
                                                                   }];
        
        self.cellAttendance.tag      = kCLActivityDetailsAttendanceCellTag;

        UIButton *btnAttendances = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAttendances setImage:[UIImage imageNamed:@"activity-show-attendance"]
                        forState:UIControlStateNormal];
        [btnAttendances setTitle:@"Attendees"
                        forState:UIControlStateNormal];
        btnAttendances.titleLabel.font = [UIFont systemFontOfSize:11.f];
        
        [btnAttendances setTitleColor:[UIColor secondaryBrandColor]
                             forState:UIControlStateNormal];
        [btnAttendances setTitleEdgeInsets:UIEdgeInsetsMake(44.f, -66.f, 0.f, 0.f)];
        
        [btnAttendances addTarget:self
                           action:@selector(showAttendances)
                 forControlEvents:UIControlEventTouchUpInside];
        btnAttendances.width = 66.f;
        btnAttendances.height = 44.f;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        btnAttendances.center = self.cellAttendance.center;
        btnAttendances.centerX = screenWidth / 2.f;
        
        if (self.activity.isLoggedUserOwner) {
            UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnShare setImage:[UIImage imageNamed:@"activity-share"]
                      forState:UIControlStateNormal];
            [btnShare setTitle:@"Share"
                      forState:UIControlStateNormal];
            [btnShare setTitleColor:[UIColor secondaryBrandColor]
                           forState:UIControlStateNormal];
            btnShare.titleLabel.font = [UIFont systemFontOfSize:11.f];
            [btnShare setTitleEdgeInsets:UIEdgeInsetsMake(44.f, -44.f, 0.f, 0.f)];
            
            [btnShare addTarget:self
                         action:@selector(showShareAlertController)
               forControlEvents:UIControlEventTouchUpInside];
            btnShare.width = btnShare.height = 44.f;
            btnShare.center = self.cellAttendance.center;
            
            btnAttendances.centerX = screenWidth / 3.f;
            btnShare.centerX = screenWidth * 2.f / 3.f;
            
            [self.cellAttendance addSubview:btnShare];
        }
        
        [self.cellAttendance addSubview:btnAttendances];
        
        if ([self.activity.isAtendeeVisible boolValue]) {
            
            if (![self.cells containsObject:self.cellAttendance]) {
                
                [self.cells addObject:self.cellAttendance];
                
            }
            
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kCLActivityDetailsAttendanceSegue]) {
        
        CLNavigationController *navigationController                 = segue.destinationViewController;
        CLAttendanceListViewController *attendanceListViewController = navigationController.viewControllers.firstObject;
        
        attendanceListViewController.activityId = sender[@"activityId"];
        
    } else if ([segue.identifier isEqualToString:kCLActivityDetailsProfileSegue]) {
     
        CLProfileViewController *profileController = segue.destinationViewController;
        
        profileController.user = sender[@"user"];
        
    }
}

- (void)showAttendances
{
    [self performSegueWithIdentifier:kCLActivityDetailsAttendanceSegue
                              sender:@{@"activityId": self.activityId}];
}

- (void)showUserProfile
{
    CLProfileViewController *profileController = [[UIStoryboard storyboardWithName:@"CLProfileViewController" bundle:nil] instantiateInitialViewController];
    profileController.user                      = self.headerUser;
    
    [self.navigationController pushViewController:profileController animated:YES];
}

- (void)showMutualFriendViewController
{
    if (![self.headerUser.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:NSStringFromClass([CLHomeViewController class])
                                                             bundle:[NSBundle mainBundle]];
        
        CLMutualFriendsViewController *mutualFriendsViewController = [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([CLMutualFriendsViewController class])];
        
        mutualFriendsViewController.activityOwnerFbId      = self.headerUser.fbUserId;
        mutualFriendsViewController.activityOwnerFirstName = self.headerUser.firstName;
        
        CLNavigationController *navController = [[CLNavigationController alloc] initWithRootViewController:mutualFriendsViewController];
        
        [self.navigationController presentViewController:navController
                                                animated:YES
                                              completion:nil];
        
    }
}

- (void)loadFacebookMutualFriends
{
    [CLFacebookHelper facebookMutualFriendForFacebookId:self.headerUser.fbUserId
                                           successBlock:^(NSArray *result) {
                                               
                                               [self.cellDetailsHeader updateMutualFriendsWithCounter:result.count];
                                               
                                               DDLogInfo(@"Facebook Friends Retrieved: %@", @(result.count));
                                               
                                           } failureBlock:^(NSError *error) {
                                               
                                               DDLogError(@"Facebook Friends Error: %@", error.description);
                                               
                                           }];
}

@end
