//
//  CrashHandler.m
//  RunLoopDemo04
//
//  Created by Harvey on 2016/12/15.
//  Copyright © 2016年 Haley. All rights reserved.
//

#import "CrashHandler.h"
#import "QiLogTool.h"

#import <UIKit/UIKit.h>

#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const kSignalExceptionName = @"kSignalExceptionName";
NSString * const kSignalKey = @"kSignalKey";
NSString * const kCaughtExceptionStackInfoKey = @"kCaughtExceptionStackInfoKey";

void HandleException(NSException *exception);
void SignalHandler(int signal);

@implementation CrashHandler

static CrashHandler *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setCatchExceptionHandler];
    }
    return self;
}

- (void)setCatchExceptionHandler {
    // 1.捕获一些异常导致的崩溃
    NSSetUncaughtExceptionHandler(&HandleException);
    
    // 2.捕获非异常情况，通过signal传递出来的崩溃
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

+ (NSArray *)backtrace {
    
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)handleException:(NSException *)exception {
    
    NSString *message = [NSString stringWithFormat:@"崩溃原因如下:\n%@\n%@",
                         [exception reason],
                         [[exception userInfo] objectForKey:kCaughtExceptionStackInfoKey]];
    NSLog(@"%@",message);
    // 日志记录崩溃详情
    [QiLogTool logFile:@"chooseCrash.log" content:message];
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"如果你能让程序起死回生，那你的决定是？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"允许一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->ignore = NO;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"崩就崩吧" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->ignore = YES;
    }];
    [alertC addAction:sureAction];
    [alertC addAction:cancelAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:YES completion:nil];
    
    // 获取到当前线程的的CFRunLoop对象及 获取包含特定CFRunLoop对象的Modes数组 在指定的Modes中运行当前线程的CFRunLoop对象
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    // NSLog(@"ignore：%@", @(ignore));
    while (!ignore) {
        // NSLog(@"ignore：%@", @(ignore));
        for (NSString *mode in (__bridge NSArray *)allModes) {
            // Runs the current thread’s CFRunLoop object in a particular mode.
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:kSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:kSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

@end

void HandleException(NSException *exception) {
    // 获取异常的堆栈信息
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:callStack forKey:kCaughtExceptionStackInfoKey];
    
    CrashHandler *crashObject = [CrashHandler sharedInstance];
    NSException *customException = [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
    [crashObject performSelectorOnMainThread:@selector(handleException:) withObject:customException waitUntilDone:YES];
}

void SignalHandler(int signal) {
    // 这种情况的崩溃信息，就另某他法来捕获吧
    NSArray *callStack = [CrashHandler backtrace];
    NSLog(@"信号捕获崩溃，堆栈信息：%@",callStack);
    
    CrashHandler *crashObject = [CrashHandler sharedInstance];
    NSException *customException = [NSException exceptionWithName:kSignalExceptionName
                                                           reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil),signal]
                                                         userInfo:@{kSignalKey:[NSNumber numberWithInt:signal]}];
    
    [crashObject performSelectorOnMainThread:@selector(handleException:) withObject:customException waitUntilDone:YES];
}

