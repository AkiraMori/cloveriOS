
//
//  CLConstants.m
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"

@implementation CLConstants

/**
 *  Endpoint
 */
#if defined(DEVELOPMENT)

/**
 *  Development Environment
 */
//NSString * const kCLEndpoint = @"http://52.0.64.221:1337";
NSString * const kCLEndpoint = @"http://localhost:1337";
#elif defined(STAGE)

/**
 *  Stage Environment
 */
NSString * const kCLEndpoint = @"http://52.0.64.221:1337";

#elif defined(PRODUCTION)

/**
 *  Production Environment
 */
NSString * const kCLEndpoint = @"";

#else

//#error No environment selected

#endif

/**
 *  Google Api Key for every Google service.
 */
NSString * const kCLGoogleApiKey = @"AIzaSyA6CjW7y-9j0SHLyLvSSzZH-toHPDfVHa0";

/**
 *  QuickBlox Api Key for chat service.
 */
#if DEVELOPMENT

NSInteger  const kCLQuickBloxApplicationId = 26429;
NSString * const kCLQuickBloxServiceKey    = @"mqOuV7O5dnwkkG6";
NSString * const kCLQuickBloxServiceSecret = @"DaQEQdTJjR98YpJ";
NSString * const kCLQuickBloxAccountKey    = @"GaHpmHG7Xy1yHQMmhkk7";

#elif STAGE

NSInteger  const kCLQuickBloxApplicationId = 26429;
NSString * const kCLQuickBloxServiceKey    = @"mqOuV7O5dnwkkG6";
NSString * const kCLQuickBloxServiceSecret = @"DaQEQdTJjR98YpJ";
NSString * const kCLQuickBloxAccountKey    = @"GaHpmHG7Xy1yHQMmhkk7";

#endif

/**
 *  Amazon details
 */

NSString * const kCLAmazonCognitoIdentityPool   = @"us-west-2:2cc84aa9-886b-4ed6-b102-332ccbfd7af8";
NSString * const kCLAmazonS3Bucket              = @"slyfej";
NSString * const kCLAmazonS3ProjectFolder       = @"partake";

/**
 *  Partake URLs
 */
NSString * const kCLPartakePrivacyPolicyPageURL  = @"http://trypartake.com/privacy-policy/";
NSString * const kCLPartakeTermsOfServicePageURL = @"http://trypartake.com/terms-of-service/";
NSString * const kCLPartakeFAQPageURL            = @"http://trypartake.com/faq/";
NSString * const kCLPartakeAppStoreURL           = @"http://itunes.apple.com/app/id970717023";
NSString * const kCLPartakeShareURL              = @"http://trypartake.com";
NSString * const kCLPartakeAppLogoURL            = @"http://trypartake.com/wp-content/uploads/2016/02/JPG-Logo-version-01_1200x627.jpg";

/**
 *  Facebook Graph URL for profile picture fetch.
 *  @param facebookId 
 *  @param pictureType using CLFacebookImageType enum
 */
NSString * const kCLFacebookGraphProfilePictureURL = @"https://graph.facebook.com/%@/picture?type=%@";

/**
 *  Date Formmaters
 */
NSString * const kCLDateFormatterMonthDayYear       = @"MM/dd/yyyy";
NSString * const kCLDateFormatterYearMonthDay       = @"yyyy/MM/dd";
NSString * const kCLDateFormatterYearMonthDayDashed = @"yyyy-MM-dd";
NSString * const kCLDateFormatterISO8601            = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";

/**
 *  Font Family Constants
 */
NSString * const kCLPrimaryBrandFont     = @"Montserrat-Regular";
NSString * const kCLPrimaryBrandFontText = @"Montserrat-Light";

/**
 *  Max length of text to send along the app
 */
NSInteger  const kCLMaxNoteLength = 350;

/**
 *  Max number of activities user can create
 */
NSInteger  const kCLMaxActivitiesNumber = 15;

/**
 *  Image Format Constants
 */
NSString * const kCLImageFormatJPG = @"jpg";
NSString * const kCLImageFormatPNG = @"png";

/**
 *  Status Request Constants
 */
NSString * const kCLStatusRequestPending   = @"Pending";
NSString * const kCLStatusRequestAccepted  = @"Accepted";
NSString * const kCLStatusRequestReceived  = @"Received";
NSString * const kCLStatusRequestRejected  = @"Rejected";
NSString * const kCLStatusRequestCancelled = @"Cancelled";

/**
 *  Notification Constants
 */
NSString * const kCLBlockedUserNotification            = @"kCLBlockedUserNotification";
NSString * const kCLNotificationIsReachable            = @"kCLNotificationIsReachable";
NSString * const kCLNotificationIsNotReachable         = @"kCLNotificationIsNotReachable";
NSString * const kCLActivityDeletedNotification        = @"kCLNotificationActivityDeleted";
NSString * const kCLUserPreferencesUpdatedNotification = @"kCLUserPreferencesUpdatedNotification";
NSString * const kCLRequestOptionPerformedNotification = @"kCLRequestOptionPerformedNotification";
NSString * const kCLNotificationDialogsUpdated                = @"kNotificationDialogsUpdated";
NSString * const kCLNotificationChatDidAccidentallyDisconnect = @"kNotificationСhatDidAccidentallyDisconnect";
NSString * const kCLNotificationChatDidReconnect              = @"kNotificationChatDidReconnect";
NSString * const kCLNotificationGroupDialogJoined             = @"kNotificationGroupDialogJoined";
NSString * const kCLNotificationDidReadMessage         = @"kCLNotificationDidReadMessage";
NSString * const kCLNotificationDidReadRequest         = @"kCLNotificationDidReadRequest";

/**
 *  Request Timeout Constant
 */
float const kCLRetryTimeout = 30;

/**
 *  HTTP Methods
 */
NSString * const kCLHTTPMethodGET    = @"GET";
NSString * const kCLHTTPMethodPOST   = @"POST";
NSString * const kCLHTTPMethodDELETE = @"DELETE";
NSString * const kCLHTTPMethodPUT    = @"PUT";

/**
 *  Client & API Error Constants
 */
NSString * const kCLApiErrorDomain            = @"com.partake.api";
NSString * const kCLClientErrorDomain         = @"com.partake.client";
NSString * const kCLApiErrorTypeKey           = @"com.partake.api:TypeKey";
NSString * const kCLApiErrorHTTPStatusCodeKey = @"com.partake.api:HTTPStatusCodeKey";
NSString * const kCLQuickBloxErrorDomain      = @"com.partake.qbmanager";

/**
 *  Age Range For App
 */
NSInteger const kCLAgeRangeMin = 16;
NSInteger const kCLAgeRangeMax = 55;

/**
 *  Address reverse geo-code
 */
NSInteger const kCLAddressResolveMinDistance = 1000;

/**
 *  Share Platform
 */
NSString *  const kCLSharePlatformFacebook = @"facebook";
NSString *  const kCLSharePlatformTwitter  = @"twitter";
NSString *  const kCLSharePlatformEMail    = @"email";
NSString *  const kCLSharePlatformSMS      = @"sms";

@end
