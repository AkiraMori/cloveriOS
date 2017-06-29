//
//  CLAmazonManager.h
//  Partake
//
//  Created by technophyle on 9/21/16.
//  Copyright © 2016 CodigoDelSur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSS3/AWSS3.h>

@interface CLAmazonManager : NSObject

+ (instancetype)sharedInstance;

- (void)downloadFileFromS3:(NSString *)fileName;
- (void)uploadFileToS3:(NSURL *)fileURL
          successBlock:(void (^)(NSArray *))success
          failureBlock:(void (^)(NSError *))failure;

@end
