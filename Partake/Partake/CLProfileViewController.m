
//
//  CLProfileViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 3/6/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLProfileBioCell.h"
#import "CLAppearanceHelper.h"
#import "CLProfileHeaderCell.h"
#import "CLProfilePicturesCell.h"
#import "CLProfileViewController.h"
#import "CLFacebookPhotosViewController.h"
#import "UIAlertView+CloverAdditions.h"
#import "CLDateHelper.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "CLUser+ModelController.h"
#import "CLReportViewController.h"


@interface CLProfileViewController () <UIScrollViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIView *aboutMeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboutMeView_Height;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblGender;
@property (weak, nonatomic) IBOutlet UILabel *lblPoints;
@property (weak, nonatomic) IBOutlet CLLabel *lblBio;

@end


@implementation CLProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Profile";
    
    if (self.user) {
        
        [self configureUserPicturesScrollView];
        [self configurePageControl];
        [self configureUserAboutMeView];
        
    }
    
    if (self.user && ![self.user.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {

        [self configureRightBarButtonItem];
        
    }
}


#pragma mark - Actions

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reportAction {
    
}

- (void)optionsAction {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Block User", @"Report User", nil];
    
    [actionSheet showInView:self.navigationController.view];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _pageControl.currentPage = round(scrollView.contentOffset.y / scrollView.boundsHeight);
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == 0) {
        
        [UIAlertView showAlertWithTitle:@"Are you sure you want to block this user?"
                                message:nil
                            cancelTitle:@"No"
                            acceptTitle:@"Yes"
                     cancelButtonAction:nil
                           acceptAction:^{
                               
                               [[CLApiClient sharedInstance] blockUserWithFbId:self.user.fbUserId
                                                                  successBlock:^(NSArray *result) {
                                                                      
                                                                      DDLogInfo(@"Success blocking user - %@", result.firstObject);
                                                                      
                                                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                                                      
                                                                  } failureBlock:^(NSError *error) {
                                                                      
                                                                      DDLogError(@"Error blocking user - %@", error);
                                                                      
                                                                      [UIAlertView showMessage:@"Operation failed. Please try again later!"];
                                                                      
                                                                  }];
                               
                           }];
        
    } else if (buttonIndex == 1) {
        
        [self performSegueWithIdentifier:@"ReportSegue" sender:nil];
        
    }
}

#pragma mark - Misc

- (void)configureUserAboutMeView {
    // round corner
    _aboutMeView.layer.cornerRadius = 8.f;
    _aboutMeView.layer.masksToBounds = YES;
    
    // display values
    _lblName.text   = [NSString stringWithFormat:@"%@, %@", self.user.firstName, self.user.age];
    _lblGender.text = [self.user.gender capitalizedString];
    _lblBio.text    = self.user.aboutMe;
    
    // calculate height
    _aboutMeView_Height.constant = [CLAppearanceHelper calculateHeightWithString:self.user.aboutMe
                                                                      fontFamily:kCLPrimaryBrandFontText
                                                                        fontSize:12.f
                                                               boundingSizeWidth:self.view.width - 32.f] + 20.f;
    
    _lblPoints.text = [NSString stringWithFormat:@"%d", self.user.points.intValue];
}

- (void)configureUserPicturesScrollView {
    // round corner
    _scrollView.layer.cornerRadius = 8.f;
    _scrollView.layer.masksToBounds = YES;
    
    UIView *previousView = _scrollView;
    
    NSMutableArray *pictureUrls = [NSMutableArray arrayWithArray:self.user.pictures];
    if (!pictureUrls.count) {
        [pictureUrls addObject:[NSString stringWithFormat:kCLFacebookGraphProfilePictureURL, self.user.fbUserId, @"large"]];
    }
    
    for (NSString *url in pictureUrls) {
        
        UIImageView *imageView = [UIImageView new];
        
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [imageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:url]
                                       placeholderImage:nil
                                                options:0
                                               progress:nil
                                              completed:nil
                                   progressPrimaryColor:nil
                                 progressSecondaryColor:nil
                                               diameter:40.f
                                                  scale:1.f];
        
        [_scrollView addSubview:imageView];
        
        // constraints for equal size
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_scrollView
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.f
                                                                 constant:0.f]];
        
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_scrollView
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.f
                                                                 constant:0.f]];
        
        // constraints for horizontal align
        [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:@{@"imageView" : imageView}]];
        
        // constraints for vertical align
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:previousView
                                                                attribute:[_scrollView isEqual:previousView] ? NSLayoutAttributeTop : NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:imageView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.f
                                                                 constant:0.f]];
        
        previousView = imageView;
    }
    
    if (![previousView isEqual:_scrollView]) {
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:previousView
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_scrollView
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.f constant:0.f]];
    }
}

- (void)configurePageControl {
    _pageControl.numberOfPages = [self.user.pictures count];
    
    _pageControl.layer.anchorPoint = CGPointMake(0.f, 0.f);
    _pageControl.transform         = CGAffineTransformMakeRotation(M_PI_2);
}

- (void)configureRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar-button-options"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(optionsAction)];;
}

- (BOOL)isProfileUserBlocked
{
    CLUser *user = [CLUser getUserById:[CLApiClient sharedInstance].loggedUser.userId];

    if ([user.blockedUsers containsObject:self.user.fbUserId]) {
        return YES;
    }
    
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ReportSegue"]) {
        CLReportViewController *reportVC = segue.destinationViewController;
        reportVC.fbIdToReport = self.user.fbUserId;
    }
}

@end
