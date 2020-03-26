//
//  QiLogTool.h
//  QiLogTool
//
//  Created by 王永旺永旺 on 2020/3/24.
//  Copyright © 2020 WYW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QiLogTool : NSObject

//! 存储的日志的域
extern NSString *const QiLogDomain;


/// 把NSLog的内容重定向到Documents中
+ (void)redirectNSLog;

/// 把NSLog的内容重定向到指定文件
/// @param filePath 存储NSLog内容的文件路径
/// @param logFileName 存储NSLog内容的文件名
/// @param remove 是否移除现有文件
+ (void)redirectNSLogToFilePath:(NSString *)filePath
                    logFileName:(NSString *)logFileName
             removeExistLogFile:(BOOL)remove;

/// 存储Logfile
/// @param fileName 存储的文件名
/// @param data 待存储的数据
+ (NSError *)logFile:(NSString *)fileName
            fileData:(NSData *)data;

/// 存储Logfile
/// @param fileName 存储的日志的文件名
/// @param content 待存储的内容
+ (NSError *)logFile:(NSString *)fileName
             content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
