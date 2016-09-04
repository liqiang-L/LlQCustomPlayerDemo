//
//  AppDelegate.m
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/3.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "AppDelegate.h"
#import "LLQ_BaseNavigationController.h"
#import "LLQ_MianAVPlayerController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    LLQ_MianAVPlayerController * main = [[LLQ_MianAVPlayerController alloc] init];
    LLQ_BaseNavigationController * nav = [[LLQ_BaseNavigationController alloc] initWithRootViewController:main];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    AVAudioSession *as = [AVAudioSession sharedInstance];
    [as setActive:YES error:nil];
    [as setCategory:AVAudioSessionCategoryPlayback error:nil];
    return YES;
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return self.window.rootViewController.supportedInterfaceOrientations;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
