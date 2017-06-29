//
//  CLProfilePhoto.h
//  Partake
//
//  Created by Maikel on 16/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLProfilePhoto : NSObject <NSCoding>
@property (nonatomic, readonly) NSString *photoId;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *source;
@property (nonatomic, readonly) NSNumber *height;
@property (nonatomic, readonly) NSNumber *width;

- (id)initWithFacebookPhotoNode:(NSDictionary *)photoNode;
+ (id)photoWithFacebookPhotoNode:(NSDictionary *)photoNode;
@end
