#import <Cordova/CDV.h>

@interface SeptnetRongyunPlugin : CDVPlugin

/*
 初始化融云 连接服务器
 */
- (void)pluginConnectIM:(CDVInvokedUrlCommand*)command;

/*
 断开融云连接
 */
- (void)pluginDisconnectIM:(CDVInvokedUrlCommand*)command;


/*
 传入userId初始化并打开私聊界面
 */
- (void)pluginPriviteIM:(CDVInvokedUrlCommand*)command;

/*
 展示聊天列表界面
 */
- (void)pluginShowChartList:(CDVInvokedUrlCommand*)command;

/*
 返回用户信息
 */
- (void)pluginGetUserInfo:(CDVInvokedUrlCommand*)command;

/*
 打开native 融云 对话列表
 */
- (void)pluginshowNativeRongyun:(CDVInvokedUrlCommand*)command;

/*
 隐藏natvie 融云 对话列表
 */
- (void)pluginhideNativeRongyun:(CDVInvokedUrlCommand*)command;

/*
 获取聊天列表数据
 */
- (void)pluginGetConversations:(CDVInvokedUrlCommand*)command;

/*
  (注册回调)请求用户信息
 */
- (void)pluginRequestUserInfo:(CDVInvokedUrlCommand*)command;

/*
 (注册回调)未读信息
 */
- (void)pluginNewMessages:(CDVInvokedUrlCommand*)command;

/*
 (注册回调)未读消息
 */
- (void)pluginListerningNewMessages:(CDVInvokedUrlCommand*)command;

/*
 (注册回调)融云连接状态 （ connecting  connected disConnect  ）
 */
- (void)pluginRongyunStatus:(CDVInvokedUrlCommand*)command;

/*
 (注册回调)融云推送消息
*/
- (void)pluginRongyunPush:(CDVInvokedUrlCommand*)command;

/*
 获取对话列表数据【web聊天列表】
 */
- (void)pluginGetCovListInfos:(CDVInvokedUrlCommand*)command;

/*
 获取对话列表数据【web聊天列表】
 */
- (void)pluginListenNewCovInfo:(CDVInvokedUrlCommand*)command;

/*
 退出融云登录
 */
- (void)pluginLogoutIM:(CDVInvokedUrlCommand*)command;



@end
