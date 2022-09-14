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
    return MaterialApp(home: GroupCallPage());
  }
}

class GroupCallPage extends StatelessWidget {
  /// Users who use the same callID can in the same call.
  var callIDTextCtrl = TextEditingController(text: "group_call_id");

  GroupCallPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  controller: callIDTextCtrl,
                  decoration: const InputDecoration(
                      labelText: "join a group call by id"),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    onCallButtonPressed(context);
                  },
                  child: const Text("join"))
            ],
          ),
        ),
      ),
    );
  }

  void onCallButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SafeArea(
          child: ZegoUIKitPrebuiltCall(
            appID: /*input your AppID*/,
            appSign: /*input your AppSign*/,
            userID: localUserID,
            userName: "user_$localUserID",
            callID: callIDTextCtrl.text,
            config: ZegoUIKitPrebuiltCallConfig.group(isVideo: true),
          ),
        );
      }),
    );
  }
}
