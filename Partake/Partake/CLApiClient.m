//
//  CLApiClient.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLRequest.h"
#import "CLApiClient.h"
#import "CLConstants.h"
#import "CLObjectManager.h"
#import "CLMappingProtocol.h"
#import "CLLocationActivity.h"
#import "CLObjectRequestOperation.h"
#import "CLActivity+ModelController.h"
#import "CLLocationManagerController.h"

static CLApiClient * instance = nil;

@interface CLApiClient ()

@property (strong, nonatomic) NSManagedObjectContext *scratchManagedObjectContext;
@property (strong, nonatomic) CLLoggedUser           *loggedUser;

@end

@implementation CLApiClient

@synthesize loggedUser = _loggedUser;

+ (CLApiClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[CLApiClient alloc] initWithBaseUrl:[NSURL URLWithString:kCLEndpoint]
                                     managedObjectStore:[CLDatabaseManager sharedInstance].objectStore];
    });
    
    return instance;
}

- (void)removeInstance
{
    instance = nil;
}

- (id)initWithBaseUrl:(NSURL *)baseUrl managedObjectStore:(RKManagedObjectStore *)objectStore
{
    self = [super init];
    
    if (self) {
        _manager                              = [CLObjectManager managerWithBaseURL:baseUrl];
        _manager.managedObjectStore           = objectStore;
        _manager.requestSerializationMIMEType = RKMIMETypeJSON;
        
        [_manager registerRequestOperationClass:[CLObjectRequestOperation class]];
        
        [RKObjectManager setSharedManager:_manager];
        
        [self setupReachability];
        [self performSetupWithClasses:@[
                                        [CLUser              class],
                                        [CLActivity          class],
                                        [CLLocationActivity  class],
                                        [CLRequest           class]
                                        ]];
    }
    
    return self;
}

- (CLLoggedUser *)loggedUser
{
    if (!self->_loggedUser) {
        
        self->_loggedUser = [CLLoggedUser loggedUserFromDisk];
        
    }
    
    return self->_loggedUser;
}

- (void)setupReachability
{
    __weak CLApiClient *weakSelf = self;
    [_manager.HTTPClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [weakSelf.manager.operationQueue setSuspended:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationIsReachable object:nil];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [weakSelf.manager.operationQueue cancelAllOperations];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCLNotificationIsNotReachable object:nil];
                break;
        }
    }];
}

- (void)performSetupWithClasses:(NSArray *)classes
{
    if (classes.count > 0) {
        
        [classes enumerateObjectsUsingBlock:^(id <CLMappingProtocol>obj, NSUInteger idx, BOOL *stop) {
            
            [self.manager addRequestDescriptorsFromArray:[obj requestDescriptors]];
            [self.manager addResponseDescriptorsFromArray:[obj responseDescriptors]];
            
            [self.manager.router.routeSet addRoutes:[obj routes]];
            
            if ([obj respondsToSelector:@selector(fetchRequestCleaners)]) {
                
                [[obj fetchRequestCleaners] enumerateObjectsUsingBlock:^(id block, NSUInteger idx, BOOL *stop) {
                    
                    [self.manager addFetchRequestBlock:block];
                    
                }];
            }
        }];
        [self.manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[[RKObjectMapping alloc] init] method:RKRequestMethodPOST pathPattern:@"/report" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    }
}

- (void)setAuthHeaderWithAccessToken:(NSString *)accessToken
{
    [self.manager.HTTPClient setDefaultHeader:@"fbtoken"
                                        value:accessToken];
}

- (void)setAuthGuestToken:(NSString *)guestToken
{
    [self.manager.HTTPClient setDefaultHeader:@"GuestToken"
                                        value:guestToken];
}

- (void)cancelAllRequests
{
    [self.manager.operationQueue cancelAllOperations];
}

- (BOOL)isReachable
{
    return self.manager.HTTPClient.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable;
}

- (BOOL)isLoggedIn
{
    //return (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.isOpen) && self.loggedUser;
    return [FBSDKAccessToken currentAccessToken] && self.loggedUser;
}

#pragma mark - User Methods

- (void)userWithId:(NSString *)userId
      successBlock:(void (^)(NSArray *))success
      failureBlock:(void (^)(NSError *))failure
{
    NSAssert(userId, @"Error: User ID to search could not be nil.");
    
    DDLogInfo(@"Getting user for ID: %@", userId);
    
    NSString *path = [@"/users/" stringByAppendingString:userId];
    
    [self getTemporaryObjectsWithPath:path
                    keepActualContext:YES
                         successBlock:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             
                             success(mappingResult.array);
                             
                         }
                         failureBlock:^(RKObjectRequestOperation *operation, NSError *error) {
                             
                             failure(error);
                             
                         }];
}

- (void)loginWithFbId:(NSString *)fbId
              fbToken:(NSString *)fbToken
            firstName:(NSString *)firstName
             lastName:(NSString *)lastName
                email:(NSString *)email
               gender:(NSString *)gender
                  age:(NSString *)age
         successBlock:(void (^)(BOOL, NSArray *))success
         failureBlock:(void (^)(NSError *))failure
{
    NSAssert(fbId,      @"Error: fbId parameter could not be nil.");
    NSAssert(fbToken,   @"Error: fbToken parameter could not be nil.");
//    NSAssert(firstName, @"Error: firstName parameter could not be nil.");
//    NSAssert(lastName,  @"Error: lastName parameter could not be nil.");
//    NSAssert(email,     @"Error: email parameter could not be nil.");
//    NSAssert(gender,    @"Error: gender parameter could not be nil.");
//    NSAssert(age,       @"Error: age parameter could not be nil.");
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:fbId    forKey:@"fbId"];
            [params setObject:fbToken forKey:@"fbToken"];
            [params setObject:(gender ? gender : @"male") forKey:@"gender"];
            [params setObject:(age    ? age    : @0)      forKey:@"age"];
            if (firstName.length) {
                [params setObject:firstName forKey:@"firstName"];
            }
            if (lastName.length) {
                [params setObject:lastName forKey:@"lastName"];
            }
            if (email.length) {
                [params setObject:email forKey:@"email"];
            }
            
            [self.manager postObject:nil
                                path:@"/user/login"
                          parameters:params
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 NSString     *userId   = [mappingResult.array.firstObject userId];
                                 [self updateLoggedUserWithUserId:userId];
                                 
                                 success(operation.HTTPRequestOperation.response.statusCode == 201, mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)mutualFriendsForUserWithFacebookId:(NSString *)facebookId
                              successBlock:(void (^)(NSArray *))success
                              failureBlock:(void (^)(NSError *))failure
{
    NSAssert(facebookId, @"Error: Facebook ID could not be nil.");
    
    DDLogInfo(@"Getting mutual friend with user with Facebook ID: %@", facebookId);
    
    NSString *path = [@"/user/mutualFriends?fbId=" stringByAppendingString:facebookId];
    
    [self getTemporaryObjectsWithPath:path
                    keepActualContext:YES
                         successBlock:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             
                             success(mappingResult.array);
                             
                         }
                         failureBlock:^(RKObjectRequestOperation *operation, NSError *error) {
                             
                             failure(error);
                             
                         }];
}

- (void)blockUserWithFbId:(NSString *)fbIdToBlock
             successBlock:(void (^)(NSArray *))success
             failureBlock:(void (^)(NSError *))failure
{
    NSAssert(fbIdToBlock, @"Error: FacebookId to block could not be nil.");
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [self.manager postObject:nil
                                path:@"/user/blockUser"
                          parameters:@{
                                       @"userFbIdToBlock": fbIdToBlock,
                                       @"userFbIdBlocker": [CLApiClient sharedInstance].loggedUser.fbUserId
                                       }
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 [[CLApiClient sharedInstance].loggedUser saveToDisk];
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)reportUserWithFbId:(NSString *)fbIdToReport
                    reason:(NSString *)reason
                  comments:(NSString *)comments
              successBlock:(void (^)(NSArray *result))success
              failureBlock:(void (^)(NSError *error))failure
{
    NSAssert(fbIdToReport, @"Error: FacebookId to report could not be nil.");
    NSAssert(reason, @"Error: You can't block a user with no reason.");
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [self.manager postObject:nil
                                path:@"/report"
                          parameters:@{
                                       @"userToReportId"    : fbIdToReport,
                                       @"userReporterId"    : [CLApiClient sharedInstance].loggedUser.fbUserId,
                                       @"reason"            : reason,
                                       @"additionalComments": comments ? comments : [NSNull null]
                                       }
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)saveUserDefaultPreferences:(NSInteger)searchDistanceLimit
                         CreatedBy:(NSString *)createdBy
                           AgeFrom:(NSInteger)ageFrom
                             AgeTo:(NSInteger)ageTo
                      successBlock:(void (^)(NSArray *))success
                      failureBlock:(void (^)(NSError *))failure
{
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [self.manager postObject:nil
                                path:@"/user/saveDefaultPreferences"
                          parameters:@{
                                       @"fbId" : [CLApiClient sharedInstance].loggedUser.fbUserId,
                                       @"default_limit_search_results"  : @(searchDistanceLimit),
                                       @"default_activities_created_by" : createdBy,
                                       @"default_activities_age_from"   : @(ageFrom),
                                       @"default_activities_age_to"     : @(ageTo)
                                       }
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 NSString     *userId   = [mappingResult.array.firstObject userId];
                                 [self updateLoggedUserWithUserId:userId];
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)resetUserBadgeInBackground {
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [self.manager postObject:nil
                                path:@"/user/resetBadge"
                          parameters:@{
                                       @"fbId" : [CLApiClient sharedInstance].loggedUser.fbUserId,
                                       }
                             success:nil
                             failure:nil];
            
        }
    }];
}

- (void)editUserProfileAboutMe:(NSString *)aboutMe
                      Pictures:(NSArray *)pictures
                  successBlock:(void (^)(NSArray *))success
                  failureBlock:(void (^)(NSError *))failure
{
    NSAssert(aboutMe || pictures, @"Must provide at least one parameter for update.");
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            
            [params setObject:[CLApiClient sharedInstance].loggedUser.userId forKey:@"id"];
            if (pictures) {
                [params setObject:pictures forKey:@"pictures"];
            }
            if (aboutMe) {
                [params setObject:aboutMe forKey:@"aboutMe"];
            }
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager postObject:nil
                                path:@"/user/edit"
                          parameters:params
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 NSString     *userId   = [mappingResult.array.firstObject userId];
                                 [self updateLoggedUserWithUserId:userId];
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)registerDeviceToken:(NSString *)deviceToken
                enableAlert:(BOOL)enableAlert
               successBlock:(void (^)(void))success
               failureBlock:(void (^)(NSError *))failure
{
    NSAssert(deviceToken, @"Error: Device Token could not be nil.");
    
    [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
    
    NSMutableURLRequest *request = [self.manager requestWithObject:nil
                                                            method:RKRequestMethodPOST
                                                              path:@"/user/registerDevice"
                                                        parameters:@{
                                                                     @"fbId" : self.loggedUser.fbUserId,
                                                                     @"device_token" : deviceToken,
                                                                     @"enable_alert" : @(enableAlert)
                                                                     }];
    
    RKObjectRequestOperation *operation = [self.manager objectRequestOperationWithRequest:request
                                                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                      
                                                                                      success();
                                                                                      
                                                                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                      
                                                                                      failure(error);
                                                                                      
                                                                                  }];
    
    [operation start];

}


- (void)deactivateUserAccountWithSuccessBlock:(void (^)(void))success
                                 failureBlock:(void (^)(NSError *))failure
{
    
    [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
    
    NSMutableURLRequest *request = [self.manager requestWithObject:nil
                                                            method:RKRequestMethodDELETE
                                                              path:@"/user"
                                                        parameters:@{
                                                                     @"fbId" : self.loggedUser.fbUserId,
                                                                     }];
    
    RKObjectRequestOperation *operation = [self.manager objectRequestOperationWithRequest:request
                                                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                      
                                                                                      success();
                                                                                      
                                                                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                      
                                                                                      failure(error);
                                                                                      
                                                                                  }];
    
    [operation start];
    
}


#pragma mark - Activity Methods

- (void)activitiesWithCoordinates:(CLLocationCoordinate2D)coordinates
                     successBlock:(void (^)(NSArray *))success
                     failureBlock:(void (^)(NSError *))failure
{
    NSAssert(coordinates.latitude,  @"Error: Latitude value could not be nil.");
    NSAssert(coordinates.longitude, @"Error: Longitude value could not be nil.");
    
    DDLogInfo(@"Getting activities for coordinates: Lat: %f - Lon: %f", coordinates.latitude, coordinates.longitude);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            failure(error);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            CGFloat lat = coordinates.latitude;
            CGFloat lon = coordinates.longitude;
            
#if DEVELOPMENT
            lat = 39;
            lon = -77;
#endif
            
            NSString *path = [NSString stringWithFormat:@"/activity?lat=%f&lon=%f&userAge=%@&userGender=%@&fbId=%@",
                              lat,
                              lon,
#ifdef DEVELOPMENT
                              @(25),
#else
                              [self.loggedUser.age stringValue],
#endif
                              self.loggedUser.gender,
                              self.loggedUser.fbUserId];
            
            DDLogInfo(@"/activity?lat=%f&lon=%f&userAge=%@&userGender=%@&fbId=%@",
                      lat,
                      lon,
#ifdef DEVELOPMENT
                      @(25),
#else
                      [self.loggedUser.age stringValue],
#endif
                      self.loggedUser.gender,
                      self.loggedUser.fbUserId);
            
            [self.manager getObject:nil
                               path:path
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                
                                [mappingResult.array enumerateObjectsUsingBlock:^(CLActivity *activity, NSUInteger idx, BOOL *stop) {
                                    
                                    [activity setDistanceBasedOnRange];
                                    
                                }];
                                
                                success(mappingResult.array);

                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                
                                failure(error);
                                
                            }];
        }
    }];
}

- (void)activityWithId:(NSString *)activityId
          successBlock:(void (^)(NSArray *))success
          failureBlock:(void (^)(NSError *))failure
{
    NSAssert(activityId, @"Error: Activity ID to search could not be nil.");
    
    DDLogInfo(@"Getting activity for ID: %@", activityId);
    
    NSString *path = [NSString stringWithFormat:@"/activity/%@?fbId=%@", activityId, self.loggedUser.fbUserId];
    
    [self.manager getObject:nil
                       path:path
                 parameters:nil
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        
                        [mappingResult.array enumerateObjectsUsingBlock:^(CLActivity *activity, NSUInteger idx, BOOL *stop) {
                            
                            [activity setDistanceBasedOnRange];
                            
                        }];
                        
                        success(mappingResult.array);
                        
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        
                        failure(error);
                        
                    }];
}

- (void)searchActivitiesWithText:(NSString *)searchText
                     coordinates:(CLLocationCoordinate2D)coordinates
                           limit:(NSInteger)limit
                          offset:(NSInteger)offset
                    successBlock:(void (^)(NSArray *))success
                    failureBlock:(void (^)(NSError *))failure
{
    NSAssert(searchText, @"Error: Text to search could not be nil.");
    
    DDLogInfo(@"Searching activities for string: %@", searchText);
    
    CGFloat lat = coordinates.latitude;
    CGFloat lon = coordinates.longitude;
#if DEVELOPMENT
    lat = 39;
    lon = -77;
#endif
    NSString *path = [NSString stringWithFormat:@"/activity/findByQuery?q=%@&lat=%f&lon=%f&limit=%li&offset=%li&fbId=%@",
                      searchText,
                      (float)lat,
                      (float)lon,
                      (long)limit,
                      (long)offset,
                      self.loggedUser.fbUserId];
    
    [self getTemporaryObjectsWithPath:path
                    keepActualContext:NO
                         successBlock:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

                             success(mappingResult.array);
                             
                         }
                         failureBlock:^(RKObjectRequestOperation *operation, NSError *error) {
                             
                             failure(error);
                             
                         }];
}

- (void)searchActivitiesWithTypes:(NSArray *)types
                      coordinates:(CLLocationCoordinate2D)coordinates
                       viewableBy:(NSString *)viewableBy
                         dayStart:(NSInteger)dayStart
                           dayEnd:(NSInteger)dayEnd
                     successBlock:(void (^)(NSArray *))success
                     failureBlock:(void (^)(NSError *))failure
{
    NSAssert(coordinates.latitude, @"Error: Text to search could not be nil.");
    NSAssert(coordinates.longitude, @"Error: Text to search could not be nil.");
    NSAssert(types, @"Error: Array could not be nil.");
    NSAssert(viewableBy, @"Error: Text to search could not be nil.");
    NSAssert(dayStart, @"Error: Text to search could not be nil.");
    NSAssert(dayEnd, @"Error: Text to search could not be nil.");
    
    DDLogInfo(@"Searching activities with filters: Lat: %f - Lon: %f - Type: %@ - ViewableBy: %@ - DayStart: %li - DayEnd: %li",
              coordinates.latitude,
              coordinates.longitude,
              types,
              viewableBy,
              dayStart,
              dayEnd);
    
    CGFloat lat = coordinates.latitude;
    CGFloat lon = coordinates.longitude;
    
#if DEVELOPMENT
    lat = 39;
    lon = -77;
#endif
    
    __block NSString *typesUrl = @"";
    
    [types enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
        type = [type stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        type = [type stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        
        NSString *string = [NSString stringWithFormat:@"&type%li=%@", (idx + 1), type];
        
        typesUrl = [typesUrl stringByAppendingString:string];
    }];
    
    NSString *path = [NSString stringWithFormat:@"/activity?lat=%f&lon=%f&type=%@&createdBy=%@&dayStart=%li&dayEnd=%li&userAge=%@&userGender=%@&fbId=%@",
                      lat,
                      lon,
                      typesUrl,
                      viewableBy,
                      dayStart > 0 ? dayStart - 1 : dayStart,
                      dayEnd,
#ifdef DEVELOPMENT
                      @(25),
#else
                      [self.loggedUser.age stringValue],
#endif
                      self.loggedUser.gender,
                      self.loggedUser.fbUserId];
    
    [self getTemporaryObjectsWithPath:path
                    keepActualContext:NO
                         successBlock:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             
                             DDLogInfo(@"Success fetching filtered items - %lu\nStatus Code : %lu", mappingResult.array.count, operation.HTTPRequestOperation.response.statusCode);
                             
                             success(mappingResult.array);
                             
                         }
                         failureBlock:^(RKObjectRequestOperation *operation, NSError *error) {
                             
                             DDLogError(@"Error fetching filtered items - %@", error);
                             
                             failure(error);
                             
                         }];
}

- (void)createActivityWithCreaterId:(NSString *)creatorId
                               date:(NSString *)date
                            endDate:(NSString *)endDate
                               name:(NSString *)name
                            details:(NSString *)details
                               type:(NSString *)type
                           fromTime:(NSString *)fromTime
                             toTime:(NSString *)toTime
                            address:(NSString *)address
                         visibility:(NSString *)visibility
                             gender:(NSString *)gender
                      ageFilterFrom:(NSNumber *)ageFilterFrom
                        ageFilterTo:(NSNumber *)ageFilterTo
                   isAtendeeVisible:(BOOL)isAtendeeVisible
                       successBlock:(void (^)(NSArray *))success
                       failureBlock:(void (^)(NSError *))failure
{
    NSAssert(creatorId,        @"Error: creatorId type parameter could not be nil.");
    NSAssert(date,             @"Error: date type parameter could not be nil.");
    NSAssert(name,             @"Error: name type parameter could not be nil.");
    NSAssert(details,          @"Error: details type parameter could not be nil.");
    NSAssert(type,             @"Error: type type parameter could not be nil.");
    NSAssert(fromTime,         @"Error: fromTime type parameter could not be nil.");
    NSAssert(toTime,           @"Error: toTime type parameter could not be nil.");
    NSAssert(address,          @"Error: address type parameter could not be nil.");
    NSAssert(gender,           @"gender: CLUser type parameter could not be nil.");
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [self.manager postObject:nil
                                path:@"/activity"
                          parameters:@{
                                       @"creator":          creatorId,
                                       @"date":             date,
                                       @"endDate":          endDate,
                                       @"name":             name,
                                       @"details":          details,
                                       @"type":             type,
                                       @"fromTime":         fromTime,
                                       @"toTime":           toTime,
                                       @"address":          address,
                                       @"visibility":       visibility,
                                       @"gender":           gender,
                                       @"age_filter_from":  ageFilterFrom,
                                       @"age_filter_to":    ageFilterTo,
                                       @"isAtendeeVisible": @(isAtendeeVisible)
                                       }
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                                 [mappingResult.array.firstObject setDistanceBasedOnRange];
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)editActivityWithCreaterId:(NSString *)creatorId
                             date:(NSString *)date
                          endDate:(NSString *)endDate
                             name:(NSString *)name
                          details:(NSString *)details
                             type:(NSString *)type
                         fromTime:(NSString *)fromTime
                           toTime:(NSString *)toTime
                          address:(NSString *)address
                       visibility:(NSString *)visibility
                           gender:(NSString *)gender
                    ageFilterFrom:(NSNumber *)ageFilterFrom
                      ageFilterTo:(NSNumber *)ageFilterTo
                 isAtendeeVisible:(BOOL)isAtendeeVisible
                    addressEdited:(BOOL)addressEdited
                       activityId:(NSString *)activityId
                       locationId:(NSString *)locationId
                     successBlock:(void (^)(NSArray *result))success
                     failureBlock:(void (^)(NSError *error))failure;
{
    NSAssert(creatorId,        @"Error: creatorId type parameter could not be nil.");
    NSAssert(date,             @"Error: date type parameter could not be nil.");
    NSAssert(name,             @"Error: name type parameter could not be nil.");
    NSAssert(details,          @"Error: details type parameter could not be nil.");
    NSAssert(type,             @"Error: type type parameter could not be nil.");
    NSAssert(fromTime,         @"Error: fromTime type parameter could not be nil.");
    NSAssert(toTime,           @"Error: toTime type parameter could not be nil.");
    NSAssert(address,          @"Error: address type parameter could not be nil.");
    NSAssert(gender,           @"Error: gender type parameter could not be nil.");
    NSAssert(activityId,       @"Error: activityId type parameter could not be nil.");
    NSAssert(locationId,       @"Error: locationId type parameter could not be nil.");
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [self.manager postObject:nil
                                path:@"/activity/"
                          parameters:@{
                                       @"creator":          creatorId,
                                       @"date":             date,
                                       @"endDate":          endDate,
                                       @"name":             name,
                                       @"details":          details,
                                       @"type":             type,
                                       @"fromTime":         fromTime,
                                       @"toTime":           toTime,
                                       @"address":          address,
                                       @"visibility":       visibility,
                                       @"gender":           gender,
                                       @"age_filter_from":  ageFilterFrom,
                                       @"age_filter_to":    ageFilterTo,
                                       @"isAtendeeVisible": @(isAtendeeVisible),
                                       @"address_edited":   @(addressEdited),
                                       @"id":               activityId,
                                       @"location":         locationId
                                       }
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                                 [mappingResult.array.firstObject setDistanceBasedOnRange];
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)deleteActivityWithId:(NSString *)activityId
                successBlock:(void (^)(NSArray *))success
                failureBlock:(void (^)(NSError *))failure
{
    NSAssert(activityId, @"Error: ActivityID could not be nil.");
    
    DDLogInfo(@"Deleting activities with ID: %@", activityId);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager deleteObject:nil
                                  path:[NSString stringWithFormat:@"/activity?id=%@&requesterFbId=%@", activityId, self.loggedUser.fbUserId]
                            parameters:nil
                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                   
                                   [[CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext deleteObject:mappingResult.array.firstObject];
                                   
                                   success(mappingResult.array);
                                   
                               } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                   
                                   failure(error);
                                   
                               }];
        }
    }];
}

- (void)likeActivityWithId:(NSString *)activityId
                      like:(BOOL)like
              successBlock:(void (^)(NSArray *result))success
              failureBlock:(void (^)(NSError *error))failure
{
    NSAssert(activityId,          @"Error: Activity ID value could not be nil.");
    
    DDLogInfo(@"Like for ActivityID: %@", activityId);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager postObject:nil
                                path:[NSString stringWithFormat:@"/activity/%@?id=%@&requesterFbId=%@", like ? @"like" : @"unlike", activityId, self.loggedUser.fbUserId]
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)userDidShare:(NSString *)activityId
                  on:(NSString *)platform
        successBlock:(void (^)(NSArray *result))success
        failureBlock:(void (^)(NSError *error))failure
{
    NSAssert(platform, @"Error: Platform must be provided.");
    
    DDLogInfo(@"Share for ActivityID: %@", activityId);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager postObject:nil
//                                path:[NSString stringWithFormat:@"/user/shared?activityId=%@&fbId=%@&platform=%@", activityId ? activityId : @"", self.loggedUser.fbUserId, platform]
                                path:@"/user/shared"
                          parameters:[NSDictionary dictionaryWithObjectsAndKeys:platform, @"platform", self.loggedUser.fbUserId, @"fbId", activityId, @"activityId", nil]
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 if (success) {
                                     success(mappingResult.array);
                                 }
                                 
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
        }
    }];
}

- (void)activitiesByUserId:(NSString *)userId
              successBlock:(void (^)(NSArray *))success
              failureBlock:(void (^)(NSError *))failure
{
    NSAssert(userId, @"Error: User ID could not be nil.");
    
    DDLogInfo(@"Retrieving activities for User ID: %@", userId);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            NSString *path = [@"/activity/createdByUser?creator=" stringByAppendingString:userId];
            
            DDLogInfo(path);
            
            [self.manager getObject:nil
                               path:path
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                
                                [mappingResult.array enumerateObjectsUsingBlock:^(CLActivity *activity, NSUInteger idx, BOOL *stop) {

                                    [activity setDistanceBasedOnRange];
                                    
                                }];
                                
                                success(mappingResult.array);
                                
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                
                                failure(error);
                                
                            }];
        }
    }];
}

- (void)attendanceListWithActivityId:(NSString *)activityId
                        successBlock:(void (^)(NSArray *result))success
                        failureBlock:(void (^)(NSError *error))failure
{
    NSAssert(activityId, @"Error: Activity ID could not be nil.");
    
    DDLogInfo(@"Getting Attendances for Activity ID: %@", activityId);
    
    NSString *path = [@"/activity/attendance?id=" stringByAppendingString:activityId];
    
    [self getTemporaryObjectsWithPath:path
                    keepActualContext:YES
                         successBlock:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             
                             NSMutableArray *array = [NSMutableArray array];
                             
                             for (id obj in mappingResult.array) {
                                 
                                 if ([obj isKindOfClass:[CLUser class]]) {
                                     
                                     [array addObject:obj];
                                     
                                 }
                             }
                             
                             success(array);
                             
                         }
                         failureBlock:^(RKObjectRequestOperation *operation, NSError *error) {
                             
                             failure(error);
                             
                         }];
}

#pragma mark - Request Methods

- (void)postRequestWithActivityId:(NSString *)activityId
                      requesterId:(NSString *)requesterId
                             note:(NSString *)note
              activityCreatorFbId:(NSString *)activityCreatorFbId
                     successBlock:(void (^)(NSArray *))success
                     failureBlock:(void (^)(NSError *))failure
{
    NSAssert(activityId,          @"Error: Activity ID value could not be nil.");
    NSAssert(requesterId,         @"Error: Requester ID value could not be nil.");
    NSAssert(note,                @"Error: Note value could not be nil.");
    NSAssert(activityCreatorFbId, @"Error: Creator Facebook ID value could not be nil.");
    
    DDLogInfo(@"Sending Request for ActivityID: %@ from RequesterID: %@ with Note: %@", activityId, requesterId, note);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager postObject:nil
                                path:@"/request"
                          parameters:@{
                                       @"note":          note,
                                       @"requesterFbId": requesterId,
                                       @"activity":      activityId,
                                       @"creatorFbId":   activityCreatorFbId
                                       }
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)acceptRequestWithId:(NSString *)requestId
               successBlock:(void (^)(NSArray *result))success
               failureBlock:(void (^)(NSError *error))failure
{
    NSAssert(requestId, @"Error: Request ID value could not be nil.");
    
    DDLogInfo(@"Accepting Request for ID: %@", requestId);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager postObject:nil
                                path:@"/request/accept"
                          parameters:@{@"id": requestId}
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)cancelRequestWithId:(NSString *)requestId
               successBlock:(void (^)(NSArray *result))success
               failureBlock:(void (^)(NSError *error))failure
{
    NSAssert(requestId, @"Error: Request ID value could not be nil.");
    
    DDLogInfo(@"Canceling Request for ID: %@", requestId);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager postObject:nil
                                path:@"/request/cancel"
                          parameters:@{@"id": requestId}
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)denyRequestWithId:(NSString *)requestId
             successBlock:(void (^)(NSArray *result))success
             failureBlock:(void (^)(NSError *error))failure
{
    NSAssert(requestId, @"Error: Request ID value could not be nil.");
    
    DDLogInfo(@"Denying Request for ID: %@", requestId);
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager postObject:nil
                                path:@"/request/deny"
                          parameters:@{@"id": requestId}
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 success(mappingResult.array);
                                 
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 
                                 failure(error);
                                 
                             }];
        }
    }];
}

- (void)requestsForLoggedUserWithSuccessBlock:(void (^)(NSArray *))success
                                 failureBlock:(void (^)(NSError *))failure
{
    DDLogInfo(@"Getting all Requests for logged user");
    
    [self.manager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        
        NSError *error;
        
        if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
            
            DDLogError(@"Failed to save - error: %@", [error localizedDescription]);
            
        } else {
            
            [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            
            [self.manager getObject:nil
                               path:[NSString stringWithFormat:@"/request?fbId=%@&userId=%@",
                                     [CLApiClient sharedInstance].loggedUser.fbUserId,
                                     [CLApiClient sharedInstance].loggedUser.userId]
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                
                                success(mappingResult.array);
                                
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                
                                failure(error);
                                
                            }];
        }
    }];
}

#pragma mark - Private Methods

- (void)updateLoggedUserWithUserId:(NSString *)userId
{
    // save current logged user locations array
    NSMutableArray *locationsArray = self.loggedUser.locationsArray;
    
    // initialize logged user data from CLUser with userId
    CLLoggedUser *user     = [[CLLoggedUser alloc] initWithUserId:userId];
    
    [user saveToDisk];
    
    // invalidate cached logged user
    self->_loggedUser = nil;
    
    // restore locations array
    self.loggedUser.locationsArray = locationsArray ? locationsArray : [NSMutableArray array];
}

- (void)getTemporaryObjectsWithPath:(NSString *)path
                  keepActualContext:(BOOL)keepContext
                       successBlock:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                       failureBlock:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    DDLogInfo(@"%@", path);

    if (!keepContext) {
        
        _scratchManagedObjectContext = [[CLDatabaseManager sharedInstance] generateScratchObjectContext];
        
    }
    
    if (_scratchManagedObjectContext == nil) {
        
        _scratchManagedObjectContext = [[CLDatabaseManager sharedInstance] generateScratchObjectContext];
        
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self.scratchManagedObjectContext performBlock:^{
    
        [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
        
        NSMutableURLRequest *request = [weakSelf.manager requestWithObject:nil
                                                                    method:RKRequestMethodGET
                                                                      path:path
                                                                parameters:nil];
    
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
        RKManagedObjectRequestOperation *operation = [weakSelf.manager managedObjectRequestOperationWithRequest:request
                                                                                           managedObjectContext:weakSelf.scratchManagedObjectContext
                                                                                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                                        
                                                                                                            success(operation, mappingResult);
                                                                                                        
                                                                                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                                        
                                                                                                            failure(operation, error);
                                                                                                        
                                                                                                        }];
        
        operation.savesToPersistentStore = NO;
        
        [operation start];
    }];

}

@end
