
package com.bybon.ScreenTool;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class RNScreenToolModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNScreenToolModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNScreenTool";
  }
}