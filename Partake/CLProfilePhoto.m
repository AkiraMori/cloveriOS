//
//  CLProfilePhoto.m
//  Partake
//
//  Created by Maikel on 16/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLProfilePhoto.h"

static NSString * const kCLProfilePhotoIdKey     = @"id";
static NSString * const kCLProfilePhotoNameKey   = @"name";
static NSString * const kCLProfilePhotoWidthKey  = @"width";
static NSString * const kCLProfilePhotoHeightKey = @"height";
static NSString * const kCLProfilePhotoSourceKey = @"source";

@implementation CLProfilePhoto

#pragma mark - Initializers

+ (id)photoWithFacebookPhotoNode:(NSDictionary *)photoNode {
    return [[CLProfilePhoto alloc] initWithFacebookPhotoNode:photoNode];
}

- (id)initWithFacebookPhotoNode:(NSDictionary *)photoNode {
    self = [super init];
    if (self) {
        _photoId = photoNode[kCLProfilePhotoIdKey];
        _name    = photoNode[kCLProfilePhotoNameKey];
        _source  = photoNode[kCLProfilePhotoSourceKey];
        _width   = photoNode[kCLProfilePhotoWidthKey];
        _height  = photoNode[kCLProfilePhotoHeightKey];
    }
    
    return self;
}

#pragma mark - NSCopying

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    if (self) {
        _photoId = [aDecoder decodeObjectForKey:kCLProfilePhotoIdKey];
        _name    = [aDecoder decodeObjectForKey:kCLProfilePhotoNameKey];
        _source  = [aDecoder decodeObjectForKey:kCLProfilePhotoSourceKey];
        _width   = [aDecoder decodeObjectForKey:kCLProfilePhotoWidthKey];
        _height  = [aDecoder decodeObjectForKey:kCLProfilePhotoHeightKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_photoId forKey:kCLProfilePhotoIdKey];
    [aCoder encodeObject:_name    forKey:kCLProfilePhotoNameKey];
    [aCoder encodeObject:_width   forKey:kCLProfilePhotoWidthKey];
    [aCoder encodeObject:_height  forKey:kCLProfilePhotoHeightKey];
    [aCoder encodeObject:_source  forKey:kCLProfilePhotoSourceKey];
}

@end
