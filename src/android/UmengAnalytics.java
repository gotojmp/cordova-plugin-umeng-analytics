package com.gotojmp.cordova.umenganalytics;

import com.umeng.analytics.MobclickAgent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONException;

public class UmengAnalytics extends CordovaPlugin {
    private String mainPageName = "index";

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        boolean debugMode = preferences.getBoolean("UmengAnalyticsDebugMode", false);
        MobclickAgent.setDebugMode(debugMode);
        MobclickAgent.openActivityDurationTrack(false);
        MobclickAgent.updateOnlineConfig(this.cordova.getActivity());
    }

    @Override
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        if ("onPageStart".equals(action)) {
            onPageStart(args, callbackContext);
            return true;
        } else if ("onPageEnd".equals(action)) {
            onPageEnd(args, callbackContext);
            return true;
        }
        return false;
    }

    public void onPageStart(final CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        final String pageName = getPageName(args);
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                MobclickAgent.onPageStart(pageName);
            }
        });
    }

    public void onPageEnd(CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        final String pageName = getPageName(args);
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                MobclickAgent.onPageEnd(pageName);
            }
        });
    }

    private String getPageName(CordovaArgs args) throws JSONException {
        String pageName = args.getString(0);
        if (pageName == null || pageName.length() <= 0) {
            pageName = "umeng_unknown_page";
        }
        return pageName;
    }

    @Override
    public void onPause(boolean multitasking) {
        MobclickAgent.onPageEnd(mainPageName);
        MobclickAgent.onPause(this.cordova.getActivity());
    }

    @Override
    public void onResume(boolean multitasking) {
        MobclickAgent.onPageStart(mainPageName);
        MobclickAgent.onResume(this.cordova.getActivity());
    }
}
