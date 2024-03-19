// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Project imports:
import 'common.dart';
import 'constants.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CallPageState();
}

class CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, String>{}) as Map<String, String>;
    final callID = arguments[PageParam.call_id] ?? '';

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: yourAppID /*input your AppID*/,
        appSign: yourAppSign /*input your AppSign*/,
        userID: currentUser.id,
        userName: currentUser.name,
        callID: callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()

          /// support minimizing
          ..topMenuBar.isVisible = true
          ..topMenuBar.buttons = [
            ZegoCallMenuBarButtonName.minimizingButton,
            ZegoCallMenuBarButtonName.showMemberListButton,
            ZegoCallMenuBarButtonName.soundEffectButton,
          ]
          ..avatarBuilder = customAvatarBuilder,
      ),
    );
  }
}
