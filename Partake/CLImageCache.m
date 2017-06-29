//
//  CLImageCache.m
//  Partake
//
//  Created by Maikel on 05/08/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLImageCache.h"

@implementation CLImageCache

+ (NSString *)applicationDocumentsDirectory
{
    static NSString * documentsDirectory = nil;
    
    if (!documentsDirectory) {
        NSArray *paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
    }
    
    return documentsDirectory;
}

+ (NSString *)imagePathForId:(NSUInteger)imageId
{
    return [self imagePathForIdString:[NSString stringWithFormat:@"%lu", imageId]];
}

+ (NSString *)imagePathForIdString:(NSString *)imageId
{
    return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imageId]];
}

+ (UIImage *)imageForId:(NSString *)imageId
{
    return [UIImage imageWithContentsOfFile:[self imagePathForIdString:imageId]];
}

@end
