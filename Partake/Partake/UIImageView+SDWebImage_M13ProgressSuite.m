//
//  UIImageView+SDWebImage_M13ProgressSuite.m
//  testSDWebImageWithProgress
//
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "PureLayout.h"
#import "NUIAppearance.h"
#import "UIView+NUI.h"

#import "UIImageView+SDWebImage_M13ProgressSuite.h"

#define TAG_PROGRESS_VIEW_RING 258369

@implementation UIImageView (SDWebImage_M13ProgressSuite)

- (void)addProgressViewRingWithPrimaryColor:(UIColor *)pColor
                             SecondaryColor:(UIColor *)sColor
                                   Diameter:(float)diameter
{
    
    UIView *wrapper;
    
    M13ProgressViewPie *progressView = [[M13ProgressViewPie alloc] initForAutoLayout];
    
    wrapper           = [[UIView alloc] initForAutoLayout];
    wrapper.tag       = TAG_PROGRESS_VIEW_RING;
    wrapper.transform = CGAffineTransformMakeScale(0, 0);
    
    [self addSubview:wrapper];
    
    [wrapper addSubview:progressView];
    
    pColor = [UIColor lightGrayColor];
    
    sColor = [UIColor darkGrayColor];
    
    float ringWidth = 0.0f;
    
    if (self.nuiClass && [NUISettings hasProperty:@"spinner-width" withClass:self.nuiClass]) {
        ringWidth = [NUISettings getFloat:@"spinner-width" withClass:self.nuiClass];
    }
    
    [progressView autoSetDimensionsToSize:CGSizeMake(diameter, diameter)];
    [progressView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [progressView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    [wrapper autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    progressView.primaryColor        = pColor;
    progressView.secondaryColor      = sColor;
    progressView.backgroundRingWidth = ringWidth;
    
    float randomNum = ((float)rand() / RAND_MAX) * 200;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * (randomNum / 50.0f) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [progressView setProgress:(0.05f * (randomNum / 100.0f)) animated:YES];
        
    });
    
    [UIView animateWithDuration:0.4f
                          delay:0.1f
         usingSpringWithDamping:0.6
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         wrapper.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

- (void)updateProgressViewRing:(CGFloat)progress
{
    UIView *wrapper;
    
    if (!(wrapper = [self viewWithTag:TAG_PROGRESS_VIEW_RING]) || wrapper.subviews.count <= 0) {
        return;
    }
    
    __block M13ProgressViewPie *progressView = wrapper.subviews[0];
    
    if (progress <= progressView.progress) {
        return;
    }
    
    [progressView setProgress:progress animated:YES];
}

- (void)removeProgressViewRing
{
    UIView *wrapper;
    
    if (!(wrapper = [self viewWithTag:TAG_PROGRESS_VIEW_RING])) {
        return;
    }
    
    [self sd_cancelCurrentImageLoad];
    
    [wrapper removeFromSuperview];
}

#pragma mark - Public Methods

- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url
                            placeholderImage:(UIImage *)placeholder
                                     options:(SDWebImageOptions)options
                                    progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                   completed:(SDWebImageCompletionBlock)completedBlock
                        progressPrimaryColor:(UIColor *)pColor
                      progressSecondaryColor:(UIColor *)sColor
                                    diameter:(float)diameter
                                       scale:(BOOL)allowScale
{
    UIView *wrapper;
    
    if ((wrapper = [self viewWithTag:TAG_PROGRESS_VIEW_RING]) || self.image) {
        [self removeProgressViewRing];
    }
    
    [self addProgressViewRingWithPrimaryColor:pColor
                               SecondaryColor:sColor
                                     Diameter:diameter];
    
    __weak typeof(self) weakSelf = self;
    
    [self sd_setImageWithURL:url
            placeholderImage:placeholder
                     options:options
                    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                        CGFloat progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
                        [weakSelf updateProgressViewRing:progress];
                        
                        if (progressBlock) {
                            progressBlock(receivedSize, expectedSize);
                        }
                        
                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        
                        if (image && cacheType == SDImageCacheTypeNone) {
                            self.transform = allowScale ? CGAffineTransformMakeScale(0.4f, 0.4f) : CGAffineTransformIdentity;
                            weakSelf.layer.allowsEdgeAntialiasing = YES;
                            [UIView animateWithDuration:(allowScale ? 0.7f : 1.0f)
                                                  delay:0
                                 usingSpringWithDamping:(allowScale ? 0.81f : 1.0f)
                                  initialSpringVelocity:(allowScale ? 0.0f : 0.0f)
                                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                                             animations:^{
                                                 weakSelf.transform = CGAffineTransformIdentity;
                                             } completion:^(BOOL finished) {
                                                 weakSelf.layer.allowsEdgeAntialiasing = NO;
                                             }];
                            
                            
                            self.alpha = 0.0;
                            [UIView animateWithDuration:(allowScale ? 0.7f : 1.0f)
                                                  delay:0
                                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                                             animations:^{
                                                 weakSelf.alpha = 1.0f;
                                             } completion:nil];
                        }
                        
                        [weakSelf removeProgressViewRing];
                        
                        if (completedBlock) {
                            completedBlock(image, error, cacheType, imageURL);
                        }
                    }];
}

@end
