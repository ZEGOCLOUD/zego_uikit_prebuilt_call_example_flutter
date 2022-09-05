// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Note that the userID needs to be globally unique,
final String localUserID = math.Random().nextInt(10000).toString();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController inviteeUserIDTextCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCallWithInvitation(
      appID: /*input your AppID*/,
      appSign: /*input your AppSign*/,
      userID: localUserID,
      userName: "user_$localUserID",
      //  we will ask you for config when we need it, you can customize your app with data
      requireConfig: (ZegoCallInvitationData data) {
        var config = ZegoUIKitPrebuiltCallConfig();
        config.turnOnCameraWhenJoining =
            ZegoInvitationType.videoCall == data.type;
        return config;
      },
      child: body(context),
    );
  }

  Widget body(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your User ID: $localUserID'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  inviteeUserIDInput(),
                  const SizedBox(width: 5),
                  callButton(false),
                  const SizedBox(width: 5),
                  callButton(true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inviteeUserIDInput() => SizedBox(
    width: 200,
    child: TextFormField(
      controller: inviteeUserIDTextCtrl,
      decoration: const InputDecoration(
        isDense: true,
        hintText: "Please Enter Invitee User ID",
        labelText: "Invitee User ID",
      ),
    ),
  );

  Widget callButton(bool isVideoCall) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: inviteeUserIDTextCtrl,
        builder: (context, inviteeUserID, _) {
          return ZegoStartCallCallInvitation(
            isVideoCall: isVideoCall,
            invitees: [
              ZegoUIKitUser(
                id: inviteeUserIDTextCtrl.text,
                name: 'user_${inviteeUserIDTextCtrl.text}',
              )
            ],
            iconSize: const Size(30, 30),
            buttonSize: const Size(40, 40),
          );
        },
      );
}
