#import "SceneDelegate.h"
#import "ViewController.h"
#import "PAirSandbox.h"

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
    
    UIWindowScene *windowScene = [[UIWindowScene alloc] initWithSession:session connectionOptions:connectionOptions];
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    [self.window makeKeyAndVisible];
    // 是否要直接访问沙盒中的内容
    #ifdef DEBUG
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[PAirSandbox sharedInstance] enableSwipe];
        });
    #endif
}



@end
