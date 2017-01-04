//
//  AppDelegate.m
//  VOThemeManagerDemo
//
//  Created by Valo on 15/11/20.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import "AppDelegate.h"
#import "VOThemeManager.h"
#import "VOThemeUtils.h"
#import "AFImageDownloader.h"
#import "UIColor+VOHEX.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VOThemeSample" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    dispatch_queue_t dispatchQueue = dispatch_queue_create("ted.queue.next", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    NSMutableDictionary *processedDic = @{}.mutableCopy;
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        VOThemeImagePathType type = [VOThemeUtils imagePathType:value];
        NSRange range = [value rangeOfString:@"#" options:NSLiteralSearch];
        if (range.length == 1) {
            processedDic[key] = [UIColor colorWithHexString:value];
        }
        else if(type == VOThemeImagePathAbsoluteURL){
            dispatch_async(dispatchQueue, ^{
                dispatch_group_enter(dispatchGroup);
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:value]];
                [[AFImageDownloader defaultInstance] downloadImageForURLRequest:request success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                    processedDic[key] = responseObject;
                    dispatch_group_leave(dispatchGroup);
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                    dispatch_group_leave(dispatchGroup);
                }];
            });
        }
        else if(type == VOThemeImagePathMainBundle){
            processedDic[key] = [UIImage imageNamed:value];
        }
    }];
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        [[VOThemeManager shared] setData:processedDic forTheme:@"test"];
        [VOThemeManager shared].currentTheme = @"test";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [VOThemeManager shared].currentTheme = nil;
        });
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
