//
//  CLLocationManagerController.m
//  Partake
//
//  Created by Pablo Episcopo on 3/10/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLActivity+ModelController.h"
#import "CLLocationManagerController.h"
#import "CLConstants.h"
#import "CLAnalyticsHelper.h"


@interface CLLocationManagerController () <CLLocationManagerDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D myLastLocation;
@property (nonatomic, assign) CLLocationAccuracy     myLastLocationAccuracy;

@property (nonatomic, assign) CLLocationCoordinate2D lastAddressLocation;
@end

@implementation CLLocationManagerController

+ (CLLocationManagerController *)sharedInstance
{
    static CLLocationManagerController * instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CLLocationManagerController new];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [self setup];
        
    }
    
    return self;
}

- (void)setup
{
    CLLoggedUser *loggedUser  = [CLApiClient sharedInstance].loggedUser;
    loggedUser.locationsArray = [NSMutableArray array];
    
    self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.delegate        = self;
}

- (void)startNotify
{
    if ([self respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self requestWhenInUseAuthorization];
        
    }
    
    [self startUpdatingLocation];
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (int i = 0; i < locations.count; i++) {
        
        CLLocation *newLocation = locations[i];
        
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy     theAccuracy = newLocation.horizontalAccuracy;
        NSTimeInterval         locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0f) {
            
            continue;
        }
        
        if (newLocation != nil &&
            theAccuracy > 0 &&
            theAccuracy < 2000 &&
            (!(theLocation.latitude  == 0.0 &&
               theLocation.longitude == 0.0))) {
            
            self.myLastLocation         = theLocation;
            self.myLastLocationAccuracy = theAccuracy;
            
            NSMutableDictionary *dict = [@{
                                           @"latitude":    @(theLocation.latitude),
                                           @"longitude":   @(theLocation.longitude),
                                           @"theAccuracy": @(theAccuracy)
                                           } copy];
            
            [[CLApiClient sharedInstance].loggedUser.locationsArray addObject:dict];
            
            DDLogDebug(@"User location updated - %@", dict);
            
            [self resolveAddressInBackground];
            
            [CLAnalyticsHelper logUserLocation:locations[i]];
        }
    }
    
    if (self.wdelegate != nil && [self.wdelegate respondsToSelector:@selector(locationManagerDidUpdateLocations)]) {
        
        [self.wdelegate locationManagerDidUpdateLocations];
        
    }
}

- (void)locationManager:(CLLocationManagerController *)manager didFailWithError:(NSError *)error
{
    if (self.wdelegate != nil && [self.wdelegate respondsToSelector:@selector(locationManagerController:didFailWithError:)]) {
        
        [self.wdelegate locationManagerController:manager
                                 didFailWithError:error];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (self.wdelegate != nil && [self.wdelegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)]) {
        
        [self.wdelegate locationManagerDidChangeAuthorizationStatus:status];
        
    }
}

#pragma mark - PRIVATE

- (void)resolveAddressInBackground
{
    if (!CLLocationCoordinate2DIsValid(self.myLastLocation)) {
        return;
    }
    
    CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:self.myLastLocation.latitude longitude:self.myLastLocation.longitude];
    if (CLLocationCoordinate2DIsValid(self.lastAddressLocation)) {
        CLLocation *lastAddressLocation = [[CLLocation alloc] initWithLatitude:self.lastAddressLocation.latitude longitude:self.lastAddressLocation.longitude];
        if (lastLocation && lastAddressLocation && [lastAddressLocation distanceFromLocation:lastLocation] < kCLAddressResolveMinDistance) {
            return;
        }
    }
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            NSString *town = placemark.subAdministrativeArea;
            if (!town) {
                town = placemark.subLocality;
            }
            if (!town) {
                town = placemark.locality;
            }
            self.currentAddress = [NSString stringWithFormat:@"%@, %@", town, placemark.administrativeArea];
            self.lastAddressLocation = self.myLastLocation;
            NSLog(@"Location Address - %@", self.currentAddress);
        }
    }];
}

@end
