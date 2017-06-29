//
//  CLFacebookHelper.m
//  Partake
//
//  Created by Pablo Episcopo on 3/3/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLFacebookHelper.h"

@implementation CLFacebookHelper

+ (NSString *)facebookAppId {
    return @"1631003883784855";
}

+ (NSArray *)readPermissions
{
    return @[
             @"email",
             @"public_profile",
             @"user_birthday",
             @"user_friends",
             @"user_about_me",
             @"user_photos"
             ];
}

+ (NSArray *)publishPermissions
{
    return @[
             @"publish_actions"
             ];
}

+ (NSURL *)profilePictureURLWithFacebookId:(NSString *)facebookId
                                 imageType:(CLFacebookImageType)imageType
{
    NSString *imageTypeParam;
    
    switch (CLFacebookImageTypeLarge) {
        case 0:
            imageTypeParam = @"square";
            break;
        case 1:
            imageTypeParam = @"small";
            break;
        case 2:
            imageTypeParam = @"normal";
            break;
        case 3:
            imageTypeParam = @"large";
            break;
    }
    
    NSString *profilePictureURL = [NSString stringWithFormat:kCLFacebookGraphProfilePictureURL, facebookId, imageTypeParam];
    
    return [NSURL URLWithString:profilePictureURL];
}

+ (void)facebookMutualFriendForFacebookId:(NSString *)facebookId
                             successBlock:(void (^)(NSArray *result))success
                             failureBlock:(void (^)(NSError *error))failure
{
    [[CLApiClient sharedInstance] mutualFriendsForUserWithFacebookId:facebookId
                                                        successBlock:^(NSArray *result) {
                                                            
                                                            success(result);
                                                    
                                                        }
                                                        failureBlock:^(NSError *error) {
                                                            
                                                            failure(error);
                                                            
                                                        }];
}


+ (void)getUserProfilePhotosWithCompletion:(void(^)(NSArray *photos))completion {
    if (!completion) {
        return;
    }
    
    //request albums
    FBSDKGraphRequest *requestAlbums = [[FBSDKGraphRequest alloc]
                                        initWithGraphPath:@"me/albums"
                                        parameters:nil
                                        HTTPMethod:@"GET"];
    [requestAlbums startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id resultAlbums,
                                          NSError *error) {
        
        NSString *profileAlbumID = nil;
        
        //find "Profile Pictures" album (type = profile)
        for (NSDictionary *album in resultAlbums[@"data"])
        {
            profileAlbumID = album[@"id"];

            if ([album[@"type"] isEqualToString:@"profile"])
            {
                break;
            }
        }
        
        if (profileAlbumID)
        {
            //request photos from the profile album
            FBSDKGraphRequest *requestPhotos = [[FBSDKGraphRequest alloc] initWithGraphPath:[NSString stringWithFormat:@"%@/photos", profileAlbumID] parameters:nil
                                                                                 HTTPMethod:@"GET"];

            [requestPhotos startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                        id resultPhotos,
                                                        NSError *errorPhotos) {

                if (errorPhotos) {
                    
                    NSLog(@"Error fetching facebook profile photos - %@", errorPhotos.userInfo[@"error"]);
                    completion(nil);
                    
                } else {
                    
                    NSMutableArray *photos = [NSMutableArray array];
                    for (NSDictionary *photoNode in resultPhotos[@"data"]) {
                        [photos addObject:[CLProfilePhoto photoWithFacebookPhotoNode:photoNode]];
                    }
                    
                    completion(photos);
                }
                
            }];
            
        } else {
            completion(nil);
        }
    }];
}
/*
+ (void)openActiveSessionWithPublishPermissions:(void (^)(FBSession *, NSError *))completion {
    FBSession *session = [FBSession activeSession];
    
    if (session.isOpen) {
        void (^finalBlock)(FBSession *, NSError *) = ^(FBSession *session, NSError *error) {
            if (![session.accessTokenData.accessToken isEqualToString:[CLApiClient sharedInstance].loggedUser.fbUserToken]) {
                [self updateAccessTokenInBackground:nil];
            }
            if (completion) {
                completion(session, nil);
            }
        };
        
        if ([session.permissions containsObject:@"publish_actions"]) {
            finalBlock(session, nil);
        } else {
            [session requestNewPublishPermissions:[CLFacebookHelper publishPermissions]
                                  defaultAudience:FBSessionDefaultAudienceEveryone
                                completionHandler:^(FBSession *session, NSError *error) {
                                    finalBlock(session, error);
                                }];
        }
        
    } else {
        [FBSession openActiveSessionWithPublishPermissions:[CLFacebookHelper publishPermissions]
                                           defaultAudience:FBSessionDefaultAudienceEveryone
                                              allowLoginUI:YES
                                        fromViewController:session.fromViewController
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             [self openActiveSessionWithPublishPermissions:completion];
                                         }];
    }
}

+ (void)updateAccessTokenInBackground:(void(^)(NSError *))completion {
    CLLoggedUser *loggedUser = [CLApiClient sharedInstance].loggedUser;
    
    [[CLApiClient sharedInstance] loginWithFbId:loggedUser.fbUserId
                                        fbToken:[FBSession activeSession].accessTokenData.accessToken
                                      firstName:nil
                                       lastName:nil
                                          email:nil
                                         gender:loggedUser.gender
                                            age:loggedUser.age.stringValue
                                   successBlock:^(BOOL isNewUser, NSArray *result) {
                                          if (completion) {
                                              completion(nil);
                                          }
                                      } failureBlock:^(NSError *error) {
                                          if (completion) {
                                              completion(error);
                                          }
                                      }];
}
 */
@end
