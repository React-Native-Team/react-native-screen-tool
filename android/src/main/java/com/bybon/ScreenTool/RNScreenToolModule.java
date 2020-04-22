
package com.bybon.ScreenTool;

import android.Manifest;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.net.Uri;
import android.text.format.Time;
import android.util.Log;

import com.bybon.ScreenTool.screenshot.CheckSoulPermissionListener;
import com.bybon.ScreenTool.screenshot.ScreenShot;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.qw.soul.permission.SoulPermission;
import com.qw.soul.permission.bean.Permission;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class RNScreenToolModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private final String TAG = "RNScreenToolModule";
  private ScreenShot mScreenShot;
  private String mImagePath;

  public RNScreenToolModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    SoulPermission.getInstance().checkAndRequestPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
            new CheckSoulPermissionListener(reactContext.getString(R.string.screen_shot_permission), new Runnable() {
              @Override
              public void run() {
              }
            }) {
              @Override
              public void onPermissionOk(Permission permission) {

              }
            });
    initData();
  }

  private void initData() {
    mScreenShot = ScreenShot.getInstance();
  }

  @Override
  public String getName() {
    return "RNScreenTool";
  }

  /**
   * 开启监听截屏
   */
  @ReactMethod
  public void startListeningScreenshot() {
    Log.d(TAG, "=================startListeningScreenshot================");
    /**6.0后动态申请权限*/
    SoulPermission.getInstance().checkAndRequestPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
            new CheckSoulPermissionListener(reactContext.getString(R.string.screen_shot_permission), new Runnable() {
              @Override
              public void run() {
//                mBtnSystem.callOnClick();
              }
            }) {
              @Override
              public void onPermissionOk(Permission permission) {
                reactContext.runOnUiQueueThread(new Runnable() {
                  @Override
                  public void run() {
                    handelSystemScreenShot();
                  }
                });

              }
            });
  }

  /**
   * 开启监听截屏
   */
  @ReactMethod
  public void setImageText(String text) {
    Log.d(TAG, "text====================================" + text);
    Log.d(TAG, "mImagePath====================================" + mImagePath);
    editImage(mImagePath,text);
  }

  private void handelSystemScreenShot() {
    mScreenShot.register(reactContext, new ScreenShot.CallbackListener() {
      @Override
      public void onShot(String path) {
        Log.d(TAG,  "screen shot path===================" + path);
        mImagePath = path;
        /**
         * 检测到截屏,native通知rn
         */
        RNTEventEmitter.sendEventToRn("UserDidTakeScreenshot",path);
      }
    });
  }

  /**
   * 编辑图片
   * @param imagePath
   */
  private void editImage(String imagePath,String text){
    Log.i(TAG, "imagePath=========================" + imagePath);
    File picture = new File(imagePath);
    Uri filepath = Uri.fromFile(picture);
    Bitmap bitmap =  BitmapFactory.decodeFile(filepath.getPath());
    Bitmap bitmap1 = createBitmap(bitmap, text);

    if (bitmap1 != null) {
      saveMyBitmap(bitmap1,imagePath);
    }
  }

  // 给图片添加水印
  private Bitmap createBitmap(Bitmap src, String str) {

    /**根据换行符统计行数以及文字行高*/
    String [] splitText = str.split("\n");
    int textHeight = splitText.length * 50;

    Time t = new Time();
    t.setToNow();
    int w = src.getWidth();
    int h = src.getHeight() + textHeight;
    Bitmap bmpTemp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);

    Canvas canvas = new Canvas(bmpTemp);
    canvas.drawColor(Color.WHITE);
    Paint p = new Paint();
    String familyName = "宋体";
    Typeface font = Typeface.create(familyName, Typeface.BOLD);
    p.setColor(Color.RED);
    p.setTypeface(font);
    p.setTextSize(50);

    /**textHeight为文字行高,截图从文字下开始展示*/
    canvas.drawBitmap(src, 0, textHeight, p);

    /**根据行数换行展示文字信息*/
    int y = 0;
    for(int i = 0 ; i < splitText.length; i ++){
        y = y + 50;
        canvas.drawText(splitText[i], 200, y, p);
    }

    canvas.save();
    canvas.restore();
    return bmpTemp;
  }

  /**
   * 保存文件到指定的路径下面
   * @param bitmap
   * @param bitName 文件名字
   */
  public void saveMyBitmap(Bitmap bitmap, String bitName) {
    Log.i(TAG, "bitName=========================" + bitName);
    File f = new File(bitName);
    FileOutputStream fOut = null;
    try {
      f.createNewFile();
      fOut = new FileOutputStream(f);
      bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
      fOut.flush();
      fOut.close();
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    } catch (IOException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }catch (Exception e){
      e.printStackTrace();
    }
  }

}