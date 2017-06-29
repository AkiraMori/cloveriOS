//
//  CLOnboardingSlidesViewController.m
//  Partake
//
//  Created by Maximilian Bosch on 1/5/17.
//  Copyright © 2017 CodigoDelSur. All rights reserved.
//

#import "CLOnboardingSlidesViewController.h"
#import "CLOnboardingController.h"
#import "CLOnboardingFacebookViewController.h"
#import "CLOnboardingPrivacyInfoViewController.h"
#import "CLFacebookHelper.h"
#import "CLAppDelegate.h"
#import "NSDate+DateTools.h"
#import "CLDateHelper.h"

#import "TAPageControl.h"

@interface CLOnboardingSlidesViewController () <UIScrollViewDelegate, TAPageControlDelegate, FBSDKLoginButtonDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *slidesScrollView;
@property (weak, nonatomic) IBOutlet TAPageControl *pageControlView;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *FBloginBtn;

@property (strong, nonatomic) NSArray *imagesData;

@end

@implementation CLOnboardingSlidesViewController

@synthesize slidesScrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagesData = @[@"slide_home", @"slide_filters", @"slide_activity", @"slide_create_activity", @"slide_requests"];
    
    [self setupScrollViewImages];
    
    slidesScrollView.delegate = self;
    
    self.pageControlView.numberOfPages = self.imagesData.count;
    
    self.FBloginBtn.center             = self.view.center;
    self.FBloginBtn.readPermissions = [CLFacebookHelper readPermissions];
    self.FBloginBtn.publishPermissions = [CLFacebookHelper publishPermissions];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    slidesScrollView.contentSize = CGSizeMake(CGRectGetWidth(slidesScrollView.frame) * self.imagesData.count, CGRectGetHeight(slidesScrollView.frame));
}


#pragma mark - ScrollView delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    
    self.pageControlView.currentPage = pageIndex;
}


#pragma mark - Util

- (void)setupScrollViewImages
{
    [self.imagesData enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(slidesScrollView.frame) * idx, 0, CGRectGetWidth(slidesScrollView.frame), CGRectGetHeight(slidesScrollView.frame))];
        NSLog(@"width: %f", imageView.frame.size.width);
        NSLog(@"height: %f", imageView.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [UIImage imageNamed:imageName];
        imageView.backgroundColor = [UIColor lightGrayColor];
        [slidesScrollView addSubview:imageView];
    }];
}


#pragma mark - Actions

- (IBAction)facebookLoginTapped:(id)sender {
    
    CLOnboardingFacebookViewController *facebookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CLOnboardingFacebookViewController"];
    
    facebookVC.onboardingController = (CLOnboardingController *)self.parentViewController;
    
    self.definesPresentationContext = YES;
    facebookVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [facebookVC.view setHidden:YES];
    [self presentViewController:facebookVC animated:NO completion:nil];
    
    [facebookVC nextAction:nil];
    
}

- (IBAction)infoTapped:(id)sender {
    CLOnboardingPrivacyInfoViewController *infoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CLOnboardingPrivacyInfoViewController"];
    infoVC.parentVC = self;
    [self presentViewController:infoVC animated:YES completion:nil];
}

#pragma mark - FBSDKLoginButton Delegate
- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error
{
    if(error) {
        [RMessage showErrorMessageWithTitle:@"Could not connect to Facebook. Please try again."];
    }
    else if(result.isCancelled) {
        
    }
    else {
        if ([result.grantedPermissions containsObject:@"email"])
        {
            DDLogInfo(@"Permissions on Session: %@", result.grantedPermissions);
            [self getFBResult];
        }
    }
}

- (void)getFBResult
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        [self showProgressHUDWithStatus:@"Logging In..."];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, first_name, last_name, birthday, picture.type(large), email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id user, NSError *error) {
             if (!error)
             {
                 //NSLog(@"fb user info : %@",result);
                 DDLogInfo(@"Successful Facebook Login with ID: %@", user[@"id"]);
                 
                 
                 NSDate *dateOfBirth = [CLDateHelper dateFromStringDate:user[@"birthday"]
                                                              formatter:kCLDateFormatterMonthDayYear];
                 
                 NSNumber *age       = @([dateOfBirth yearsAgo]);
                 
                 NSString *bio       = ([[((NSDictionary *)user) allKeys] containsObject:@"bio"]) ? user[@"bio"] : @"";
                 
                 [[CLApiClient sharedInstance] loginWithFbId:user[@"id"]
                                                     fbToken:[[FBSDKAccessToken currentAccessToken] tokenString]
                                                   firstName:user[@"first_name"]
                                                    lastName:user[@"last_name"]
                                                       email:user[@"email"]
                                                      gender:user[@"gender"]
                                                         age:[age stringValue]
                  //                                        aboutMe:bio
                                                successBlock:^(BOOL isNewUser, NSArray *result) {
                                                    
                                                    DDLogInfo(@"Successful Partake Login");
                                                    
                                                    [self dismissProgressHUD];
                                                    
                                                    [[CLAppDelegate sharedInstance] showTabBar];
                                                    
                                                    // save first 6 profile photos as default
                                                    if (isNewUser) {
                                                        [self saveUserProfileDefaultsFromFacebook:bio];
                                                    }
                                                    
                                                } failureBlock:^(NSError *error) {
                                                    
                                                    DDLogError(@"Error: %@", error.description);
                                                    
                                                    [RMessage showErrorMessageWithTitle:@"Oh no! Something went wrong!"];
                                                    
                                                    
                                                    [self dismissProgressHUD];
                                                    
                                                }];
                 
             }
             else
             {
                 NSLog(@"error : %@",error);
             }
         }];
    }
}

- (void)saveUserProfileDefaultsFromFacebook:(NSString *)bio {
    [CLFacebookHelper getUserProfilePhotosWithCompletion:^(NSArray *photos) {
        
        if (photos.count) {
            
            NSMutableArray *pictures = [NSMutableArray array];
            for (int i = 0; i < MIN(photos.count, 6); i++) {
                CLProfilePhoto *profilePhotoObject = photos[i];
                [pictures addObject:profilePhotoObject.source];
            }
            
            [[CLApiClient sharedInstance] editUserProfileAboutMe:bio
                                                        Pictures:pictures
                                                    successBlock:^(NSArray *results) {
                                                        
                                                        DDLogDebug(@"Success saving user profile photos - %@", results);
                                                        
                                                    } failureBlock:^(NSError *error) {
                                                        
                                                        DDLogError(@"Error saving user profile photos - %@", error.userInfo[@"error"]);
                                                        
                                                    }];
        }
        
    }];
}
@end
