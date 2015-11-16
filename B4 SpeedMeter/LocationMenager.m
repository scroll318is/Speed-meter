//
//  LocationMenager.m
//  B4 SpeedMeter
//
//  Created by Stoyan Yordanov Kostov on 6/29/15.
//  Copyright (c) 2015 com.kostov. All rights reserved.
//

#import "LocationMenager.h"
#import <CoreLocation/CoreLocation.h>
@interface LocationMenager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation LocationMenager
// singleton
+ (instancetype)sharedInstance
{
    static LocationMenager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [LocationMenager new];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

#pragma mark - Getters

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark - Public

- (void)start
{
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)reset
{
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self reset];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([self.delegate respondsToSelector:@selector(didUpdateLocation:)]) {
        CLLocation *lastLocation = (CLLocation *)[locations lastObject];
        [self.delegate didUpdateLocation:lastLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
        didUpdateHeading:(CLHeading *)newHeading{
    float heading = newHeading.trueHeading; //in degrees
    float headingDegrees = -(heading*M_PI/180); //assuming needle points to top of iphone.
    if ([self.delegate respondsToSelector:@selector(didUpdateHeadingWithNewRotationAngle:)]) {
        [self.delegate didUpdateHeadingWithNewRotationAngle:headingDegrees];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        NSLog(@"User has denied location services");
    } else {
        NSLog(@"Location manager did fail with error: %@", error.localizedFailureReason);
    }
}

@end
