// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

/// Note that the userID needs to be globally unique,
final String localUserID = Random().nextInt(10000).toString();

/// Users who use the same liveName can in the same live streaming.
/// (ZegoUIKitPrebuiltLiveStreaming supports 1 host Live for now)
const String liveName = "live_name";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(120, 60),
      primary: const Color(0xff2C2F3E).withOpacity(0.6),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("your project")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please test with two or more devices'),
            const SizedBox(height: 60),
            // click floatingActionButton to navigate to LivePage
            ElevatedButton(
              style: buttonStyle,
              child: const Text('Start a live'),
              onPressed: () =>
                  jumpToLivePage(context, liveName: liveName, isHost: true),
            ),
            const SizedBox(height: 60),
            // click floatingActionButton to navigate to LivePage
            ElevatedButton(
              style: buttonStyle,
              child: const Text('Watch a live'),
              onPressed: () =>
                  jumpToLivePage(context, liveName: liveName, isHost: false),
            ),
          ],
        ),
      ),
    );
  }

  jumpToLivePage(BuildContext context,
      {required String liveName, required bool isHost}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LivePage(liveName: liveName, isHost: isHost);
        },
      ),
    );
  }
}

// integrate code :
class LivePage extends StatelessWidget {
  final String liveName;
  final bool isHost;

  const LivePage({
    Key? key,
    required this.liveName,
    this.isHost = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: /*input your AppID*/,
        appSign: /*input your AppSign*/,
        userID: localUserID,
        userName: 'user_$localUserID',
        liveName: liveName,
        config: ZegoUIKitPrebuiltLiveStreamingConfig(
          // true if you are the host, false if you are a audience
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
}
