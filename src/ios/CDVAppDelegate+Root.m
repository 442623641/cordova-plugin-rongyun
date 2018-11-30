//
//  CDVAppDelegate+Root.m
//  CordovaLib
//
//  Created by ☺strum☺ on 2018/11/13.
//

#import "CDVAppDelegate+Root.h"
#import <objc/runtime.h>

@implementation CDVAppDelegate (Root)

+ (void)load
{
    Method originalDidFinishLaunching, swizzledDidFinishLaunching;
    originalDidFinishLaunching = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    swizzledDidFinishLaunching = class_getInstanceMethod(self, @selector(swizzled_application:didFinishLaunchingWithOptions:));
    method_exchangeImplementations(originalDidFinishLaunching, swizzledDidFinishLaunching);
}

-(BOOL)swizzled_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    self.window.autoresizesSubviews = YES;
    
    if (self.viewController == nil) {
        self.viewController = [[CDVViewController alloc] init];
    }
    
    UINavigationController *rootNavVC =[[UINavigationController alloc]initWithRootViewController:self.viewController];
    self.window.rootViewController = rootNavVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
