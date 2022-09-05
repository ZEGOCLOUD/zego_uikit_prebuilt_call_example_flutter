// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Note that the userID needs to be globally unique,
final String localUserID = math.Random().nextInt(10000).toString();

/// Users who use the same callID can in the same call.
const String callID = "call_id";

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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.call),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return ZegoUIKitPrebuiltCall(
              appID: /*input your AppID*/,
              appSign: /*input your AppSign*/,
              userID: localUserID,
              userName: "user_$localUserID",
              callID: callID,
              config: ZegoUIKitPrebuiltCallConfig(),
            );
          }),
        ),
      ),
    );
  }
}
