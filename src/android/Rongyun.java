package com.rongyun.im;

import android.app.LocalActivityManager;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cn.rongcloud.im.IMApp;
import cn.rongcloud.im.SealAppContext;
import cn.rongcloud.im.SealMessageListener;
import cn.rongcloud.im.SealNotificationListener;
import cn.rongcloud.im.SealNotificationReceiver;
import cn.rongcloud.im.SealUIListener;
import cn.rongcloud.im.SealUserInfoManager;
import cn.rongcloud.im.model.SystemUnreadEvent;
import cn.rongcloud.im.ui.activity.IMMainActivity;
import cn.rongcloud.im.ui.widget.MessageCenterHeaderView;
import io.rong.eventbus.EventBus;
import io.rong.imkit.RongIM;
import io.rong.imkit.manager.IUnReadMessageObserver;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.push.notification.PushNotificationMessage;

import com.google.gson.Gson;

public class Rongyun extends CordovaPlugin implements IUnReadMessageObserver {

    View mDiscoverView;
    /** JS回调点击事件对象 */
    static CallbackContext actionCallbackContext = null;
    /** JS回调消息通知事件对象 */
    static CallbackContext messageCallbackContext = null;
    /** JS回调消息数事件对象 */
    static CallbackContext badgeCallbackContext = null;

    /** JS回调消息数事件对象 */
    static CallbackContext notifysCallbackContext = null;

    final String KEY_PHONE = "phone";
    final String KEY_ACCESS_KEY = "accessKey";
    final String KEY_FIXED_PIXELS_TOP="fixedPixelsTop";
    final String KEY_FIXED_PIXELS_BOTTOM="fixedPixelsBottom";

     int sysCount=0;
     int companyCount=0;

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("init")) {
            final JSONObject opt= args.getJSONObject(0);
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        IMApp.login(cordova.getActivity(), opt.getString(KEY_ACCESS_KEY), opt.getString(KEY_PHONE), new SealUserInfoManager.ResultCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean aBoolean) {
                                callbackContext.success();
                                Log.i("RongyunPlugin", "Rongyun plugin init success");
                            }

                            @Override
                            public void onError(String s) {
                                Log.e("RongyunPlugin", s);
                                callbackContext.error(s);
                            }
                        });
                    } catch (JSONException e) {
                        e.printStackTrace();
                        callbackContext.error("Rongyun plugin init JSONException");
                    }

                }
            });
        }else if (action.equals("show")) {
            final JSONObject opt= args.getJSONObject(0);
            final int fixedPixelsTop="null".equals(opt.getInt(KEY_FIXED_PIXELS_TOP))?0:opt.getInt(KEY_FIXED_PIXELS_TOP);
            final int fixedPixelsBottom="null".equals(opt.getInt(KEY_FIXED_PIXELS_BOTTOM))?0:opt.getInt(KEY_FIXED_PIXELS_BOTTOM);
            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    if (!cordova.getActivity().isFinishing()){
                        if(mDiscoverView == null) {
                            Intent intent = new Intent(cordova.getActivity(), IMMainActivity.class);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                            intent.putExtra("top", Math.round(fixedPixelsTop * cordova.getActivity().getResources().getDisplayMetrics().density));
                            intent.putExtra("bottom", Math.round(fixedPixelsBottom * cordova.getActivity().getResources().getDisplayMetrics().density));
                            LocalActivityManager mLocalActivityManager = new LocalActivityManager(cordova.getActivity(), true);
                            mLocalActivityManager.dispatchCreate(null);
                            mDiscoverView = mLocalActivityManager.startActivity("conversationlist", intent).getDecorView();
                            FrameLayout contentParent = cordova.getActivity().getWindow().getDecorView().findViewById(android.R.id.content);
                            FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
                            contentParent.addView(mDiscoverView, lp);
                            EventBus.getDefault().post(new SystemUnreadEvent(1, sysCount));
                            EventBus.getDefault().post(new SystemUnreadEvent(0, companyCount));
                        }else{
                            mDiscoverView.setVisibility(View.VISIBLE);
                        }
                        callbackContext.success();
                    }else {
                        callbackContext.error("cordova activity is finished");
                    }

                }
            });
        } else if (action.equals("hide")) {
            Runnable runnable = new Runnable() {
                public void run() {
                    try {
                        if (!cordova.getActivity().isFinishing()) {
                            if (mDiscoverView != null) {
                                mDiscoverView.setVisibility(View.GONE);
                            }
                        }
                        callbackContext.success();
                    } catch (Exception e) {
                        e.printStackTrace();
                        callbackContext.error("hide exception");
                    }
                }
            };
            this.cordova.getActivity().runOnUiThread(runnable);
        } else if (action.equals("logout")) {
           RongIM.getInstance().logout();
           callbackContext.success();
        }else if(action.equals("onClick")){
            if(actionCallbackContext==null) {
                actionCallbackContext = callbackContext;
                cordova.getThreadPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        onClick(callbackContext);
                    }

                });
            }
        }else if(action.equals("onMessage")){
            if(messageCallbackContext==null) {
                messageCallbackContext = callbackContext;
                cordova.getThreadPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            onMessage(callbackContext);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                });

            }
        }else if(action.equals("onBadge")){
            if(badgeCallbackContext==null) {
                badgeCallbackContext = callbackContext;
                cordova.getThreadPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            onBadge(callbackContext);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                });

            }
        }else if(action.equals("onNotify")){
            if(notifysCallbackContext==null) {
                notifysCallbackContext = callbackContext;
                cordova.getThreadPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            onNotify(callbackContext);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                });

            }
        }else if(action.equals("setCompanyBadge")){
            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    try {
                        companyCount=args.getInt(0);
                        EventBus.getDefault().post(new SystemUnreadEvent(0, companyCount));
                        sendUnreadCount(callbackContext);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        callbackContext.error("JSONException");
                    }
                }
            });
        } else if(action.equals("setSystemBadge")){

            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    try {
                        sysCount=args.getInt(0);
                        EventBus.getDefault().post(new SystemUnreadEvent(1, sysCount));
                        sendUnreadCount(callbackContext);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        callbackContext.error("JSONException");
                    }
                }

            });
        }
        return true;
    }

    /**
     * 消息通知
     * @param callbackContext
     * @throws JSONException
     */
    private void onNotify(final CallbackContext callbackContext) throws JSONException {

        SealAppContext.getInstance().setSealMessageListener(new SealMessageListener() {
            @Override
            public void companyMessage(Message message) {
                sendResult(callbackContext,"company_notice");
            }

            @Override
            public void systemMessage(Message message) {
                sendResult(callbackContext,"system_notice");
            }
        });
    }

    /**
     * 点击消息通知栏
     * @param callbackContext
     * @throws JSONException
     */
    private void onMessage(final CallbackContext callbackContext) throws JSONException{

        SealNotificationReceiver.setListener(new SealNotificationListener() {
            @Override
            public void companyClick(Context context, PushNotificationMessage pushNotificationMessage) {
                onNotifyTap(callbackContext,pushNotificationMessage);
            }

            @Override
            public void systemClick(Context context, PushNotificationMessage pushNotificationMessage) {
                onNotifyTap(callbackContext,pushNotificationMessage);
            }
        });
//        RongIM.getInstance().setMessageInterceptor(new RongIM.MessageInterceptor() {
//            @Override
//            public boolean intercept(Message message) {
//                try {
//                    JSONObject jsonObject = new JSONObject();
//                    jsonObject.put("type", "message");
//                    jsonObject.put("title", message.getSenderUserId());
//                    jsonObject.put("content", new Gson().toJson(message.getContent()));
//                    jsonObject.put("extra", message.getExtra());
//                    PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
//                    result.setKeepCallback(true);
//                    callbackContext.sendPluginResult(result);
//                }catch (Exception e) {
//                    e.printStackTrace();
//                }
//                return false;
//            }
//        });
    }

    private void onNotifyTap(final CallbackContext callbackContext,final PushNotificationMessage pushNotificationMessage){
        Intent intent = new Intent();
        intent.setClass(cordova.getActivity(), cordova.getActivity().getClass() );
        cordova.getActivity().startActivity(intent);
        sendResult(callbackContext,new Gson().toJson(pushNotificationMessage));
    }
    private void sendResult(final CallbackContext callbackContext,String data){
        PluginResult result = new PluginResult(PluginResult.Status.OK, data);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    /**
     * 消息数变化
     * @param callbackContext
     * @throws JSONException
     */
    private void onBadge(final CallbackContext callbackContext) throws JSONException{

        sendUnreadCount(null);
        RongIM.getInstance().addUnReadMessageCountChangedObserver(this, Conversation.ConversationType.PRIVATE,
                Conversation.ConversationType.GROUP, Conversation.ConversationType.PUBLIC_SERVICE,
                Conversation.ConversationType.APP_PUBLIC_SERVICE);
    }


    private void sendUnreadCount(final CallbackContext callbackContext){
        RongIM.getInstance().getUnreadCount(new RongIMClient.ResultCallback<Integer>() {
                                                @Override
                                                public void onSuccess(Integer integer) {
                                                    if (callbackContext == null) {
                                                        onCountChanged(integer + sysCount + companyCount);
                                                    } else {
                                                        onCountChanged(integer + sysCount + companyCount, callbackContext);
                                                    }
                                                }

                                                @Override
                                                public void onError(RongIMClient.ErrorCode errorCode) {
                                                    callbackContext.error("code:"+errorCode.getValue()+",message:"+errorCode.getMessage());
                                                }
                                            },
                Conversation.ConversationType.PRIVATE,
                Conversation.ConversationType.GROUP,
                Conversation.ConversationType.PUBLIC_SERVICE,
                Conversation.ConversationType.APP_PUBLIC_SERVICE);
    }


    private void onClick(final CallbackContext callbackContext){
        MessageCenterHeaderView.setListener(new SealUIListener() {
            @Override
            public void companyClick() {
                sendResult(callbackContext,"company_notice");
            }

            @Override
            public void systemClick() {
                sendResult(callbackContext,"system_notice");
            }
        });
    }

    @Override
    public void onCountChanged(int i) {
        PluginResult result = new PluginResult(PluginResult.Status.OK, i);
        result.setKeepCallback(true);
        badgeCallbackContext.sendPluginResult(result);
    }

    public void onCountChanged(final int i,final CallbackContext callbackContext) {
        PluginResult result = new PluginResult(PluginResult.Status.OK, i);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        try {
            RongIM.getInstance().removeUnReadMessageCountChangedObserver(this);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }
    }

}