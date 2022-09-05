# Quick start

---

## Add ZegoUIKitPrebuiltLiveStreaming as dependencies

1. Edit your project's pubspec.yaml and add local project dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  zego_uikit_prebuilt_live_streaming: ^0.0.6 # Add this line
```

2. Execute the command as shown below under your project's root folder to install all dependencies

```
flutter pub get
```

## Import SDK

Now in your Dart code, you can import prebuilt.

```dart
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
```

## Integrate the live streaming

> You can get the AppID and AppSign from [ZEGOCLOUD&#39;s Console](https://console.zegocloud.com).
> Users who use the same liveName can in the same live streaming. (ZegoUIKitPrebuiltLiveStreaming supports 1 host Live for now)
> you can customize UI by config properties

```dart
@override
Widget build(BuildContext context) {
   return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
         appID: /*Your App ID*/,
         appSign: /*Your App Sign*/,
         userID: user_id, // userID should only contain numbers, English characters and  '_'
         userName: 'user_name',
         liveName: 'live_name',
         config: ZegoUIKitPrebuiltLiveStreamingConfig(
            // set config properties based on roles, UI will drive by properties
            turnOnCameraWhenJoining: isHost,
            turnOnMicrophoneWhenJoining: isHost,
            useSpeakerWhenJoining: !isHost,
            bottomMenuBarConfig: ZegoBottomMenuBarConfig(
               menuBarButtons: isHost
                       ? [
                  ZegoLiveMenuBarButtonName.toggleCameraButton,
                  ZegoLiveMenuBarButtonName.toggleMicrophoneButton,
                  ZegoLiveMenuBarButtonName.switchCameraButton,
               ]
                       : const [],
            ),
            useEndLiveStreamingButton: isHost,
         ),
      ),
   );
}
```

**Now, you can start a live stream, other people who enter the same '*live name*' can watch your live stream.**

## How to run

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
   ```
<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/live/permission_android.png" width=800>

#### iOS

Need add app permissions, open ·your_project/ios/Runner/Info.plist·, add the following code inside the "dict" tag:

```plist
<key>NSCameraUsageDescription</key>
<string>We require camera access to connect to a live</string>
<key>NSMicrophoneUsageDescription</key>
<string>We require microphone access to connect to a live</string>
```
<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/live/permission_ios.png" width=800>

### 2. Build & Run

Now you can simply click the "Run" or "Debug" button to build and run your App on your device.
![/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg)

## Related guide

[Custom prebuilt UI](!ZEGOUIKIT_Custom_prebuilt_UI)
