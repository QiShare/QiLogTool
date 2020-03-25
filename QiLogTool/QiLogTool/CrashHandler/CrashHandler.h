//
//  CrashHandler.h
//  RunLoopDemo04
//
//  Created by Harvey on 2016/12/15.
//  Copyright © 2016年 Haley. All rights reserved.
//
// 感谢：https://blog.csdn.net/u011619283/article/details/53673255

#import <Foundation/Foundation.h>
extern NSString * const kSignalExceptionName;
extern NSString * const kSignalKey;
extern NSString * const kCaughtExceptionStackInfoKey;

@interface CrashHandler : NSObject
{
    BOOL ignore;
}

+ (instancetype)sharedInstance;
+ (NSArray *)backtrace;

@end


