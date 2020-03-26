//
//  QiLogTool.m
//  QiLogTool
//
//  Created by 王永旺永旺 on 2020/3/24.
//  Copyright © 2020 WYW. All rights reserved.
//

#import "QiLogTool.h"

typedef NS_ENUM(NSUInteger, QiLogErrorCode) {
    QiLogErrorCodeRight = 0,
    QiLogErrorCodeFileNameContent = 456,
    QiLogErrorCodeCreateFileContent = 457,
};

NSString *const QiLogDomain = @"com.qishare.ios.wyw";

@implementation QiLogTool

+ (instancetype)sharedInstance {
    
    static QiLogTool *logTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logTool = [[self alloc] init];
    });
    return logTool;
}

+ (void)redirectNSLog {
    
    NSString *fileName = @"NSLog.log";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    NSString *saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:saveFilePath error:nil];

    // 将log输入到文件 stdout：标准输出 stderr：标准错误 a 表示追加文件
    // freopen是被包含于C标准库头文件<stdio.h>中的一个函数，用于重定向输入输出流。该函数可以在不改变代码原貌的情况下改变输入输出环境，但使用时应当保证流是可靠的。 引自360百科：https://baike.so.com/doc/6129821-6342981.html
    freopen([saveFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([saveFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (void)redirectNSLogToFilePath:(NSString *)filePath logFileName:(NSString *)logFileName removeExistLogFile:(BOOL)remove {
    
    NSString *fileName = logFileName;
    if (!fileName) {
        fileName = @"NSLog.log";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    NSString *saveFilePath = filePath;
    if (!saveFilePath) {
        NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        saveFilePath = logFilePath;
    }
    
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if (remove) {
        [defaultManager removeItemAtPath:saveFilePath error:nil];
    }

    // 将log输入到文件
    freopen([saveFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([saveFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (NSError *)logFile:(NSString *)fileName fileData:(NSData *)data {
    
    if (!fileName || !data) {
        return [[NSError alloc] initWithDomain:QiLogDomain code:QiLogErrorCodeFileNameContent userInfo:nil];
    }
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:absolutePath]) {
        // 文件存在
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:absolutePath];
        [fileHandle seekToEndOfFile];
        if (@available(iOS 13.0, *)) {
            BOOL flag = [fileHandle writeData:data error:&error];
            if (!flag || error) {
                return error;
            }
        } else {
            // Fallback on earlier versions
            [fileHandle writeData:data];
        }
        // 会覆写现有内容
        // [content writeToFile:absolutePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    } else {
        BOOL flag = [fileManager createFileAtPath:absolutePath contents:data attributes:nil];
        if (!flag) {
           return [[NSError alloc] initWithDomain:QiLogDomain code:QiLogErrorCodeFileNameContent userInfo:nil];;
        }
    }
    return error;
}


+ (NSError *)logFile:(NSString *)fileName content:(NSString *)content {
    
    if (!fileName || !content) {
        return [[NSError alloc] initWithDomain:QiLogDomain code:QiLogErrorCodeFileNameContent userInfo:nil];
    }
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:absolutePath]) {
        // 文件存在
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:absolutePath];
        [fileHandle seekToEndOfFile];
        if (@available(iOS 13.0, *)) {
            BOOL flag = [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding] error:&error];
            if (!flag || error) {
                return error;
            }
        } else {
            // Fallback on earlier versions
            [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // 会覆写现有内容
        // [content writeToFile:absolutePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    } else {
        BOOL createFlag = [fileManager createFileAtPath:absolutePath contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        if (!createFlag) {
            return [[NSError alloc] initWithDomain:QiLogDomain code:QiLogErrorCodeCreateFileContent userInfo:nil];
        }
    }
    return error;
}



@end
