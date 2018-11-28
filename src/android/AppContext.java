package com.rongyun.im;

import android.app.ActivityManager;
import android.content.Context;
import android.support.multidex.MultiDexApplication;

import cn.rongcloud.im.IMApp;

/**
 * Created by caipu on 2018/10/16.
 */

public class AppContext extends MultiDexApplication{

    @Override
    public void onCreate() {
        super.onCreate();
        if (getApplicationInfo().packageName.equals(getCurProcessName(getApplicationContext()))) {
            IMApp.init(this);
        }
    }


    public static String getCurProcessName(Context context) {
        int pid = android.os.Process.myPid();
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo appProcess : activityManager.getRunningAppProcesses()) {
            if (appProcess.pid == pid) {
                return appProcess.processName;
            }
        }
        return null;
    }
}