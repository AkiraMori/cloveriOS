//
//  CLAmazonManager.m
//  Partake
//
//  Created by technophyle on 9/21/16.
//  Copyright © 2016 CodigoDelSur. All rights reserved.
//

#import "CLAmazonManager.h"
#import "CLConstants.h"

@implementation CLAmazonManager

+ (instancetype)sharedInstance {
    static CLAmazonManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self setupAmazonConfiguration];
    }
    
    return self;
}

- (void)setupAmazonConfiguration {
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSWest2
                                                          identityPoolId:kCLAmazonCognitoIdentityPool];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

- (void)downloadFileFromS3:(NSString *)fileName {
    
    // Construct the NSURL for the download location.
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"computer-freak.jpg"];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = kCLAmazonS3Bucket;
    downloadRequest.key = [kCLAmazonS3ProjectFolder stringByAppendingString:@"/computer-freak.jpg"];
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    // Download the file.
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error){
                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                       switch (task.error.code) {
                                                                           case AWSS3TransferManagerErrorCancelled:
                                                                           case AWSS3TransferManagerErrorPaused:
                                                                               break;
                                                                               
                                                                           default:
                                                                               NSLog(@"Error: %@", task.error);
                                                                               break;
                                                                       }
                                                                   } else {
                                                                       // Unknown error.
                                                                       NSLog(@"Error: %@", task.error);
                                                                   }
                                                               }
                                                               
                                                               if (task.result) {
                                                                   //AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                   //File downloaded successfully.
                                                               }
                                                               return nil;
                                                           }];
}

- (void)uploadFileToS3:(NSURL *)fileURL
          successBlock:(void (^)(NSArray *))success
          failureBlock:(void (^)(NSError *))failure {
    
    //NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"computer-freak.jpg"];
    //NSURL *uploadingFileURL = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kCLAmazonS3Bucket;
    uploadRequest.key = [kCLAmazonS3ProjectFolder stringByAppendingString:@"/test.jpg"];
    uploadRequest.body = fileURL;
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               //AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               // The file uploaded successfully.
                                                           }
                                                           return nil;
                                                       }];
    
}

@end
