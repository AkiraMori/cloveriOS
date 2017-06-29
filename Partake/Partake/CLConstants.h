//
//  CLConstants.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef enum CLApiErrorCodes {
//    CLOrderAddressNotBelongsToPerson   = 200
//} CLAPIErrorCodes;

typedef enum CLClientErrorCodes {
    CLClientErrorCodeOperationFailed   = 8000,
    CLClientErrorCodeOperationCanceled = 8001,
    CLClientErrorCodeResponseParsing   = 9000
} CLClientErrorCodes;

typedef enum CLFacebookImageType {
    CLFacebookImageTypeSquare = 0,
    CLFacebookImageTypeSmall  = 1,
    CLFacebookImageTypeNormal = 2,
    CLFacebookImageTypeLarge  = 3
} CLFacebookImageType;

@interface CLConstants : NSObject

/**
 *  Endpoint
 */
extern NSString * const kCLEndpoint;

/**
 *  Google Api Key for every Google service.
 */
extern NSString * const kCLGoogleApiKey;

/**
 *  QuickBlox Api Key for chat service.
 */
extern NSInteger  const kCLQuickBloxApplicationId;
extern NSString * const kCLQuickBloxServiceKey;
extern NSString * const kCLQuickBloxServiceSecret;
extern NSString * const kCLQuickBloxAccountKey;

/**
 *  Amazon details
 */

extern NSString * const kCLAmazonCognitoIdentityPool;
extern NSString * const kCLAmazonS3Bucket;
extern NSString * const kCLAmazonS3ProjectFolder;

/**
 *  Partake Privacy Policy Page URL
 */
extern NSString * const kCLPartakePrivacyPolicyPageURL;
extern NSString * const kCLPartakeTermsOfServicePageURL;
extern NSString * const kCLPartakeFAQPageURL;
extern NSString * const kCLPartakeAppStoreURL;
extern NSString * const kCLPartakeShareURL;
extern NSString * const kCLPartakeAppLogoURL;

/**
 *  Facebook Graph URL for profile picture fetch.
 *  @param facebookId
 *  @param pictureType using CLFacebookImageType enum
 */
extern NSString * const kCLFacebookGraphProfilePictureURL;

/**
 *  Date Formmaters
 */
extern NSString * const kCLDateFormatterMonthDayYear;
extern NSString * const kCLDateFormatterYearMonthDay;
extern NSString * const kCLDateFormatterYearMonthDayDashed;
extern NSString * const kCLDateFormatterISO8601;

/**
 *  Font Family Constants
 */
extern NSString * const kCLPrimaryBrandFont;
extern NSString * const kCLPrimaryBrandFontText;

/**
 *  Max length of text to send along the app
 */
extern NSInteger  const kCLMaxNoteLength;

/**
 *  Max number of activities user can create
 */
extern NSInteger  const kCLMaxActivitiesNumber;

/**
 *  Image Format Constants
 */
extern NSString * const kCLImageFormatJPG;
extern NSString * const kCLImageFormatPNG;

/**
 *  Status Request Constants
 */
extern NSString * const kCLStatusRequestPending;
extern NSString * const kCLStatusRequestAccepted;
extern NSString * const kCLStatusRequestReceived;
extern NSString * const kCLStatusRequestRejected;
extern NSString * const kCLStatusRequestCancelled;

/**
 *  Notification Constants
 */
extern NSString * const kCLBlockedUserNotification;
extern NSString * const kCLNotificationIsReachable;
extern NSString * const kCLNotificationIsNotReachable;
extern NSString * const kCLActivityDeletedNotification;
extern NSString * const kCLUserPreferencesUpdatedNotification;
extern NSString * const kCLRequestOptionPerformedNotification;
extern NSString * const kCLNotificationDialogsUpdated;
extern NSString * const kCLNotificationChatDidAccidentallyDisconnect;
extern NSString * const kCLNotificationChatDidReconnect;
extern NSString * const kCLNotificationGroupDialogJoined;
extern NSString * const kCLNotificationDidReadMessage;
extern NSString * const kCLNotificationDidReadRequest;

/**
 *  Request Timeout Constant
 */
extern float const kCLRetryTimeout;

/**
 *  HTTP Methods
 */
extern NSString * const kCLHTTPMethodGET;
extern NSString * const kCLHTTPMethodPOST;
extern NSString * const kCLHTTPMethodDELETE;
extern NSString * const kCLHTTPMethodPUT;

/**
 *  Client & API Error Constants
 */
extern NSString * const kCLApiErrorDomain;
extern NSString * const kCLClientErrorDomain;
extern NSString * const kCLApiErrorTypeKey;
extern NSString * const kCLApiErrorHTTPStatusCodeKey;
extern NSString * const kCLQuickBloxErrorDomain;

/**
 *  Age Range For App
 */
extern NSInteger const kCLAgeRangeMin;
extern NSInteger const kCLAgeRangeMax;

/**
 *  Address reverse geo-code
 */
extern NSInteger const kCLAddressResolveMinDistance;

/**
 *  Share Platform
 */
extern NSString * const kCLSharePlatformFacebook;
extern NSString * const kCLSharePlatformTwitter;
extern NSString * const kCLSharePlatformEMail;
extern NSString * const kCLSharePlatformSMS;

@end
