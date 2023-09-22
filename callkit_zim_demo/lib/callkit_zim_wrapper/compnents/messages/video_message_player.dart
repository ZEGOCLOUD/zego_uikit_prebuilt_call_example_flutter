import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/services.dart';
import 'video_message_controls.dart';
import 'video_message_preview.dart';

class ZIMWrapperVideoMessagePlayer extends StatefulWidget {
  const ZIMWrapperVideoMessagePlayer(this.message, {Key? key}) : super(key: key);

  final ZIMWrapperMessage message;

  @override
  State<ZIMWrapperVideoMessagePlayer> createState() => ZIMWrapperVideoMessagePlayerState();
}

class ZIMWrapperVideoMessagePlayerState extends State<ZIMWrapperVideoMessagePlayer> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  late Future<void> initing;

  @override
  Future<void> dispose() async {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.message.videoContent!.fileLocalPath.isNotEmpty &&
        (widget.message.videoContent!.fileLocalPath.endsWith('mp4') ||
            widget.message.videoContent!.fileLocalPath.endsWith('mov')) &&
        File(widget.message.videoContent!.fileLocalPath).existsSync()) {
      ZIMWrapperLogger.fine('ZIMWrapperVideoMessagePlayer: initPlayer from local '
          'file: ${widget.message.videoContent!.fileLocalPath}');
      videoPlayerController =
          VideoPlayerController.file(File(/*Uri.encodeComponent*/ widget.message.videoContent!.fileLocalPath));
    } else {
      ZIMWrapperLogger.fine('ZIMWrapperVideoMessagePlayer: initPlayer from network: '
          '${widget.message.videoContent!.fileDownloadUrl}');
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.message.videoContent!.fileDownloadUrl));
    }

    // TODO
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        looping: true,
        customControls: const ZIMWrapperCustomControls(),
        placeholder:
            Center(child: ZIMWrapperVideoMessagePreview(widget.message, key: ValueKey(widget.message.info.messageID))))
      ..setVolume(1.0)
      ..play();

    initing = videoPlayerController.initialize();

    Future.delayed(const Duration(seconds: 4)).then((value) {
      if (!chewieController.videoPlayerController.value.isInitialized) {
        ZIMWrapperLogger.severe(
            'videoPlayerController is not initialized, ${widget.message.videoContent!.fileLocalPath}');
        ZIMWrapperLogger.shout(context, "Seems Can't play this video, ${widget.message.videoContent!.fileLocalPath}");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: initing,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                ZIMWrapperLogger.fine('ZIMWrapperVideoMessagePlayer: videoPlayerController initialize done');
                return Chewie(key: ValueKey(widget.message.info.messageID), controller: chewieController);
              } else {
                ZIMWrapperLogger.fine('ZIMWrapperVideoMessagePlayer: videoPlayerController initializing...');
                return Chewie(key: ValueKey(snapshot.hashCode), controller: chewieController);
              }
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
