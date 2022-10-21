// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

/// Note that the userID needs to be globally unique,
final String localUserID = math.Random().nextInt(10000).toString();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CallInvitationPage());
  }
}

class CallInvitationPage extends StatelessWidget {
  CallInvitationPage({Key? key}) : super(key: key);
  final TextEditingController inviteeUsersIDTextCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCallInvitationService(
      appID: /*input your AppID*/,
      appSign: /*input your AppSign*/,
      userID: localUserID,
      userName: "user_$localUserID",
      plugins: [ZegoUIKitSignalingPlugin()],
      requireConfig: (ZegoCallInvitationData data) {
        var config = (data.invitees.length > 1)
            ? ZegoInvitationType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            : ZegoInvitationType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        // Modify your custom configurations here.
        return config;
      },
      child: yourPage(context),
    );
  }

  Widget yourPage(BuildContext context) {
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

        return ZegoStartCallInvitationButton(
          isVideoCall: isVideoCall,
          invitees: invitees,
          iconSize: const Size(40, 40),
          buttonSize: const Size(50, 50),
        );
      },
    );
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
