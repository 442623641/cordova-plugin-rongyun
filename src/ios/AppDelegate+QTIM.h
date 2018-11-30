//
//  AppDelegate+QTIM.h
//  RIMDemo
//
//  Created by 未可知 on 2018/10/24.
//  Copyright © 2018年 QT. All rights reserved.
//

#import "AppDelegate.h"
#if NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

// MARK:  application: didReceiveLocalNotification:  这里实现了这个方法，默认在AppDelegate里面没有实现这个方法,若实现了则必须在这里进行交换方法

@interface AppDelegate (QTIM) <UNUserNotificationCenterDelegate>
@end
