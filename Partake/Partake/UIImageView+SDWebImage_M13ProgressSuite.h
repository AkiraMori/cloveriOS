//
//  UIImageView+SDWebImage_M13ProgressSuite.h
//  testSDWebImageWithProgress
//
//

#import "M13ProgressViewPie.h"
#import "UIImageView+WebCache.h"

@interface UIImageView (SDWebImage_M13ProgressSuite)

- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url
                            placeholderImage:(UIImage *)placeholder
                                     options:(SDWebImageOptions)options
                                    progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                   completed:(SDWebImageCompletionBlock)completedBlock
                        progressPrimaryColor:(UIColor *)pColor
                      progressSecondaryColor:(UIColor *)sColor
                                    diameter:(float)diameter
                                       scale:(BOOL)allowScale;

- (void)removeProgressViewRing;

@end