//
//  CLRequest+ModelController.m
//  Partake
//
//  Created by Maikel on 28/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLRequest+ModelController.h"
#import "CLUser+ModelController.h"
#import "CLActivity+ModelController.h"


@implementation CLRequest (ModelController)

+ (void)allRequestsForLoggedUser:(void (^)(NSArray *))requests
{
    [[CLApiClient sharedInstance] requestsForLoggedUserWithSuccessBlock:^(NSArray *result) {
        
        requests(result);
        
    } failureBlock:^(NSError *error) {
        
        DDLogError(@"Error: Cannot get Requests for this user.");
        
    }];
}

+ (void)requestForActivityId:(NSString *)activityId
                  withUserId:(NSString *)userId
         withCompletionBlock:(void (^)(CLRequest *))response
{
    [self allRequestsForLoggedUser:^(NSArray *result) {
        
        for (CLRequest *request in result) {
            
            if ([request.activityId isEqualToString:activityId] && [request.theOtherUser.userId isEqualToString:userId]) {
                
                response(request);
                
                return;
                
            }
            
        };
        
        response(nil);
    }];
}

+ (CLRequest *)getRequestById:(NSString *)requestId
{
    NSManagedObjectContext *moc     = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    NSFetchRequest         *request = [NSFetchRequest new];
    
    NSEntityDescription    *entity  = [NSEntityDescription entityForName:@"CLRequest"
                                                  inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestId ==[c] %@", requestId];
    
    [request    setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *array = [moc executeFetchRequest:request
                                        error:&error];
    
    if (array != nil && array.count > 0) {
        
        return [array firstObject];
        
    }
    
    return nil;
}

- (CLUser *)theOtherUser
{
    if ([self.userId isEqualToString:[CLApiClient sharedInstance].loggedUser.userId]) {
        return self.activityCreator;
    }
    
    return self.user;
}

- (NSString *)activityName
{
    [self willAccessValueForKey:@"activityName"];
    
    NSString *activityName = [self primitiveValueForKey:@"activityName"];
    
    [self didAccessValueForKey:@"activityName"];
    
    return [activityName uppercaseString];
}
@end
