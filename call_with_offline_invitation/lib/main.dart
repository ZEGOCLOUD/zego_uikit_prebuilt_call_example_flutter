// Dart imports:
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';


/// Note that the userID needs to be globally unique,
String localUserID = '';

/// on user login
void onUserLogin() {
  /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: YourSecret.appID /*input your AppID*/,
    appSign: YourSecret.appSign /*input your AppSign*/,
    userID: localUserID,
    userName: "user_$localUserID",
    notifyWhenAppRunningInBackgroundOrQuit: true,
    isIOSSandboxEnvironment: false,
    androidNotificationConfig: ZegoAndroidNotificationConfig(
      channelID: "ZegoUIKit",
      channelName: "Call Notifications",
      sound: "zego_incoming",
    ),
    plugins: [ZegoUIKitSignalingPlugin()],
  );
}

/// on user logout
void onUserLogout() {
  /// 5/5. de-initialization ZegoUIKitPrebuiltCallInvitationService when account is logged out
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// 1/5: define a navigator key
  final navigatorKey = GlobalKey<NavigatorState>();

  /// 2/5: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  getUniqueUserId().then((userID) {
    localUserID = userID;
    onUserLogin();

    ZegoUIKit().initLog().then((value) {
      runApp(MyApp(navigatorKey: navigatorKey));
    });
  });

  onUserLogout();
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 3/5: register the navigator key to MaterialApp
    navigatorKey: widget.navigatorKey,
      home: const CallInvitationPage(),
    );
  }
}

class CallInvitationPage extends StatefulWidget {
  const CallInvitationPage({
    Key? key,
  }) : super(key: key);

  @override
  State<CallInvitationPage> createState() => _CallInvitationPageState();
}

class _CallInvitationPageState extends State<CallInvitationPage> {
  bool isChatEnabled = true;
  bool isUpdatingRoomProperty = false;
  final TextEditingController inviteeUsersIDTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your userID: $localUserID'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  inviteeUserIDInput(),
                  const SizedBox(width: 5),
                  callButton(false),
                  const SizedBox(width: 5),
                  callButton(true),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inviteeUserIDInput() {
    return Expanded(
      child: TextFormField(
        controller: inviteeUsersIDTextCtrl,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
        ],
        decoration: const InputDecoration(
          isDense: true,
          hintText: "Please Enter Invitees ID",
          labelText: "Invitees ID, Separate ids by ','",
        ),
      ),
    );
  }

  Widget callButton(bool isVideoCall) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: inviteeUsersIDTextCtrl,
      builder: (context, inviteeUserID, _) {
        var invitees = getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.text);

        return ZegoSendCallInvitationButton(
          isVideoCall: isVideoCall,
          invitees: invitees,
          resourceID: "zegouikit_call",
          iconSize: const Size(40, 40),
          buttonSize: const Size(50, 50),
          onPressed: onSendCallInvitationFinished,
        );
      },
    );
  }

  void onSendCallInvitationFinished(
      String code, String message, List<String> errorInvitees) {
    if (errorInvitees.isNotEmpty) {
      String userIDs = "";
      for (int index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        var userID = errorInvitees.elementAt(index);
        userIDs += userID + ' ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var message = 'User doesn\'t exist or is offline: $userIDs';
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      showToast(
        message,
        position: StyledToastPosition.top,
        context: context,
      );
    } else if (code.isNotEmpty) {
      showToast(
        'code: $code, message:$message',
        position: StyledToastPosition.top,
        context: context,
      );
    }
  }

  List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
    List<ZegoUIKitUser> invitees = [];

    var inviteeIDs = textCtrlText.trim().replaceAll('，', '');
    inviteeIDs.split(",").forEach((inviteeUserID) {
      if (inviteeUserID.isEmpty) {
        return;
      }

      invitees.add(ZegoUIKitUser(
        id: inviteeUserID,
        name: 'user_$inviteeUserID',
      ));
    });

    return invitees;
  }
}

Future<String> getUniqueUserId() async {
  String? deviceID;
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    deviceID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    deviceID = androidDeviceInfo.androidId; // unique ID on Android
  }

  if (deviceID != null && deviceID.length < 4) {
    if (Platform.isAndroid) {
      deviceID += "_android";
    } else if (Platform.isIOS) {
      deviceID += "_ios___";
    }
  }
  if (Platform.isAndroid) {
    deviceID ??= "flutter_user_id_android";
  } else if (Platform.isIOS) {
    deviceID ??= "flutter_user_id_ios";
  }

  var userID = md5
      .convert(utf8.encode(deviceID!))
      .toString()
      .replaceAll(RegExp(r'[^0-9]'), '');
  return userID.substring(userID.length - 6);
}
