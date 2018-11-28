package com.rongyun.im;

import android.app.LocalActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cn.rongcloud.im.IMApp;
import cn.rongcloud.im.SealAppContext;
import cn.rongcloud.im.SealConst;
import cn.rongcloud.im.SealNotificationListener;
import cn.rongcloud.im.SealNotificationReceiver;
import cn.rongcloud.im.SealSystemListener;
import cn.rongcloud.im.SealUserInfoManager;
import cn.rongcloud.im.server.broadcast.BroadcastManager;
import cn.rongcloud.im.ui.activity.IMMainActivity;
import cn.rongcloud.im.ui.widget.MessageCenterHeaderView;
import io.rong.imkit.RongIM;
import io.rong.imkit.manager.IUnReadMessageObserver;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.push.notification.PushNotificationMessage;

import com.google.gson.Gson;

public class Rongyun extends CordovaPlugin implements IUnReadMessageObserver {

    View mDiscoverView;
    Boolean attached=false;
    /** JS回调点击事件对象 */
    static CallbackContext actionCallbackContext = null;
    /** JS回调消息通知事件对象 */
    static CallbackContext messageCallbackContext = null;
    /** JS回调消息数事件对象 */
    static CallbackContext badgeCallbackContext = null;

    final String KEY_RONGYUN_TOKEN = "rongyun_token";
    final String KEY_USER_ID = "userId";
    final String KEY_PHONE = "phone";
    final String KEY_USER_NAME = "userName";
    final String KEY_ACCESS_KEY = "accessKey";
    final String KEY_FIXED_PIXELS_TOP="fixedPixelsTop";
    final String KEY_FIXED_PIXELS_BOTTOM="fixedPixelsBottom";

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

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
        }
        return true;
    }


    /**
     *
     */
    private void setConfig(JSONObject opt) throws JSONException {
        SharedPreferences sp = cordova.getActivity().getSharedPreferences("config", Context.MODE_PRIVATE);
        sp.edit().putString("loginToken", opt.getString(KEY_RONGYUN_TOKEN)).commit();
        sp.edit().putString(KEY_ACCESS_KEY, opt.getString(KEY_ACCESS_KEY)).commit();
        sp.edit().putString(SealConst.SEALTALK_LOGIN_ID, opt.getString(KEY_USER_ID)).commit();
        sp.edit().putString(SealConst.SEALTALK_LOGIN_NAME,  opt.getString(KEY_USER_NAME)).commit();
        sp.edit().putString(SealConst.SEALTALK_LOGING_PHONE, opt.getString(KEY_PHONE)).commit();
    }

    /**
     * 消息通知
     * @param callbackContext
     * @throws JSONException
     */
    private void onMessage(final CallbackContext callbackContext) throws JSONException{

        SealNotificationReceiver.setListener(new SealNotificationListener() {
            @Override
            public void companyClick(Context context, PushNotificationMessage pushNotificationMessage) {
                sendResult(callbackContext,new Gson().toJson(pushNotificationMessage));
            }

            @Override
            public void systemClick(Context context, PushNotificationMessage pushNotificationMessage) {
                sendResult(callbackContext,new Gson().toJson(pushNotificationMessage));
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

        RongIM.getInstance().getTotalUnreadCount(new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                onCountChanged(integer);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callbackContext.error("code:"+errorCode.getValue()+",message:"+errorCode.getMessage());
            }
        });
        RongIM.getInstance().addUnReadMessageCountChangedObserver(this, Conversation.ConversationType.PRIVATE,
                Conversation.ConversationType.GROUP,Conversation.ConversationType.SYSTEM, Conversation.ConversationType.PUBLIC_SERVICE,
                Conversation.ConversationType.APP_PUBLIC_SERVICE);
    }

    private void onClick(final CallbackContext callbackContext){
        MessageCenterHeaderView.setListener(new SealSystemListener() {
            @Override
            public boolean onClick(String s) {
                PluginResult result = new PluginResult(PluginResult.Status.OK, s);
                result.setKeepCallback(true);
                callbackContext.sendPluginResult(result);

                return false;
            }
        });
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


    @Override
    public void onCountChanged(int i) {
        PluginResult result = new PluginResult(PluginResult.Status.OK, i);
        result.setKeepCallback(true);
        badgeCallbackContext.sendPluginResult(result);
    }
}