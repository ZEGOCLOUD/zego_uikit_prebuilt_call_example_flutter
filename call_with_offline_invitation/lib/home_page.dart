import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? localUserID;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    localUserID = args[PageParam.localUserID] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: ZegoUIKitPrebuiltCallWithInvitation(
        appID: /*input your AppID*/,
        appSign: /*input your AppSign*/,
        userID: localUserID ?? '',
        userName: "user_${localUserID ?? ''}",
        notifyWhenAppRunningInBackgroundOrQuit: true,
        isIOSSandboxEnvironment: false,
        androidNotificationConfig: ZegoAndroidNotificationConfig(
          channelID: "ZegoUIKit",
          channelName: "Call Notifications",
          sound: "zego_incoming",
        ),
        plugins: [ZegoUIKitSignalingPlugin()],
        child: userListView(),
      ),
    );
  }

  Widget userListView() {
    return Center(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          final userName = "User $index";
          return Row(
            children: [
              const SizedBox(width: 20),
              Text(userName, style: textStyle),
              Expanded(child: Container()),
              ElevatedButton(
                child: const Text("Details", style: textStyle),
                onPressed: () {
                  /// WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                  /// Don't user pushReplacementNamed,
                  /// pushReplacementNamed will replace current page,
                  /// then destroy ZegoUIKitPrebuiltCallWithInvitation
                  Navigator.pushNamed(
                    context,
                    PageRouteNames.call,
                    arguments: <String, String>{
                      PageParam.localUserID: localUserID ?? '',
                    },
                  );
                },
              ),
              const SizedBox(width: 20),
            ],
          );
        },
      ),
    );
  }
}
