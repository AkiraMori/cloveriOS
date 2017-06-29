//
//  CLQuickBloxManager.h
//  Partake
//
//  Created by Maikel on 03/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

typedef void (^CLQuickBloxCompletionBlock)(NSError *error, NSArray *results);


@interface CLQuickBloxManager : NSObject

@property (strong, nonatomic) QBUUser *currentUser;

+ (CLQuickBloxManager *)sharedManager;

- (void)loginQuickBlox:(void(^)(NSError *error))completion;
- (void)sendDeviceTokenToQuickBlox;
- (void)getTotalUnreadMessagesCountWithCompletionBlock:(void(^)(NSUInteger count, NSError *error))completion;

@end
