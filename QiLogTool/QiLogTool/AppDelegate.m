//
//  AppDelegate.m
//  QiLogTool
//
//  Created by 王永旺永旺 on 2020/3/23.
//  Copyright © 2020 WYW. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "PAirSandbox.h"

#include <execinfo.h>
//#import "SignalHandler.h"
//#import "UncaughtExceptionHandler.h"

//#import "AppCatchExceptionHandler.h"

//#include <libkern/OSAtomic.h>

#import "CrashHandler.h"
#import "QiLogTool.h"

//记录之前的异常处理器
// static NSUncaughtExceptionHandler *previousUncaughtExceptionHandler = nil;


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (@available(iOS 13.0, *)) {
        
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
        [self.window makeKeyAndVisible];
    }
    // 是否要直接访问沙盒中的内容
    #ifdef DEBUG
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[PAirSandbox sharedInstance] enableSwipe];
        });
    #endif
    
    // 重定向NSLog内容 注意：把NSLog的内容重定向到其他文件
    [QiLogTool redirectNSLog];
    
    #ifdef DEBUG
        // 捕获异常 Summary Changes the top-level error handler.
        // NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    #endif
    // 捕获异常并且有一次应用遇到异常后 不会闪退的处理
    [CrashHandler sharedInstance];
    return YES;
}

#pragma mark - 捕获异常 不防崩
void UncaughtExceptionHandler(NSException *exception) {
    
    // 获取异常崩溃信息
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *crashDetail = [NSString stringWithFormat:@"========异常错误报告========\n name:%@\n reason:\n%@\n callStackSymbols:\n%@", name, reason, [callStack componentsJoinedByString:@"\n"]];
    NSLog(@"%@", crashDetail);
    [QiLogTool logFile:@"crash.log" content:crashDetail];

    // 把异常崩溃信息发送至开发者邮件
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:QiShareTestCrash@qq.com"];
    [mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
    [mailUrl appendFormat:@"&body=%@", crashDetail];
    // 打开地址
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // mailPath = [mailUrl stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLHostAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


@end
