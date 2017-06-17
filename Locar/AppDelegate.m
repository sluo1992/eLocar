//
//  AppDelegate.m
//  Locar
//
//  Created by apple on 2017/5/16.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
// udid:cc98ea47dc0bdf8c4c15ad0de6344a0a4a4554ec
//e73481f77854471e1d25f4aaec67a071c01bc114
//ed23f926816bf98eb6770b5efeef7f399fb472bf

#import "AppDelegate.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "LaunchIntroductionView.h"
#import "ViewControllerMain.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    BOOL version = [[NSUserDefaults standardUserDefaults] boolForKey:kAppVersion];
    if (version == NO) {
        [LaunchIntroductionView sharedWithStoryboardName:@"Main" images:@[@"launch1",@"launch2",@"launch3"]];
    } else {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
       ViewControllerMain *main = [story instantiateViewControllerWithIdentifier:@"ViewControllerMain"];
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.window makeKeyWindow];
        self.window.rootViewController = main;
    }
    
    [AMapServices sharedServices].apiKey = @"f31ccab3d97b5c7116d1efe77ad81682";

    if([HSAppData isFirstStartup])
    {
        [HSAppData setFirstStartup:NO];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
