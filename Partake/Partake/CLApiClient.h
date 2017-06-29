//
//  CLApiClient.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//
#import "RestKit.h"
#import <RestKit/CoreData.h>
#import <Foundation/Foundation.h>

#import "CLUser.h"
#import "CLActivity.h"
#import "CLLoggedUser.h"
#import "CLObjectManager.h"

@import CoreLocation;

@interface CLApiClient : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *scratchManagedObjectContext;
@property (strong, nonatomic, readonly) CLLoggedUser           *loggedUser;
@property (strong, nonatomic)           CLObjectManager        *manager;

+ (CLApiClient *)sharedInstance;

- (id)initWithBaseUrl:(NSURL *)baseUrl
   managedObjectStore:(RKManagedObjectStore *)objectStore;

- (void)cancelAllRequests;
- (void)setAuthGuestToken:(NSString *)guestToken;
- (void)setAuthHeaderWithAccessToken:(NSString *)accessToken;

- (void)removeInstance;

- (BOOL)isReachable;
- (BOOL)isLoggedIn;

#pragma mark - User Methods

- (void)userWithId:(NSString *)userId
      successBlock:(void (^)(NSArray *))success
      failureBlock:(void (^)(NSError *))failure;

- (void)loginWithFbId:(NSString *)fbId
              fbToken:(NSString *)fbToken
            firstName:(NSString *)firstName
             lastName:(NSString *)lastName
                email:(NSString *)email
               gender:(NSString *)gender
                  age:(NSString *)age
         successBlock:(void (^)(BOOL isNewUser, NSArray *result))success
         failureBlock:(void (^)(NSError *error))failure;

- (void)mutualFriendsForUserWithFacebookId:(NSString *)facebookId
                              successBlock:(void (^)(NSArray *result))success
                              failureBlock:(void (^)(NSError *error))failure;

- (void)blockUserWithFbId:(NSString *)fbIdToBlock
             successBlock:(void (^)(NSArray *result))success
             failureBlock:(void (^)(NSError *error))failure;

- (void)reportUserWithFbId:(NSString *)fbIdToReport
                    reason:(NSString *)reason
                  comments:(NSString *)comments
             successBlock:(void (^)(NSArray *result))success
             failureBlock:(void (^)(NSError *error))failure;

- (void)saveUserDefaultPreferences:(NSInteger)searchDistanceLimit
                         CreatedBy:(NSString *)createdBy
                           AgeFrom:(NSInteger)ageFrom
                             AgeTo:(NSInteger)ageTo
                      successBlock:(void (^)(NSArray *))success
                      failureBlock:(void (^)(NSError *))failure;

- (void)editUserProfileAboutMe:(NSString *)aboutMe
                      Pictures:(NSArray *)pictures
                  successBlock:(void (^)(NSArray *))success
                  failureBlock:(void (^)(NSError *))failure;

- (void)registerDeviceToken:(NSString *)deviceToken
                enableAlert:(BOOL)enableAlert
               successBlock:(void (^)(void))success
               failureBlock:(void (^)(NSError *))failure;

- (void)resetUserBadgeInBackground;

- (void)deactivateUserAccountWithSuccessBlock:(void (^)(void))success
                                 failureBlock:(void (^)(NSError *))failure;

#pragma mark - Activity Methods

- (void)activitiesWithCoordinates:(CLLocationCoordinate2D)coordinates
                     successBlock:(void (^)(NSArray *result))success
                     failureBlock:(void (^)(NSError *error))failure;

- (void)activityWithId:(NSString *)activityId
          successBlock:(void (^)(NSArray *result))success
          failureBlock:(void (^)(NSError *error))failure;

- (void)searchActivitiesWithText:(NSString *)searchText
                     coordinates:(CLLocationCoordinate2D)coordinates
                           limit:(NSInteger)limit
                          offset:(NSInteger)offset
                    successBlock:(void (^)(NSArray *result))success
                    failureBlock:(void (^)(NSError *error))failure;

- (void)searchActivitiesWithTypes:(NSArray *)types
                      coordinates:(CLLocationCoordinate2D)coordinates
                       viewableBy:(NSString *)viewableBy
                         dayStart:(NSInteger)dayStart
                           dayEnd:(NSInteger)dayEnd
                     successBlock:(void (^)(NSArray *result))success
                     failureBlock:(void (^)(NSError *error))failure;

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
                       successBlock:(void (^)(NSArray *result))success
                       failureBlock:(void (^)(NSError *error))failure;

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

- (void)activitiesByUserId:(NSString *)userId
              successBlock:(void (^)(NSArray *result))success
              failureBlock:(void (^)(NSError *error))failure;

- (void)deleteActivityWithId:(NSString *)activityId
                successBlock:(void (^)(NSArray *result))success
                failureBlock:(void (^)(NSError *error))failure;

- (void)likeActivityWithId:(NSString *)activityId
                      like:(BOOL)like
              successBlock:(void (^)(NSArray *result))success
              failureBlock:(void (^)(NSError *error))failure;

- (void)userDidShare:(NSString *)activityId
                  on:(NSString *)platform
        successBlock:(void (^)(NSArray *result))success
        failureBlock:(void (^)(NSError *error))failure;

- (void)attendanceListWithActivityId:(NSString *)activityId
                        successBlock:(void (^)(NSArray *result))success
                        failureBlock:(void (^)(NSError *error))failure;

#pragma mark - Request Methods

- (void)postRequestWithActivityId:(NSString *)activityId
                      requesterId:(NSString *)requesterId
                             note:(NSString *)note
              activityCreatorFbId:(NSString *)activityCreatorFbId
                     successBlock:(void (^)(NSArray *result))success
                     failureBlock:(void (^)(NSError *error))failure;

- (void)requestsForLoggedUserWithSuccessBlock:(void (^)(NSArray *))success
                                 failureBlock:(void (^)(NSError *))failure;

- (void)acceptRequestWithId:(NSString *)requestId
               successBlock:(void (^)(NSArray *result))success
               failureBlock:(void (^)(NSError *error))failure;

- (void)cancelRequestWithId:(NSString *)requestId
               successBlock:(void (^)(NSArray *result))success
               failureBlock:(void (^)(NSError *error))failure;

- (void)denyRequestWithId:(NSString *)requestId
             successBlock:(void (^)(NSArray *result))success
             failureBlock:(void (^)(NSError *error))failure;

@end
