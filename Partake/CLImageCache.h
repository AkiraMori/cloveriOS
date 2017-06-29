//
//  CLImageCache.h
//  Partake
//
//  Created by Maikel on 05/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLImageCache : NSObject

+ (NSString *)applicationDocumentsDirectory;

+ (NSString *)imagePathForId:(NSUInteger)imageId;

+ (NSString *)imagePathForIdString:(NSString *)imageId;

+ (UIImage *)imageForId:(NSString *)imageId;

@end
