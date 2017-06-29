//
//  CLOnboardingController.m
//  Partake
//
//  Created by Maikel on 24/11/15.
//  Copyright © 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLOnboardingController.h"
#import "CLOnboardingFinalViewController.h"
#import "CLOnboardingCreateActivityViewController.h"
#import "CLSettingsManager.h"
#import "CLAppDelegate.h"


@interface CLOnboardingController ()
@property (strong, nonatomic) NSArray *pageIds;
@end


@implementation CLOnboardingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageIds = @[
                 @"CLOnboardingSlidesViewController",
                 @"CLOnboardingFinalViewController",
                 @"CLOnboardingCreateActivityViewController"
                 ];
    
    _currentPage = 0;
    [self loadPageAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoNextPage {
    if (_currentPage < _pageIds.count - 1) {
        _currentPage++;
        [self loadPageAnimated:YES];
    } else {
        [CLSettingsManager sharedManager].didShowOnboarding = YES;
        [[CLAppDelegate sharedInstance] showTabBar];
    }
}

- (void)loadPageAnimated:(BOOL)animated
{
    NSString *pageId = _pageIds[_currentPage];
    if (_currentPage == _pageIds.count - 1) {
        UIViewController *createActivityVC = [CLOnboardingCreateActivityViewController new];
        [self setViewControllers:@[createActivityVC] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:nil];
    } else {
        UIViewController *pageVC = [self.storyboard instantiateViewControllerWithIdentifier:pageId];
        [self setViewControllers:@[pageVC] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:nil];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
