# Quick start

---

## Add ZegoUIKitPrebuiltCallWithInvitation as dependencies

1. Run this command with Flutter:

```
flutter pub add zego_uikit_signaling_plugin
```

2. Execute the command as shown below under your project's root folder to install all dependencies

```dart
flutter pub get
```

## Import SDK

Now in your Dart code, you can import prebuilt.

```dart
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
```

## Integrate the call functionality with the invitation feature

### 1. Warp your widget with ZegoUIKitPrebuiltCallWithInvitation

> You can get the AppID and AppSign from [ZEGOCLOUD&#39;s Console](https://console.zegocloud.com).
> Users who use the same callID can talk to each other. (ZegoUIKitPrebuiltCallWithInvitation supports 1 on 1 call for now, and will support group call soon)

```dart
@override
Widget build(BuildContext context) {
   return ZegoUIKitPrebuiltCallWithInvitation(
      appID: yourAppID,
      appSign: yourAppSign,
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      child: YourWidget(),
   );
}
```

### 2. Add a button for making a call

```dart
ZegoSendCallInvitationButton(
   isVideoCall: true,
   invitees: [
      ZegoUIKitUser(
         id: targetUserID,
         name: targetUserName,
      )
   ],
)
```

Now, you can invite someone to the call by simply clicking this button.

## How to customize the calling page?

> this example is trying to make different menubar between audio call or video call

```dart
@override
Widget build(BuildContext context) {
   return ZegoUIKitPrebuiltCallWithInvitation(
      appID: yourAppID,
      appSign: yourAppSign,
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      //  we will ask you for config when we need it, you can customize your app with data
      requireConfig: (ZegoCallInvitationData data) {
        var config = ZegoUIKitPrebuiltCallConfig();
        config.turnOnCameraWhenJoining =
            ZegoInvitationType.videoCall == data.type;
        if (ZegoInvitationType.videoCall == data.type) {
          config.bottomMenuBarConfig.extendButtons = [
            IconButton(color: Colors.white, icon: const Icon(Icons.phone), onPressed:() {}),
            IconButton(color: Colors.white, icon: const Icon(Icons.cookie), onPressed:() {}),
            IconButton(color: Colors.white, icon: const Icon(Icons.speaker), onPressed:() {}),
            IconButton(color: Colors.white, icon: const Icon(Icons.air), onPressed:() {}),
          ];
        }
        return config;
      },
      child: YourWidget(),
   );
}
```

![customize_config](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/invitation/customize_config.gif)

## Build & Run

### 1. Config your project

#### Android

1. If your project is created with Flutter 2.x.x, you will need to open the `your_project/android/app/build.gradle` file, and modify the `compileSdkVersion` to **33**.


   ![compileSdkVersion](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/compile_sdk_version.png)

2. And in the same file, edit the `minSdkVersion`.

   ```xml
   minSdkVersion 21
   ```

![Pics/ZegoUIKit/Flutter/android_class_confusion.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/android_min_sdk_21.png)


3. Need to add app permissions, Open the file `your_project/app/src/main/AndroidManifest.xml`, add the following code:

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
   <uses-permission android:name="android.permission.VIBRATE"/>
   ```

<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/invitation/permission_android.png" width=800>

4. Prevent code obfuscation.

To prevent the ZEGO SDK public class names from being obfuscated, please complete the following steps:

1. Create `proguard-rules.pro` file under [your_project > android > app] with content as show below:
```
-keep class **.zego.** { *; }
-keep class **.**.zego_zpns.** { *; }
```

2. Add the following config code to the release part of the `your_project/android/app/build.gradle` file.
```
proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
```

![image](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/android_class_confusion_zpns.png)


#### iOS

Need add app permissions, open ·your_project/ios/Runner/Info.plist·, add the following code inside the "dict" tag:

```plist
<key>NSCameraUsageDescription</key>
<string>We require camera access to connect to a call</string>
<key>NSMicrophoneUsageDescription</key>
<string>We require microphone access to connect to a call</string>
```

<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/permission_ios.png" width=800>

### 2. Run & Debug

Now you can simply click the **Run** or **Debug** button to build and run your App on your device.
![/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg)

## Related guide

[Custom prebuilt UI](https://docs.zegocloud.com/article/14748)
