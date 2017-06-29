//
//  CLLocationManagerController.h
//  Partake
//
//  Created by Pablo Episcopo on 3/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@protocol CLLocationManagerControllerDelegate;

@interface CLLocationManagerController : CLLocationManager
@property (strong, nonatomic) NSString *currentAddress;
@property (weak, nonatomic) id<CLLocationManagerControllerDelegate> wdelegate;

+ (CLLocationManagerController *)sharedInstance;

- (void)startNotify;

@end

@protocol CLLocationManagerControllerDelegate <NSObject>

@required
- (void)locationManagerDidUpdateLocations;

- (void)locationManagerController:(CLLocationManagerController *)manager
                 didFailWithError:(NSError *)error;

- (void)locationManagerDidChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end
