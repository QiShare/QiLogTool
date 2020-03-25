//
//  ViewController.m
//  QiLogTool
//
//  Created by 王永旺永旺 on 2020/3/23.
//  Copyright © 2020 WYW. All rights reserved.
//

#import "ViewController.h"
#import "QiLogTool.h"
#import <StoreKit/StoreKit.h>

static NSString *const logFileName = @"logFileName.txt";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"iOS查看及导出项目运行日志";
    [self setupUI];
}

- (void)setupUI {
    
    UIButton *testLogButton = [[UIButton alloc] initWithFrame:CGRectMake(.0, .0, 200.0, 40.0)];
    [self.view addSubview:testLogButton];
    testLogButton.center = self.view.center;
    testLogButton.backgroundColor = [UIColor lightGrayColor];
    [testLogButton setTitle:@"测试日志按钮" forState:UIControlStateNormal];
    [testLogButton addTarget:self action:@selector(testLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)testLogButtonClicked:(UIButton *)sender {
    
    [self logTest];
}

- (void)logTest {
    
    NSLog(@"NSLog日志内容");
    // 测试日志工具
    [QiLogTool logFile:@"logfile.log" content:[NSString stringWithFormat:@"时间：%@\n内容：%@\n", [[NSDate date] dateByAddingTimeInterval:8.0 * 60 * 60], @"logContent"]];
    
    // 测试崩溃
    NSArray *arr = @[@(1)];
    NSLog(@"arr[2]：%@", arr[2]);

    return;

    /**
     * 普通异常的捕获方式：
     * 2020-03-25 10:47:11.179085+0800 QiLogTool[18371:4064396] exception：***
     * -[__NSSingleObjectArrayI objectAtIndex:]: index 2 beyond bounds [0 .. 0]
     2020-03-25 10:47:11.179310+0800 QiLogTool[18371:4064396] finally
     */
    @try {
        NSArray *arr = @[@(1)];
        NSLog(@"%@", arr[2]);
    } @catch (NSException *exception) {
        NSLog(@"exception：%@", exception);
    } @finally {
        NSLog(@"finally");
    }
    NSLog(@"NSLog touchesBegan内容");
    NSString *content = @"content";
    
    [QiLogTool logFile:logFileName fileData:[content dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)supportDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urlsArray = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSLog(@"%@", urlsArray);
}


@end
