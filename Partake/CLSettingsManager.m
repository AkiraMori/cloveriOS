//
//  CLSettingsManager.m
//  Partake
//
//  Created by Maikel on 02/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSettingsManager.h"

static NSString * const kCLSettingsKey            = @"settings";
static NSString * const kCLSettingsVibrationKey   = @"vibration";
static NSString * const kCLSettingsSoundKey       = @"sound";
static NSString * const kCLSettingsPreviewKey     = @"preview";
static NSString * const kCLSettingsPushAlertKey   = @"push_alert";
static NSString * const kCLSettingsDeviceTokenKey = @"device_token";
static NSString * const kCLSettingsDidShowOnboarding = @"didShowOnboarding";

@interface CLSettingsManager ()
@property (strong, nonatomic) NSMutableDictionary *settingsData;
@end


@implementation CLSettingsManager

#pragma mark - Singleton Methods

+ (id)sharedManager {
    static CLSettingsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self sm_loadSettingsData];
    }

    return self;
}


#pragma mark - Public Methods

- (BOOL)vibrationEnabled {
    return false;//[[self sm_objectForKey:kCLSettingsVibrationKey] boolValue];
}

- (void)setVibrationEnabled:(BOOL)vibrationEnabled {
    [self sm_setObject:@(vibrationEnabled) forKey:kCLSettingsVibrationKey];
}

- (BOOL)soundEnabled {
    return false;//[[self sm_objectForKey:kCLSettingsSoundKey] boolValue];
}

- (void)setSoundEnabled:(BOOL)soundEnabled {
    [self sm_setObject:@(soundEnabled) forKey:kCLSettingsSoundKey];
}

- (BOOL)previewEnabled {
    return false;//[[self sm_objectForKey:kCLSettingsPreviewKey] boolValue];
}

- (void)setPreviewEnabled:(BOOL)previewEnabled {
    [self sm_setObject:@(previewEnabled) forKey:kCLSettingsPreviewKey];
}

- (BOOL)pushAlertEnabled {
    return false;//[[self sm_objectForKey:kCLSettingsPushAlertKey] boolValue];
}

- (void)setPushAlertEnabled:(BOOL)pushAlertEnabled {
    [self sm_setObject:@(pushAlertEnabled) forKey:kCLSettingsPushAlertKey];
}

- (NSString *)deviceTokenString
{
    if (!_deviceToken) {
        return nil;
    }
    
    NSString *deviceTokens = [[_deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokens = [deviceTokens stringByReplacingOccurrencesOfString:@" " withString:@""];
    return deviceTokens;
}

- (BOOL)didShowOnboarding {
    return [[self sm_objectForKey:kCLSettingsDidShowOnboarding] boolValue];
}

- (void)setDidShowOnboarding:(BOOL)didShowOnboarding {
    [self sm_setObject:@(didShowOnboarding) forKey:kCLSettingsDidShowOnboarding];
}

#pragma mark - Private Methods

- (id)sm_objectForKey:(NSString *)key
{
    return _settingsData[key];
}

- (void)sm_setObject:(id)object forKey:(NSString *)key
{
    [_settingsData setObject:object forKey:key];
    
    [self sm_saveSettingsData];
}

- (void)sm_loadSettingsData {
    if (!_settingsData) {
        _settingsData = [[[NSUserDefaults standardUserDefaults] objectForKey:kCLSettingsKey] mutableCopy];
        
        if (!_settingsData) {
            _settingsData = [NSMutableDictionary dictionary];
            
            _settingsData[kCLSettingsVibrationKey] = @(YES);
            _settingsData[kCLSettingsSoundKey]     = @(YES);
            _settingsData[kCLSettingsPreviewKey]   = @(YES);
            _settingsData[kCLSettingsPushAlertKey] = @(YES);
            _settingsData[kCLSettingsDidShowOnboarding] = @(NO);
        }
    }
}

- (void)sm_saveSettingsData
{
    if (_settingsData) {
        [[NSUserDefaults standardUserDefaults] setObject:_settingsData forKey:kCLSettingsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
