//
//  AppDelegate.h
//  B4 SpeedMeter
//
//  Created by Stoyan Yordanov Kostov on 6/29/15.
//  Copyright (c) 2015 com.kostov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppDelegateDelegate <NSObject>
- (void)willResignActive;
- (void)didBecomeActive;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (weak, nonatomic) id <AppDelegateDelegate> delegate;
@property (strong, nonatomic) UIWindow *window;


@end

