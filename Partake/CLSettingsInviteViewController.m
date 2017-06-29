//
//  CLSettingsInviteViewController.m
//  Partake
//
//  Created by Maikel on 03/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsInviteViewController.h"
#import "CLAppDelegate.h"
#import "CLFacebookHelper.h"
#import <ShareKit/ShareKit.h>
//#import <ShareKit/SHKFacebook.h>
#import <ShareKit/SHKTwitter.h>
#import <ShareKit/SHKMail.h>
#import <ShareKit/SHKTextMessage.h>
//#import "FBLinkShareParams.h"

@interface CLSettingsInviteViewController ()
@property (strong, nonatomic) SHKItem *shareItem;
@property (strong, nonatomic) SHKSharer *sharer;
@end

@implementation CLSettingsInviteViewController {
    NSString *sharePlatform;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:kCLPartakeAppStoreURL];
    _shareItem = [SHKItem URL:url
                        title:@"I am using Partake to find fun activities near me to enjoy with others. You should check it out."
                  contentType:SHKURLContentTypeWebpage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShare) name:SHKSendDidFinishNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Actions

- (void)didShare {
    [[CLApiClient sharedInstance] userDidShare:nil on:sharePlatform successBlock:nil failureBlock:nil];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thank you for sharing!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [[CLApiClient sharedInstance] userDidShare:nil on:kCLSharePlatformFacebook successBlock:nil failureBlock:nil];
}

- (IBAction)facebookAction:(id)sender {
    if([FBSDKAccessToken currentAccessToken]) {
        /*NSDictionary *params = @{
                                 @"app_id"      : [CLFacebookHelper facebookAppId],
                                 @"name"        : @"Partake",
                                 @"description" : @"I am using Partake to find fun activities near me to enjoy with others. You should check it out.",
                                 @"picture"     : kCLPartakeAppLogoURL,
                                 @"link"        : kCLPartakeShareURL,
                                 };*/
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:kCLPartakeShareURL];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
    }
    /* adam
    FBSession *session = FBSession.activeSession;

    if (session.isOpen) {
        session.fromViewController = self;
        NSDictionary *params = @{
                                 @"app_id"      : [CLFacebookHelper facebookAppId],
                                 @"name"        : @"Partake",
                                 @"description" : @"I am using Partake to find fun activities near me to enjoy with others. You should check it out.",
                                 @"picture"     : kCLPartakeAppLogoURL,
                                 @"link"        : kCLPartakeShareURL,
                                 };
        [FBWebDialogs presentFeedDialogModallyWithSession:session parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if (error) {
                NSLog(@"Error sharing via feed dialog - %@", error);
            } else if (result == FBWebDialogResultDialogCompleted) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thank you for sharing!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [[CLApiClient sharedInstance] userDidShare:nil on:kCLSharePlatformFacebook successBlock:nil failureBlock:nil];
            }
        }];
    } else {
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:NO fromViewController:self completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Error opening facebook. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                [self facebookAction:nil];
            }
        }];
    }
     */
}

- (IBAction)twitterAction:(id)sender {
    _sharer = [SHKTwitter shareItem:_shareItem];
    sharePlatform = kCLSharePlatformTwitter;
}

- (IBAction)mailAction:(id)sender {
    _sharer = [SHKMail shareItem:_shareItem];
    sharePlatform = kCLSharePlatformEMail;
}

- (IBAction)smsAction:(id)sender {
    _sharer = [SHKTextMessage shareItem:_shareItem];
    sharePlatform = kCLSharePlatformSMS;
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
