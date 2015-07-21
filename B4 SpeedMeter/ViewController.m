//
//  ViewController.m
//  B4 SpeedMeter
//
//  Created by Stoyan Yordanov Kostov on 6/29/15.
//  Copyright (c) 2015 com.kostov. All rights reserved.
//

#import "ViewController.h"
#import "LocationMenager.h"
#import "SettingsVC.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController () <LocationMenagerCustomDelegate, SettingsDelegate, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *speedUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitude_degrees;
@property (weak, nonatomic) IBOutlet UILabel *longitude_minutes;
@property (weak, nonatomic) IBOutlet UILabel *longitude_seconds;
@property (weak, nonatomic) IBOutlet UILabel *latitude_degrees;
@property (weak, nonatomic) IBOutlet UILabel *latitude_seconds;
@property (weak, nonatomic) IBOutlet UILabel *latitude_minutes;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *compassImage;
@property (weak, nonatomic) IBOutlet UIView *lanLotView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *longitudeWidth_constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *latitudeWidth_constraint;

@property (strong, nonatomic) LocationMenager *locationMenager;
@property (strong, nonatomic) SettingsVC *settingsVC;

@property (assign,nonatomic) BOOL coordinateAppearanceInDMS;
@property (assign,nonatomic) BOOL speedAppearanceInKMH;
@end

@implementation ViewController

- (void)viewDidLoad
{   [super viewDidLoad];
    self.speedLabel.textColor = [UIColor redColor];
    [self.locationMenager start];
    self.lanLotView.layer.cornerRadius = 3.0f;
    
    _coordinateAppearanceInDMS = [[NSUserDefaults standardUserDefaults] boolForKey:@"coordinateAppearanceInDMS"];
    _speedAppearanceInKMH = [[NSUserDefaults standardUserDefaults] boolForKey:@"speedAppearanceInKMH"];
    
    [self setSpeedUnitInKMH];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"show_only_once"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Use compass only in Portrait mode!"
                                                       message:@"The compass is made to working correctly only in portrait mode!"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"show_only_once"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidLayoutSubviews
{   [super viewDidLayoutSubviews];
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice]orientation])) {
        self.image.image = [UIImage imageNamed:@"Audi_leftSide"];
        [self.speedUnitLabel setTextColor:[UIColor whiteColor]];
    } else {
        [self.speedUnitLabel setTextColor:[UIColor blackColor]];
        self.image.image = [UIImage imageNamed:@"Audi_front"];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{   [super viewDidDisappear:animated];
    [self.locationMenager stop];
}

#pragma mark - Getters

- (LocationMenager *)locationMenager {
    if (!_locationMenager) {
        _locationMenager = [LocationMenager sharedInstance];
        _locationMenager.delegate = self;
    }
    return _locationMenager;
}

#pragma mark - LocationMenagerCustomDelegate

static CGFloat const kmh = 0.277778; //meters per second for 1 kmh
static CGFloat const mph = 0.44704;
- (void)didUpdateLocation:(CLLocation *)location {
    CGFloat speed = _speedAppearanceInKMH ? location.speed/kmh : location.speed/mph;
    [self speed:speed];
    
    [self setDMSInDegrees];
    if (_coordinateAppearanceInDMS) {
       // NSLog(@"lati:%f DMS:%@",location.coordinate.latitude,[self DMSfromDegrees:location.coordinate.latitude]);
        
        [self latitude:[self DMSfromDegrees:location.coordinate.latitude]];
        [self longitude:[self DMSfromDegrees:location.coordinate.longitude]];
    } else {
        self.latitude_degrees.text = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
        self.longitude_degrees.text = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    }
}

- (void)didUpdateHeadingWithNewRotationAngle:(CGFloat)radians {
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.compassImage.transform = CGAffineTransformMakeRotation(radians);
                        } completion:nil];
}

#pragma mark - Private

- (void)speed:(CGFloat)speed {
    if (_speedAppearanceInKMH ? speed > 100 : speed > 60) {
        self.speedLabel.textColor = [UIColor redColor];
    } else {
        self.speedLabel.textColor = [UIColor greenColor];
    }
    
    if (speed < 0) {
        self.speedLabel.text = @"0";
    }else {
        self.speedLabel.text = [[[NSString stringWithFormat:@"%f",speed]componentsSeparatedByString:@"."] firstObject];
    }
}

- (void)latitude:(NSString *)latitude {
    NSArray *latStringComponents = [latitude componentsSeparatedByString:@" "];
    if (latStringComponents.count == 3) {
        self.latitude_degrees.text = [latStringComponents firstObject];
        self.latitude_minutes.text = [latStringComponents objectAtIndex:1];
        self.latitude_seconds.text = [latStringComponents lastObject];
    }
}

- (void)longitude:(NSString *)longitude {
    NSArray *lonStringComponents = [longitude componentsSeparatedByString:@" "];
    if (lonStringComponents.count == 3) {
        self.longitude_degrees.text = [lonStringComponents firstObject];
        self.longitude_minutes.text = [lonStringComponents objectAtIndex:1];
        self.longitude_seconds.text = [lonStringComponents lastObject];
    }
}

- (NSString *)DMSfromDegrees:(CLLocationDegrees)degrees {
    CGFloat degrees_float = degrees;
    NSInteger degrees_int = (NSInteger)degrees;
    CGFloat minutes = fabs((degrees_float - degrees_int)) * 60;
    NSInteger minutes_int = (NSInteger)minutes;
    CGFloat seconds = (minutes - minutes_int) * 60;
    return [NSString stringWithFormat:@"%li\u00B0 %li\' %.5f\"",degrees_int,minutes_int,seconds];
}

- (void)setDMSInDegrees {
    self.longitude_minutes.hidden = !_coordinateAppearanceInDMS;
    self.longitude_seconds.hidden = !_coordinateAppearanceInDMS;
    self.latitude_minutes.hidden  = !_coordinateAppearanceInDMS;
    self.latitude_seconds.hidden  = !_coordinateAppearanceInDMS;
    
    static CGFloat const defaultWidth  =  43.0f;
    static CGFloat const expandedWidth = 100.0f;
    
    self.longitudeWidth_constraint.constant = _coordinateAppearanceInDMS ? defaultWidth : expandedWidth;
    self.latitudeWidth_constraint.constant  = _coordinateAppearanceInDMS ? defaultWidth : expandedWidth;
}

- (void)setSpeedUnitInKMH {
    if (_speedAppearanceInKMH) {
        self.speedUnitLabel.text = @"km/h";
    } else {
        self.speedUnitLabel.text = @"mp/h";
    }
}

#pragma mark - SettingsDelegate

- (void)degreesValueChanged:(BOOL)value {
    _coordinateAppearanceInDMS = value;
    [[NSUserDefaults standardUserDefaults]setBool:_coordinateAppearanceInDMS forKey:@"coordinateAppearanceInDMS"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self setDMSInDegrees];
}

- (void)speedUnitValueChanged:(BOOL)value {
    _speedAppearanceInKMH = value;
    [[NSUserDefaults standardUserDefaults]setBool:_speedAppearanceInKMH forKey:@"speedAppearanceInKMH"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self setSpeedUnitInKMH];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"to settings Segue"]) {
        SettingsVC *settings = (SettingsVC *)segue.destinationViewController;
        UIPopoverPresentationController *PC = settings.popoverPresentationController;
        PC.delegate = self;
        settings.delegate = self;
    }
}
@end
