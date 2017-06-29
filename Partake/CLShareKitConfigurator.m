//
//  CLShareKitConfigurator.m
//  Partake
//
//  Created by Maikel on 03/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLShareKitConfigurator.h"
#import "CLFacebookHelper.h"

@implementation CLShareKitConfigurator
- (NSString*)facebookAppId {
    return @"1631003883784855";
}

- (NSString*)facebookLocalAppId {
    return @"";
}

- (NSNumber*)forcePreIOS6FacebookPosting {
    return [NSNumber numberWithBool:true];
}
//
//- (NSArray*)facebookWritePermissions {
//    return nil;
//}
//
//- (NSArray*)facebookReadPermissions {
//    return [CLFacebookHelper readPermissions];
//}

- (NSString*)twitterConsumerKey {
    return @"zcbEuCg80CU8f3u1qlZ9HeZAa";
}

- (NSString*)twitterSecret {
    return @"hzh0oAXdWaUaXG073bpjmO2dqKlO8hP8EaNWgPBtj3MSM2tgq7";
}

- (NSString*)twitterCallbackUrl {
    return @"http://partake.twitter.com";
}

- (NSNumber*)twitterUseXAuth {
    return [NSNumber numberWithInt:0];
}

- (NSString*)twitterUsername {
    return @"";
}

- (NSNumber *)useAppleShareUI {
    return @YES;
}
@end
