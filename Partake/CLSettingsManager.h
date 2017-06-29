//
//  CLSettingsManager.h
//  Partake
//
//  Created by Maikel on 02/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLSettingsManager : NSObject

@property (assign, nonatomic) BOOL vibrationEnabled;
@property (assign, nonatomic) BOOL soundEnabled;
@property (assign, nonatomic) BOOL previewEnabled;
@property (assign, nonatomic) BOOL pushAlertEnabled;

@property (assign, nonatomic) BOOL didShowOnboarding;

@property (copy, nonatomic) NSData *deviceToken;

+(CLSettingsManager *)sharedManager;

- (NSString *)deviceTokenString;

@end
