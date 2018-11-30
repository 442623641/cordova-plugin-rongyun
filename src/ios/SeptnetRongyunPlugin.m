#import <Cordova/CDV.h>
#import <QTIMModule/QTIMBridgeManager.h>
@interface SeptnetRongyunPlugin : CDVPlugin<QTIMBridgeDelegate> {
    // Member variables go here.

}

/*
 融云管理类 delegate
 */
@property (nonatomic,copy) NSString *rongyunManager;

//注册新用户信息回调
@property (nonatomic,strong) CDVInvokedUrlCommand *userInfoCommand;

//注册未读/新来信息回调
@property (nonatomic,strong) CDVInvokedUrlCommand *messageCommand;

//注册连接状态回调
@property (nonatomic,strong) CDVInvokedUrlCommand *statusCommand;

//注册push通知状态回调
@property (nonatomic,strong) CDVInvokedUrlCommand *pushCommand;

@end

@implementation SeptnetRongyunPlugin

#pragma mark 连接融云服务器
- (void)pluginConnectIM:(CDVInvokedUrlCommand*)command{
    
    
    NSDictionary* userInfo = [command.arguments objectAtIndex:0];
        
    [QTIMBridgeManager defaultManager].delegate = self;
    
    NSLog(@"nativ token : %@",userInfo);
    
    [[QTIMBridgeManager defaultManager] connectRongServerWithUserInfo:userInfo completion:^(BOOL isSucc, RCConnectErrorCode code) {
        
         CDVPluginResult *result;
        
        if (isSucc) {
            // 连接成功
             result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
        }
        else {
            // 连接失败
             result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
         [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - 断开融云连接
- (void)pluginDisconnectIM:(CDVInvokedUrlCommand*)command{
    BOOL receivePush = [[command.arguments objectAtIndex:0] boolValue];

    [[QTIMBridgeManager defaultManager] disconnect:receivePush];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}




#pragma mark 传入userId初始化并打开私聊界面
- (void)pluginPriviteIM:(CDVInvokedUrlCommand*)command{
    
//    NSDictionary* userInfo = [command.arguments objectAtIndex:0];
//
//    NSLog(@"native private userid : %@",userInfo);
//
////    [[QTIMBridgeManager defaultManager] pushConversationWithTargetId:userInfo[@"userId"] viewController:self.viewController];
//    RCConversationType ctype = ConversationType_PRIVATE;
//    if( [userInfo[@"convType"] intValue] == 1){
//        ctype = ConversationType_PRIVATE;
//    }else if( [userInfo[@"convType"] intValue] == 6){
//        ctype = ConversationType_SYSTEM;
//    }
//    [[QTIMBridgeManager defaultManager] presentConversationWithTargetId:userInfo[@"phone"] title:@"" convType:ctype viewController:self.viewController ];
//
//    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"show list ok"];
//
//    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark 展示融云聊天列表
- (void)pluginShowChartList:(CDVInvokedUrlCommand*)command{
    
////     [[QTIMBridgeManager defaultManager] pushConversationListWithViewController:self.viewController];
//    [[QTIMBridgeManager defaultManager] presentConversationListWithViewController:self.viewController];
//    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"show list ok"];
//    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}


#pragma mark  打开native 融云 对话列表
- (void)pluginshowNativeRongyun:(CDVInvokedUrlCommand*)command{
    
    NSDictionary *info= [command.arguments objectAtIndex:0] ;
    
    RCConnectionStatus status =  [[QTIMBridgeManager defaultManager] connectStatus];
    
    if(status == ConnectionStatus_Connected){
        //已连接了
        NSLog(@"融云已连接了");
        [[QTIMBridgeManager defaultManager] showConvListInViewController:self.viewController insetTop:[info[@"top"] longLongValue]  insetBottom:[info[@"bottom"] longLongValue]];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"show native ok"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    }else{
        
        //未连接 开始连接融云
        [self connectRongyun:info withCallback:^(BOOL isSucc, RCConnectErrorCode code) {
            if(isSucc){
                NSLog(@"融云连接成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[QTIMBridgeManager defaultManager] showConvListInViewController:self.viewController insetTop:[info[@"top"] longLongValue]  insetBottom:[info[@"bottom"] longLongValue]];
                });
               
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"show native ok"];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }else{
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:code];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
            
        }];
    }
        
  
}

#pragma mark 隐藏natvie 融云 对话列表
- (void)pluginhideNativeRongyun:(CDVInvokedUrlCommand*)command{
    
    [[QTIMBridgeManager defaultManager] hideConvList];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"hide native ok"];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}



#pragma mark (注册回调) （根据userID web端获取用户信息）
- (void)pluginRequestUserInfo:(CDVInvokedUrlCommand*)command{
    
    self.userInfoCommand = command;
    
}

#pragma mark (注册回调)未读信息
- (void)pluginNewMessages:(CDVInvokedUrlCommand*)command{
    self.messageCommand = command;
}

#pragma mark (注册回调)融云连接状态 （ connecting  connected disConnect  ）
- (void)pluginRongyunStatus:(CDVInvokedUrlCommand*)command{
    self.statusCommand = command;
}

#pragma mark (注册回调)未读信息
- (void)pluginListerningNewMessages:(CDVInvokedUrlCommand*)command{
    self.messageCommand = command;
}

#pragma mark (注册回调)融云推送消息
- (void)pluginRongyunPush:(CDVInvokedUrlCommand*)command{
   self.pushCommand = command;     
}


#pragma mark  退出融云登录
- (void)pluginLogoutIM:(CDVInvokedUrlCommand*)command{
    
    [[QTIMBridgeManager defaultManager] logout];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"pluginLogoutIM"];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


#pragma mark 返回用户信息 （根据userID web端获取用户信息）
- (void)pluginGetUserInfo:(CDVInvokedUrlCommand*)command{
//
//    NSDictionary* userInfo = [command.arguments objectAtIndex:0];
//
//    NSLog(@"pluginGetUserInfo %@",userInfo);
//
//
//    RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:[userInfo objectForKey:@"userId"] name:[userInfo objectForKey:@"name"] portrait:[userInfo objectForKey:@"avatar"]];
//    [[QTIMBridgeManager defaultManager] refreshFriendListWithUserInfo:user];
//
//    CDVPluginResult *result;
//
//    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:userInfo[@"name"]];
//    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark 获取所有的私聊列表

/*
 获取聊天列表数据
 */
- (void)pluginGetConversations:(CDVInvokedUrlCommand*)command{
    
//    NSArray *convs = [[QTIMBridgeManager defaultManager] getConsJsonsWithConvType:ConversationType_PRIVATE];
//
//    CDVPluginResult *result;
//
//    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:convs];
//
//    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}



#pragma mark - delegate

//-------------------------融云管理类delegate--------------------------------------------

// 返回userid web端获取用户信息
- (void)rongyunGetUserInfoWithUserid:(NSString *)userId{
    NSLog(@"rongyunGetUserInfoWithUserid %@",userId);
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:userId];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.userInfoCommand.callbackId];
}

// 返回rongyun连接的状态 连接 断开 登出
- (void)rongyunconnectStatus:(NSString *)status{
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.statusCommand.callbackId];
}

// 返回新消息回调
- (void)rongyunReceiveMessageWithConvJson:(NSDictionary *)convJson{
    CDVPluginResult *result;
    NSLog(@"rongyunReceiveMessageWithConvJson %@ :",convJson);
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:convJson];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.messageCommand.callbackId];
}

//推送 外部通知
- (void)rongyunReceivedAppActiveNotificationWithUserInfo:(NSDictionary *)userInfo
{
    CDVPluginResult *result;
    NSLog(@"rongyunReceivedAppActiveNotificationWithUserInfo %@ :",userInfo);
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.pushCommand.callbackId];
}

//推送 应用内通知
- (void)rongyunReceivedAppInActiveNotificationWithUserInfo:(NSDictionary *)userInfo
{
    CDVPluginResult *result;
    NSLog(@"rongyunReceivedAppInActiveNotificationWithUserInfo %@ :",userInfo);
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.pushCommand.callbackId];   
}

#pragma mark - private

-(NSString *)NSStringToJson:(NSString *)str
{
    NSMutableString *s = [NSMutableString stringWithString:str];
    
    [s replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    
    return [NSString stringWithString:s];
}

#pragma mark - 连接r融云
- (void)connectRongyun:(NSDictionary *)userInfo withCallback:(void (^)(BOOL,RCConnectErrorCode))callback{
    
    [QTIMBridgeManager defaultManager].delegate = self;
    
    NSLog(@"nativ token : %@",userInfo);
    
    [[QTIMBridgeManager defaultManager] connectRongServerWithUserInfo:userInfo completion:^(BOOL isSucc, RCConnectErrorCode code) {
        callback(isSucc,code);
    }];

}


@end
