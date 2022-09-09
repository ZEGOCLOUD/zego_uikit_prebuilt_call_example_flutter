# Quick start

---

## Add ZegoUIKitPrebuiltCallWithInvitation as dependencies

1. Edit your project's pubspec.yaml and add local project dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  zego_uikit_signal_plugin: ^0.0.1 # Add this line
```

2. Execute the command as shown below under your project's root folder to install all dependencies

```dart
flutter pub get
```

## Import SDK

Now in your Dart code, you can import prebuilt.

```dart
import 'package:zego_uikit_signal_plugin/zego_uikit_signal_plugin.dart';
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
      userName: useName,
      requireConfig: (ZegoCallInvitationData data) {
        return ZegoUIKitPrebuiltCallConfig();
      },
      child: YourWidget(),
   );
}
```

### 2. Add a button for making a call

```dart
ZegoStartCallCallInvitation(
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

1. If your project was created with a version of flutter that is not the latest stable, you may need to manually modify compileSdkVersion in `your_project/android/app/build.gradle` to 33

   ![compileSdkVersion](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/compile_sdk_version.png)

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
   <uses-permission android:name="android.permission.VIBRATE"/>
   ```

<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/invitation/permission_android.png" width=800>

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

[Custom prebuilt UI](!ZEGOUIKIT_Custom_prebuilt_UI)

## Resources

[Complete Sample Code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example/tree/master/call_with_invitation/flutter)
