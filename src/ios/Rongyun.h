//
//  Rongyun.h
//  七天汇
//
//  Created by ☺strum☺ on 2018/11/28.
//

#import <Cordova/CDV.h>

@interface Rongyun : CDVPlugin

#pragma mark 初始化融云服务器
- (void)init:(CDVInvokedUrlCommand*)command;

/**
 * 融云推送消息透传或系统消息回调
 */
- (void)onMessage:(CDVInvokedUrlCommand*)command;

/**
 * 系统消息,公司通知点击事件
 * @param  {Function} successCallback 系统消息：'system_notice'，公司通知：'company_notice'
 */
- (void)onClick:(CDVInvokedUrlCommand*)command;

//监听通知变换 web
- (void)onNotify:(CDVInvokedUrlCommand*)command;

//设置公司通知数量 native
- (void)setCompanyBadge:(CDVInvokedUrlCommand*)command;

//设置系统通知数量 native
- (void)setSystemBadge:(CDVInvokedUrlCommand*)command;


/**
 * 监听消息数变化
 */
- (void)onBadge:(CDVInvokedUrlCommand*)command;

/**
 * 控制显示
 * @param  option {fixedPixelsTop:头距离，默认为0,fixedPixelsBottom:底距离默认为0}
 */
- (void)show:(CDVInvokedUrlCommand*)command;

/**
 * 控制隐藏
 */
- (void)hide:(CDVInvokedUrlCommand*)command;

/*
 * 融云登出
 */
- (void)logout:(CDVInvokedUrlCommand*)command;


@end
