# Quick start

- - -

## Integrate the SDK

### Add ZegoUIKitPrebuiltCall as dependencies

1. Edit your project's pubspec.yaml and add local project dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  zego_uikit_prebuilt_call: ^1.1.2 # Add this line
```

2. Execute the command as shown below under your project's root folder to install all dependencies

```
flutter pub get
```

### Import the SDK

Now in your Dart code, import the prebuilt SDK.

```dart
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
```

### Using the ZegoUIKitPrebuiltCall in your project

You can get `appID` and `appSign` from [ZEGOCLOUD's Admin Console](https://console.zegocloud.com/). Pick up the `userID` and `userName` for connecting to ZEGOCLOUD's service. And you should also pick up a `callID` for making a new call.

- `userID` and `callID` can only contain numbers, letters, and underlines (_).
- Users that join the call with the same `callID` can talk to each other.


```dart
class CallPage extends StatelessWidget {
  final String callID;
  const CallPage({Key? key, required this.callID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: yourAppID,
      appSign: yourAppSign,
      userID: 'user_id',
      userName: 'user_name',
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
    );
  }
}
```

Now, you can make a new call by navigating to this `CallPage`.


## Build & Run

### 1. Config your project

#### Android

1. If your project was created with a version of flutter that is not the latest stable, you may need to manually modify compileSdkVersion in `your_project/android/app/build.gradle` to 33

![compileSdkVersion.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/compileSdkVersion.png)

2. Need to add app permissions, Open the file `your_project/app/src/main/AndroidManifest.xml`, add the following code:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_PHONE_STATE" />
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   ```
![/Pics/ZegoUIKit/Flutter/permission_android.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/permission_android.png)

#### iOS

Need add app permissions, open `your_project/ios/Runner/Info.plist`, add the following code inside the `dict` tag:

```plist
<key>NSCameraUsageDescription</key>
<string>We require camera access to connect to a call</string>
<key>NSMicrophoneUsageDescription</key>
<string>We require microphone access to connect to a call</string>
```
![/Pics/ZegoUIKit/Flutter/permission_ios.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/permission_ios.png)

### 2. Run & Debug

Now you can simply click the **Run** or **Debug** button to build and run your App on your device.
![/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg)

## Related guide

[Custom prebuilt UI](!ZEGOUIKIT_Custom_prebuilt_UI)


## Resources

[Complete Sample Code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example/tree/master/basic_call/flutter)
