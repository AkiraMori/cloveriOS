//
//  CLObjectRequestOperation.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLObjectRequestOperation.h"

@implementation CLApiErrorDetector

@synthesize data = _data;
@synthesize JSON = _JSON;

- (id)initWithData:(NSData *)data
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _data = data;
    
    return self;
}

- (id)initWithJSON:(id)JSON
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _JSON = JSON;
    
    return self;
}

- (NSError *)detect
{
    if (!_data && !_JSON) {
        return nil;
    }
    
    NSError *parsingError;
    
    if (!_JSON) {
        _JSON = [NSJSONSerialization JSONObjectWithData:_data
                                                options:0
                                                  error:&parsingError];
    }
    
    if (parsingError) {
        return [NSError errorWithDomain:kCLClientErrorDomain
                                   code:CLClientErrorCodeResponseParsing
                               userInfo:nil];
    }
    
//    NSString *errorsKey = @"error";
//    
//    if ([_JSON objectForKey:errorsKey] && _JSON[errorsKey]) {
//        
//        kCLApiErrorCodes code = [_JSON[errorsKey][@"code"] intValue];
//        
//        NSMutableDictionary *userInfo          = [NSMutableDictionary new];
//        userInfo[NSLocalizedDescriptionKey]    = _JSON[errorsKey][@"description"];
//        userInfo[kCLApiErrorHTTPStatusCodeKey] = [NSNumber numberWithInt:[_JSON[errorsKey][@"http_status_code"] intValue]];
//        
//        return [NSError errorWithDomain:kCLApiErrorDomain
//                                   code:code
//                               userInfo:userInfo];
//    }
    
    return nil;
}

@end

@implementation CLObjectRequestOperation

//- (void)setCompletionBlockWithSuccess:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success
//                              failure:(void (^)(RKObjectRequestOperation *, NSError *))failure {
//    
//    __unsafe_unretained id weakSelf = self;
//    
//    [super setCompletionBlockWithSuccess:^void(RKObjectRequestOperation *operation , RKMappingResult *mappingResult) {
//        
//        if (success) {
//            success(operation, mappingResult);
//        }
//    } failure:^void(RKObjectRequestOperation *operation , NSError *error) {
//        
//        if (operation.HTTPRequestOperation.response.statusCode == 401 &&
//            ![operation.HTTPRequestOperation.response.allHeaderFields objectForKey:@"-riderr-login"]) {
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationLoggedPersonRevoked
//                                                                object:operation];
//        }
//        
//        if (failure) {
//            [weakSelf handleFailureWithErrorDetector:[[CLApiErrorDetector alloc] initWithData:operation.HTTPRequestOperation.responseData]
//                                               error:error
//                                     completionBlock:^(NSError *error) {
//                                         failure(operation, error);
//                                     }];
//        }
//    }];
//}
//
//- (void)handleFailureWithErrorDetector:(BKAPIErrorDetector *)errorDetector
//                                 error:(NSError *)error
//                       completionBlock:(void (^)(NSError *error))completion
//{
//    NSError *serverError = [errorDetector detect];
//    
//    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
//        error = [NSError errorWithDomain:kCLClientErrorDomain
//                                    code:RRClientErrorCodeOperationCanceled
//                                userInfo:nil];
//    }
//    
//    //    if (serverError && [serverError.domain isEqualToString:kRiderrAPIErrorDomain]) {
//    //        switch (serverError.code) {
//    //            case RRAPIErrorCodeAuthorizationInvalidToken:
//    //                [[NSNotificationCenter defaultCenter] postNotificationName:kRiderrNotifciationAccessTokenInvalid object:nil];
//    //                break;
//    //        }
//    //    }
//    
//    completion(serverError ? serverError : error);
//}

@end
