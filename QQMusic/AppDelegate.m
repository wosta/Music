//
//  AppDelegate.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //1.获取音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //2.设置后台类型
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //3.激活回话
     [session setActive:YES error:nil];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"111111%s",__FUNCTION__);
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"iconViewAnimate"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"2222222%s",__FUNCTION__);

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"333333333%s",__FUNCTION__);
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"iconViewAnimate"]){
        return;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RotationImageViewNotification" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
