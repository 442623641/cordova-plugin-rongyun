//
//  QTIMBridgeManager.h
//  RIMDemo
//
//  Created by 未可知 on 2018/10/23.
//  Copyright © 2018年 QT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

#define QTIMAppInActiveReceivedNotification @"QTIMAppInActiveReceivedNotification"
#define QTIMAppActiveReceivedNotification @"QTIMAppActiveReceivedNotification"
#define BridgeManager [QTIMBridgeManager defaultManager]

typedef void(^Completion)(BOOL isSucc, RCConnectErrorCode code);

@protocol QTIMBridgeDelegate;
@interface QTIMBridgeManager : NSObject

@property (nonatomic, weak) id<QTIMBridgeDelegate> delegate;

@property (nonatomic, assign, readonly) CGFloat convListInsetBottom;
@property (nonatomic, strong, readonly) NSDictionary *firstUnreadDict;
@property (nonatomic, strong, readonly) NSDictionary *secondUnreadDict;

+ (instancetype)defaultManager;

/**
 * 初始化
 */
//- (void)initWithAppKey:(NSString *)aKey config:(NSDictionary *)config;

- (void)initWithConfig:(NSDictionary *)config;
/**
 * 根据手机号获取用户的数据
 *  response -> {phone,imtoken,id,name,avatar}
 */
- (void)fetchUserInfoWithPhone:(NSString *)phone comletion:(void(^)(id response, NSError *error))completion;

/**
 * 连接融云   completion : code == 0 成功 ; code == 0000; token 有误
 userinfo : {phone,imtoken,id,name,avatar}
 */
- (void)connectRongServerWithUserInfo:(NSDictionary *)userInfo completion:(Completion)completion;

/**
 * 获取连接状态
 */
- (RCConnectionStatus)connectStatus;

/**
 *  断开连接
 *  isReceivePush 是否接受通知消息
 */
- (void)disconnect:(BOOL)isReceivePush;

/**
 *  退出登录 不接收推送
 */
- (void)logout;

/**
 * 获取全部未读会话的数量
 */
- (NSInteger)getAllUnReadMessageCount;

/**
 * 获取指定类型的未读消息数
 */
- (NSInteger)getUnReadMessageCountWithConvType:(RCConversationType)aType;

/**
 * 更新系统未读消息  根据user_config里数据的顺序
 */
- (void)updateSystemMessageIndex:(NSInteger)index count:(NSInteger)count;

/**
 * showconvList addsubview
 */
- (void)showConvListInViewController:(UIViewController *)aViewController insetTop:(CGFloat)aTop insetBottom:(CGFloat)aBottom;

/**
 * hideConvList
 */
- (void)hideConvList;

@end

@protocol QTIMBridgeDelegate <NSObject>

- (void)rongyunconnectStatus:(NSString *)status;

//- (void)rongyunReceivedMessage:(NSDictionary *)message;

- (void)rongyunReceivedAppInActiveNotificationWithUserInfo:(NSDictionary *)userInfo;
/**
 * 返回的数据格式
 {
 　　"aps" :
         {
         "alert" : "You got your emails.",
         "badge" : 1,
         "sound" : "default"
         },
         "rc":{"cType":"PR","fId":"xxx","oName":"xxx","tId":"xxxx"},
         "appData":"xxxx"
 }
 https://www.rongcloud.cn/docs/ios_push.html#push_json
 */
- (void)rongyunReceivedAppActiveNotificationWithUserInfo:(NSDictionary *)userInfo;

- (void)rongyunUpdateUnReadMsgCount:(NSInteger)count;

//- (void)rongyunDidClickCompanyNotice;

//- (void)rongyunDidClickSystemNotice;

- (void)rongyunDidSelectSysMsgWithIndex:(NSInteger)index;

- (void)rongyunSystemMessageDidChange;

@end

