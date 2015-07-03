//
//  SettingsVC.h
//  B4 SpeedMeter
//
//  Created by Stoyan Yordanov Kostov on 7/1/15.
//  Copyright (c) 2015 com.kostov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsDelegate <NSObject>
- (void)degreesValueChanged:(BOOL)value;
- (void)speedUnitValueChanged:(BOOL)value;
@end

@interface SettingsVC : UIViewController
@property (strong, nonatomic) id <SettingsDelegate> delegate;
@end
