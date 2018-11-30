//
//  Rongyun.m
//  七天汇
//
//  Created by ☺strum☺ on 2018/11/28.
//

#import "Rongyun.h"
#import <QTIMModule/QTIMBridgeManager.h>

@interface Rongyun ()<QTIMBridgeDelegate>

//监听消息回调
@property (nonatomic,strong) CDVInvokedUrlCommand *messageCommand;

//监听badge回调
@property (nonatomic,strong) CDVInvokedUrlCommand *badgeCommand;


@property (nonatomic,strong) CDVInvokedUrlCommand *notifyCommand;

@property (nonatomic,strong) CDVInvokedUrlCommand *webListenerNotifyCommand;


@end


@implementation Rongyun


#pragma mark 初始化融云
- (void)init:(CDVInvokedUrlCommand*)command{

    NSDictionary* userInfo = [command.arguments objectAtIndex:0];
    
    [QTIMBridgeManager defaultManager].delegate = self;
    
    NSLog(@"nativ token : %@",userInfo);
    
    [[QTIMBridgeManager defaultManager] fetchUserInfoWithPhone:userInfo[@"phone"] comletion:^(id response, NSError *error) {
    
        CDVPluginResult *result;
        
        if (response) {
            /*
             Area =     (
             );
             avatar = "http://115.28.115.220:3000/upload/user/240/avatar.png";
             depart = "\U4ea7\U54c1\U7814\U53d1\U4e2d\U5fc3";
             flag = 1;
             id = 240;
             imtoken = "yHNI8KZmRluXiodJw6QkLA0+u8aImNgj70DNeKnLoJ0xFYgEMYwpmo+2nLQnx455Qgn6QYQgCj/dU07cZzg+kg==";
             name = "\U90d1\U7426";
             phone = 18019935951;
             pinyin = zhengqi;
             role = "\U6d4b\U8bd5\U5de5\U7a0b\U5e08";
             userType = 1;
             */
            // 连接成功
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
            
            [[QTIMBridgeManager defaultManager] connectRongServerWithUserInfo:response completion:^(BOOL isSucc, RCConnectErrorCode code) {
                NSLog(@"connect %d",isSucc);
            }];
            }
        else {
            // 连接失败
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    }];
    
}

#pragma mark 控制隐藏
/**
 * 监听消息数变化
 */
- (void)onBadge:(CDVInvokedUrlCommand*)command{
    
    NSUInteger unread = [[QTIMBridgeManager defaultManager] getAllUnReadMessageCount];
    self.badgeCommand = command;
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%zd",unread]];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.badgeCommand.callbackId];

}

#pragma mark 融云推送消息透传或系统消息回调
/**
 * 融云推送消息透传或系统消息回调
 */
- (void)onMessage:(CDVInvokedUrlCommand*)command{
    if(!self.messageCommand){
        self.messageCommand = command;
    }
}


#pragma mark 控制显示
/**
 * 控制显示
 * @param  option {fixedPixelsTop:头距离，默认为0,fixedPixelsBottom:底距离默认为0}
 */
- (void)show:(CDVInvokedUrlCommand*)command{
    
     NSDictionary *info= [command.arguments objectAtIndex:0] ;
    
    [[QTIMBridgeManager defaultManager] showConvListInViewController:self.viewController insetTop:[info[@"fixedPixelsTop"] longLongValue]  insetBottom:[info[@"fixedPixelsBottom"] longLongValue]];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"show native ok"];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

#pragma mark 控制隐藏
/**
 * 控制隐藏
 */
- (void)hide:(CDVInvokedUrlCommand*)command{
    [[QTIMBridgeManager defaultManager] hideConvList];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"hide native ok"];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark 系统消息,公司通知点击事件

/**
 * 系统消息,公司通知点击事件
 * @param  {Function} successCallback 系统消息：'system_notice'，公司通知：'company_notice'
 */
- (void)onClick:(CDVInvokedUrlCommand*)command{
    self.notifyCommand = command;
}

#pragma mark 监听通知变换 web
- (void)onNotify:(CDVInvokedUrlCommand*)command{
    self.webListenerNotifyCommand = command;
}

#pragma mark  设置公司通知数量 native
- (void)setCompanyBadge:(CDVInvokedUrlCommand*)command{
    
    NSNumber * webunRead = [command.arguments objectAtIndex:0] ;
    
    NSLog(@"web comp unread %zd",[webunRead integerValue]);

    
    NSUInteger unread = [[QTIMBridgeManager defaultManager] getAllUnReadMessageCount];

    [[QTIMBridgeManager defaultManager] updateSystemMessageIndex:0 count:[webunRead integerValue]];
    
    NSInteger count = [webunRead integerValue] + unread;
    
    [self badgeCount:count];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:count];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark  设置系统通知数量 native
- (void)setSystemBadge:(CDVInvokedUrlCommand*)command{

    NSNumber * webunRead = [command.arguments objectAtIndex:0];
    
    NSLog(@"web sys unread %zd",[webunRead integerValue]);
    
    NSUInteger unread = [[QTIMBridgeManager defaultManager] getAllUnReadMessageCount];
    
    [[QTIMBridgeManager defaultManager] updateSystemMessageIndex:1 count:[webunRead integerValue]];
    
    NSInteger count = [webunRead integerValue] + unread;
    
    [self badgeCount:count];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:count];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

/*
 * 融云登出
 */
- (void)logout:(CDVInvokedUrlCommand*)command{
    
    [[QTIMBridgeManager defaultManager] logout];
 
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}


#pragma mark - -------------------------融云管理类delegate--------------------------------------------


// 返回rongyun连接的状态 连接 断开 登出
- (void)rongyunconnectStatus:(NSString *)status{
    
}

// 返回新消息回调
- (void)rongyunReceiveMessageWithConvJson:(NSDictionary *)convJson{
    CDVPluginResult *result;
    NSLog(@"rongyunReceiveMessageWithConvJson %@ :",convJson);
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:convJson];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.messageCommand.callbackId];
}


- (void)rongyunReceivedAppInActiveNotificationWithUserInfo:(NSDictionary *)userInfo{
    CDVPluginResult *result;
    NSLog(@"rongyunReceivedAppInActiveNotificationWithUserInfo %@ :",userInfo);
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.messageCommand.callbackId];
}

- (void)rongyunReceivedAppActiveNotificationWithUserInfo:(NSDictionary *)userInfo{
    CDVPluginResult *result;
    NSLog(@"rongyunReceivedAppActiveNotificationWithUserInfo %@ :",userInfo);
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.messageCommand.callbackId];
    
   
}

- (void)rongyunUpdateUnReadMsgCount:(NSInteger)count{
    [self badgeCount:count];
}

- (void)badgeCount:(NSInteger)count{
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%zd",count]];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.badgeCommand.callbackId];
}

- (void)rongyunDidClickCompanyNotice{
    //跳到公司投资
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"company_notice"];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.notifyCommand.callbackId];
}

- (void)rongyunDidClickSystemNotice{
    //跳到系统消息
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"system_notice"];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.notifyCommand.callbackId];
}


- (void)rongyunDidSelectSysMsgWithIndex:(NSInteger)index{
    
    NSString *notice;
    if(index == 0){
        notice = @"company_notice";
    }else if(index == 1){
        notice = @"system_notice";
    }

    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:notice];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.notifyCommand.callbackId];
}



- (void)rongyunSystemMessageDidChange{
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"SystemMessageDidChange"];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.webListenerNotifyCommand.callbackId];
}


@end
