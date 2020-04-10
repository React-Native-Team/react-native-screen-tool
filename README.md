
# react-native-screen-tool

## Getting started

`$ npm install react-native-screen-tool --save`

### Mostly automatic installation

`$ react-native link react-native-screen-tool`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-screen-tool` and add `RNScreenTool.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNScreenTool.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.bybon.ScreenTool.RNScreenToolPackage;` to the imports at the top of the file
  - Add `new RNScreenToolPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-screen-tool'
  	project(':react-native-screen-tool').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-screen-tool/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-screen-tool')
  	```


## Usage
```javascript
import RNScreenTool from 'react-native-screen-tool';
import {NativeModules} from 'react-native';

this.listenerScreen = new NativeEventEmitter(NativeModules.RNTEventEmitter);
RNScreenTool.startListeningScreenshot()
this.listenerScreen.addListener('UserDidTakeScreenshot', (e) => {
  //user did take screenshot
  
  //Add text on the screenshot
  RNScreenTool.setImageText('text')
})

RNScreenTool.startMonitoringScreenRecording()
this.listenerScreen.addListener('ScreenCapturedDidChange', (e) => {
  if (e == 1) {
  //screen is being captured 
  } else {
  //screen is not being captured
  }
})
```
  
