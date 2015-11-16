//
//  LocationMenager.h
//  B4 SpeedMeter
//
//  Created by Stoyan Yordanov Kostov on 6/29/15.
//  Copyright (c) 2015 com.kostov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, B4LocationMenagerGpsSignalStrength) {
    B4LocationMenagerGpsSignalStrengthInvalid = 0,
    B4LocationMenagerGpsSignalStrengthWeak,
    B4LocationMenagerGpsSignalStrengthStrong
};

@protocol LocationMenagerCustomDelegate <NSObject>
- (void)didUpdateHeadingWithNewRotationAngle:(CGFloat)radians;
- (void)didUpdateLocation:(CLLocation *)location;
@end

@interface LocationMenager : NSObject
+ (instancetype)sharedInstance;
- (void)start;
- (void)stop;
- (void)reset;
@property (weak, nonatomic) id <LocationMenagerCustomDelegate> delegate;
@end
