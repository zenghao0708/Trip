//
//  AppDelegate.h
//  CJolDemo
//
//  Created by zenghao on 9/25/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SetCurViewController(VC) [AppDelegate app].curViewController=self

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic)IBOutlet UIViewController *curViewController;
@property BOOL isRunningBack;

+(AppDelegate *) app;


@end
