//
//  CLRequest+ModelController.h
//  Partake
//
//  Created by Maikel on 28/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLRequest.h"

@interface CLRequest (ModelController)

+ (void)allRequestsForLoggedUser:(void (^)(NSArray *))requests;

+ (void)requestForActivityId:(NSString *)activityId
                  withUserId:(NSString *)userId
         withCompletionBlock:(void (^)(CLRequest *))response;

+ (CLRequest *)getRequestById:(NSString *)requestId;

- (CLUser *)theOtherUser;

@end
