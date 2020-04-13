package com.bybon.ScreenTool;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class RNTEventEmitter extends ReactContextBaseJavaModule {
    private static ReactApplicationContext reactApplicationContext;


    public RNTEventEmitter(ReactApplicationContext reactContext) {
        super(reactContext);
        reactApplicationContext = reactContext;
    }

    /**
     * 注册native与rn通信的模块名称
     * @return
     */
    @Override
    public String getName() {
        return "RNTEventEmitter";
    }

    /**
     * native与rn通信方法
     * @param eventName  方法名称
     * @param paramss  参数（对象）
     */
    public static void sendEventToRn(String eventName, @Nullable WritableMap paramss) {

        if (reactApplicationContext != null) {
            reactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, paramss);
        }

    }

    /**
     * native与rn通信方法
     * @param eventName  方法名称
     * @param paramss  参数（单个字符串）
     */
    public static void sendEventToRn(String eventName, @Nullable String paramss) {

        if (reactApplicationContext != null) {
            reactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, paramss);
        }

    }

}
