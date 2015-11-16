//
//  SettingsVC.m
//  B4 SpeedMeter
//
//  Created by Stoyan Yordanov Kostov on 7/1/15.
//  Copyright (c) 2015 com.kostov. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC () 
@property (weak, nonatomic) IBOutlet UISwitch *degreesDMSSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *speedUnitSwitch; // km/h, mh/h
@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.degreesDMSSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"coordinateAppearanceInDMS"];
    self.speedUnitSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"speedAppearanceInKMH"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onDegreesSwitchValueChanged:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(degreesValueChanged:)]) {
        [self.delegate degreesValueChanged:sender.isOn];
    }
}

- (IBAction)speedUnitChanged:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(speedUnitValueChanged:)]) {
        [self.delegate speedUnitValueChanged:sender.isOn];
    }
}

@end
