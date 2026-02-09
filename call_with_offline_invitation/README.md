# Quick start

---

## Add ZegoUIKitPrebuiltCallWithInvitation as dependencies

Run this command with Flutter:

```
flutter pub add zego_uikit_signaling_plugin
```

## Import SDK

Now in your Dart code, you can import prebuilt.

```dart
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
```


## Integrate the SDK with the offline call invitation feature

1. Wrap your widget with ZegoUIKitPrebuiltCallWithInvitation, and specify the `userID` and `userName` for connecting the Call Kit service. 




#### Props of ZegoUIKitPrebuiltCallWithInvitation component

<table>
  <colgroup>
    <col width="20%">
    <col width="22%">
    <col width="8%">
    <col width="50%">
  </colgroup>
<tbody><tr>
<th>Property&nbsp;</th>
<th>Type&nbsp;</th>
<th>Required</th>
<th>Description</th>
</tr>
<tr>
<td>appID</td>
<td>int&nbsp;</td>
<td>Yes</td>
<td>The App ID you get from [ZEGOCLOUD Admin Console](https://console.zegocloud.com).&nbsp;</td>
</tr>
<tr>
<td>appSign</td>
<td>String&nbsp;</td>
<td>Yes</td>
<td>The App Sign you get from [ZEGOCLOUD Admin Console](https://console.zegocloud.com).&nbsp;</td>
</tr>
<tr>
<td>userID</td>
<td>String&nbsp;</td>
<td>Yes</td>
<td>`userID` can be something like a phone number or the user ID on your own user system. userID can only contain numbers, letters, and underlines (_).&nbsp;&nbsp;</td>
</tr>
<tr>
<td>userName&nbsp;</td>
<td>String</td>
<td>Yes</td>
<td>`userName` can be any character or the user name on your own user system.</td>
</tr>
<tr>
<td>plugins&nbsp;&nbsp;</td>
<td>List< IZegoUIKitPlugin ></td>
<td>Yes</td>
<td>Fixed value. Set it to `ZegoUIKitSignalingPlugin` as shown in the sample.&nbsp;</td>
</tr>
<tr>
<td>ringtoneConfig&nbsp;</td>
<td>ZegoRingtoneConfig&nbsp;</td>
<td>No</td>
<td>`ringtoneConfig.incomingCallPath` and `ringtoneConfig.outgoingCallPath` is the asset path of the ringtone file, which requires you a manual import. To know how to import, refer to [Custom prebuilt UI](https://docs.zegocloud.com/article/14748).&nbsp;</td>
</tr>
<tr>
<td>requireConfig&nbsp;&nbsp;</td>
<td>ZegoUIKitPrebuiltCallConfig Function(
    ZegoCallInvitationData)?&nbsp;</td>
<td>No</td>
<td>This method is called when you receive a call invitation. You can control the SDK behaviors by returning the required config based on the data parameter. For more details, see [Custom prebuilt UI](https://docs.zegocloud.com/article/14748).&nbsp;</td>
</tr>
<tr>
<td>notifyWhenAppRunningInBackgroundOrQuit</td>
<td>bool&nbsp;</td>
<td>No</td>
<td>Change `notifyWhenAppRunningInBackgroundOrQuit` to false if you don't need to receive a call invitation notification while your app running in the background or quit.</td>
</tr>
<tr>
<td>isIOSSandboxEnvironment</td>
<td>bool</td>
<td>No</td>
<td>To publish your app to TestFlight or App Store, set the `isIOSSandboxEnvironment` to false before starting building. To debug locally, set it to true. Ignore this when the `notifyWhenAppRunningInBackgroundOrQuit` is false.</td>
</tr>
<tr>
<td>androidNotificationConfig&nbsp;</td>
<td>ZegoAndroidNotificationConfig?</td>
<td>No</td>
<td>This property needs to be set when you are building an Android app and when the `notifyWhenAppRunningInBackgroundOrQuit` is true.  `androidNotificationConfig.channelID` must be the same as the FCM Channel ID in [ZEGOCLOUD Admin Console](https://console.zegocloud.com), and the `androidNotificationConfig.channelName` can be an arbitrary value.&nbsp;</td>
</tr>
<tr>
<td>innerText</td>
<td>ZegoCallInvitationInnerText</td>
<td>No</td>
<td>To modify the UI text, use this property. For more details, see [Custom prebuilt UI](https://docs.zegocloud.com/article/14748).&nbsp;&nbsp;</td>
</tr>
</tbody></table>

For more parameters, go to [Custom prebuilt UI](https://docs.zegocloud.com/article/14748).

```dart
@override
Widget build(BuildContext context) {
   return ZegoUIKitPrebuiltCallWithInvitation(
      appID: yourAppID,
      serverSecret: yourServerSecret,
      appSign: yourAppSign,
      userID: userID,
      userName: userName,
      config: ZegoUIKitPrebuiltCallInvitationConfig(
            notifyWhenAppRunningInBackgroundOrQuit: true,
            isIOSSandboxEnvironment: false,
      ),
      plugins: [ZegoUIKitSignalingPlugin()],
      child: YourWidget(),
   );
}
```

2. Add the button for making call invitations, and pass in the ID of the user you want to call.

#### Props of ZegoSendCallInvitationButton

<table>
  <colgroup>
    <col width="15%">
    <col width="15%">
    <col width="10%">
    <col width="60%">
  </colgroup>
<tbody><tr>
<th>Property&nbsp;&nbsp;</th>
<th>Type</th>
<th>Required</th>
<th>Description</th>
</tr>
<tr>
<td>invitees</td>
<td>List< ZegoUIKitUser ></td>
<td>Yes</td>
<td>The information of the callee. userID and userName are required. For example: [{ userID: inviteeID, userName: inviteeName }]</td>
</tr>
<tr>
<td>isVideoCall&nbsp;</td>
<td>bool</td>
<td>Yes</td>
<td>If true, a video call is made when the button is pressed. Otherwise, a voice call is made.</td>
</tr>
<tr>
<td>resourceID&nbsp;</td>
<td>String?</td>
<td>No</td>
<td>`resourceID` can be used to specify the ringtone of an offline call invitation, which must be set to the same value as the Push Resource ID in [ZEGOCLOUD Admin Console](https://console.zegocloud.com). This only takes effect when the `notifyWhenAppRunningInBackgroundOrQuit` is true.</td>
</tr>
<tr>
<td>timeoutSeconds&nbsp;</td>
<td>int</td>
<td>No</td>
<td>The timeout duration. It's 60 seconds by default.</td>
</tr>
</tbody></table>

For more parameters, go to [Custom prebuilt UI](https://docs.zegocloud.com/article/14748).

```dart
ZegoSendCallInvitationButton(
   isVideoCall: true,
   resourceID: "zegouikit_call",    // For offline call notification
   invitees: [
      ZegoUIKitUser(
         id: targetUserID,
         name: targetUserName,
      ),
      ...
      ZegoUIKitUser(
         id: targetUserID,
         name: targetUserName,
      )
   ],
)
```

Now, you can make call invitations by simply clicking on this button.


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
            ZegoLiveStreamingInvitationType.videoCall == data.type;
        if (ZegoLiveStreamingInvitationType.videoCall == data.type) {
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

1. Need add app permissions, open ·your_project/ios/Runner/Info.plist·, add the following code inside the "dict" tag:

```plist
<key>NSCameraUsageDescription</key>
<string>We require camera access to connect to a call</string>
<key>NSMicrophoneUsageDescription</key>
<string>We require microphone access to connect to a call</string>
```

<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/permission_ios.png" width=800>

2. To use the notifications and build your app correctly, navigate to the Build Settings tab, and set the following build options for your target app.

<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/ios_distribution.png" width=800>


Refer to and set the following build options:

- In the **Runner** Target:
    
    a. **Build Libraries for Distribution** -> `NO`

    b. **Only safe API extensions** -> `NO`

    c. **iOS Deployment Target** -> `11 or greater`

- In other Targets:
        
    a. **Build Libraries for Distribution** -> `NO`

    b. **Only safe API extensions** -> `YES`


# Enable offline call invitation

If you want to receive call invitation notifications, do the following: 
1. Click the button below to contact ZEGOCLOUD Technical Support.

    <a href="https://discord.gg/ExaKJvBbxy">
    <img src="https://img.shields.io/discord/980014613179555870?color=5865F2&logo=discord&logoColor=white" alt="ZEGOCLOUD"/>
</a>

2. Then, follow the instructions in the video below.

- iOS:

[![Watch the video](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/videos/how_to_enable_offline_call_invitation_ios.png)](https://youtu.be/rzdRY8bDqdo)

Resource may help: [Apple Developer](https://developer.apple.com)

- Android:

1. Add this line to your project's `my_project/android/app/build.gradle` file as instructed.

```xml
implementation 'com.google.firebase:firebase-messaging:21.1.0'
```

2. In your project's `/app/src/main/res/raw` directory, create a `keep.xml` file with the following contents:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@raw/*">
</resources>
```
![call_keep_xml.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/call/call_keep_xml.png)

3. Then, follow the instructions in the video below.
[![Watch the video](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/videos/how_to_enable_offline_call_invitation_android.png)](https://youtu.be/mhetL3MTKsE)

Resource may help: [Firebase Console](https://console.firebase.google.com/)

4. Check whether the local config is set up properly.
- Download the [zego_check_android_offline_notification.py\|_blank](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter/blob/master/call_with_offline_invitation/zego_check_android_offline_notification.py) to your project's root directory, and run the following command:

```bash
python3 zego_check_android_offline_notification.py
```
- You will see the following if everything goes well: 
```
✅ The google-service.json is in the right location.
✅ The package name matches google-service.json.
✅ The project level gradle file is ready.
✅ The plugin config in the app-level gradle file is correct.
✅ Firebase dependencies config in the app-level gradle file is correct.
✅ Firebase-Messaging dependencies config in the app-level gradle file is correct.
```

### 2. Run & Debug

Now you can simply click the **Run** or **Debug** button to build and run your App on your device.
![run_flutter_project.jpg](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg)

## Related guide

[Custom prebuilt UI](https://docs.zegocloud.com/article/14748)
