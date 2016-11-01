//
//  AppDelegate.m
//  CJolDemo
//
//  Created by zenghao on 9/25/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "AppDelegate.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "SignInViewController.h"



@implementation AppDelegate
@synthesize curViewController;
@synthesize isRunningBack;

+ (AppDelegate*) app

{
    
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIRemoteNotificationType types=UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    
    UILocalNotification *localNotification =[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (localNotification) {
        NSLog(@"Notification Body: %@",localNotification.alertBody);
        NSLog(@"%@", localNotification.userInfo);
        NSLog(@"badgeNum:%d",application.applicationIconBadgeNumber);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"时间提醒"
                                                        message:localNotification.alertBody
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"get local notification when running background!");
        
        [self showSignInView:localNotification.userInfo];
        //application.applicationIconBadgeNumber--;
        
    }else if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] )
    {
        NSLog(@"lauch because remote notification");
        
    }
    
	[self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.isRunningBack = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.isRunningBack = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//界面在前台时，到时间时触发的代理
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"receive local notification!");
    
    if ([notification.alertBody isEqualToString:PLAN_ALERT_BODY]) {
        NSLog(@"是需要的notify");
        NSLog(@"date:%@",[notification.userInfo objectForKey:PLAN_DATE]);
        NSLog(@"fire date:%@",notification.fireDate);
        
        NSArray * lns = application.scheduledLocalNotifications;
        if ([lns containsObject:notification] == NO) {
            NSLog(@"this ln has been removed!");
            return;
        }
        
        if ([self.curViewController isKindOfClass:[SignInViewController class]] == YES) {
            NSLog(@"now in sign in view , do not alert!");
            return;
        }
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:notification.fireDate];
        NSLog(@"interval=%lf",interval);
        if( interval> 60 * ALTER_MINITER ) {
            //取消掉
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            //application.applicationIconBadgeNumber--;
            return;
        }
        
        NSLog(@"notication body:%@",notification.alertBody);
        NSLog(@"title:%@",[notification.userInfo objectForKey:PLAN_TITLE]);
        NSLog(@"desc:%@",[notification.userInfo objectForKey:PLAN_DESCRIPTION]);
        NSLog(@"date:%@",[notification.userInfo objectForKey:PLAN_DATE]);
        NSLog(@"notification count:%d",[notification.userInfo count]);
        
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        
        NSArray * array = [application scheduledLocalNotifications];
        NSLog(@"rest notifications count:%d",[array count]);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"时间提醒"
                                                        message:notification.alertBody
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self showSignInView:notification.userInfo];
        //application.applicationIconBadgeNumber--;

    }else if([notification.alertBody isEqualToString:REMIND_ALERT_BODY])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请查看最新的行程状态"
                                                        message:@"建议您查看最新的行程状态，确定最终的行程时间"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        [application cancelLocalNotification:notification];
        return;
    }
     
    
}

//程序正在运行时，搜到 推送消息
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"remote notification:%@",userInfo);
    //[self showSignInView:userInfo];
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *alert = [aps objectForKey:@"alert"];
    NSLog(@"bakc run:%d",application.applicationState);
    NSLog(@"get remote notificaion:%@",alert);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber--;
    
    if (application.applicationState == UIApplicationStateInactive) {
        return;
    }else {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"alarm"
//                                                         ofType:@"wav"];
//        SystemSoundID soundID;
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
//        AudioServicesPlaySystemSound (soundID);
//
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:alert
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [av show];
        return;

        
    }
    
    
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"token:%@",deviceToken);
    //去掉<>
    NSString * device_Token = [deviceToken description];
    NSString *dt = [device_Token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *dn = [dt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //空格用别的代替
    dt = [dn stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"token is:%@",dt);
}

-(void)showSignInView:(NSDictionary *) userInfo{
    SignInViewController *sivc=[[SignInViewController alloc] initWithDictionary:userInfo];
    sivc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    if ([self.curViewController isKindOfClass:[sivc class]] == NO) {
        [self.curViewController presentViewController:sivc animated:YES completion:NULL];
    }
    
    [self.window makeKeyAndVisible];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"IMPORTANT:failed to register remote notification");
}


@end
