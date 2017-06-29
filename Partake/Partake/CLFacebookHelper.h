//
//  CLFacebookHelper.h
//  Partake
//
//  Created by Pablo Episcopo on 3/3/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLConstants.h"

@interface CLFacebookHelper : NSObject

+ (NSString *)facebookAppId;

+ (NSArray *)readPermissions;
+ (NSArray *)publishPermissions;

+ (NSURL *)profilePictureURLWithFacebookId:(NSString *)facebookId
                                 imageType:(CLFacebookImageType)imageType;

+ (void)facebookMutualFriendForFacebookId:(NSString *)facebookId
                             successBlock:(void (^)(NSArray *result))success
                             failureBlock:(void (^)(NSError *error))failure;

+ (void)getUserProfilePhotosWithCompletion:(void(^)(NSArray *photos))completion;

//+ (void)openActiveSessionWithPublishPermissions:(void(^)(FBSession *session, NSError *error))completion;
@end
