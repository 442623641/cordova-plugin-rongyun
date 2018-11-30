//
//  CDVViewController+Navigation.m
//  CordovaLib
//
//  Created by ☺strum☺ on 2018/11/13.
//

#import "CDVViewController+Navigation.h"
#import <objc/runtime.h>

@implementation CDVViewController (Navigation)


+ (void)load
{
    Method originalViewWillAppear, swizzledViewWillAppear;
    originalViewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
    swizzledViewWillAppear = class_getInstanceMethod(self, @selector(swizzled_viewWillAppear:));
    method_exchangeImplementations(originalViewWillAppear, swizzledViewWillAppear);
    
    Method originalViewDidDisappear, swizzledViewDidDisappear;
    originalViewDidDisappear = class_getInstanceMethod(self, @selector(viewDidDisappear:));
    swizzledViewDidDisappear = class_getInstanceMethod(self, @selector(swizzled_viewDidDisappear:));
    method_exchangeImplementations(originalViewDidDisappear, swizzledViewDidDisappear);
    
}

- (void)swizzled_viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [self swizzled_viewWillAppear:animated];

}

- (void)swizzled_viewDidDisappear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:15.f/255 green:131.f/255 blue:255.f/255 alpha:1]] forBarMetrics:UIBarMetricsDefault];
    
    [self swizzled_viewDidDisappear:animated];
}


- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
