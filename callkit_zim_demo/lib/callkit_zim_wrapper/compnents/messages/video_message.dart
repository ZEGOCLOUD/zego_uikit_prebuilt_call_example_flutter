import 'package:flutter/material.dart';

import '../../services/services.dart';
import 'video_message_player.dart';
import 'video_message_preview.dart';

class ZIMWrapperVideoMessage extends StatelessWidget {
  const ZIMWrapperVideoMessage({
    Key? key,
    this.onPressed,
    this.onLongPress,
    required this.message,
  }) : super(key: key);

  final ZIMWrapperMessage message;
  final void Function(BuildContext context, ZIMWrapperMessage message, Function defaultAction)? onPressed;
  final void Function(
          BuildContext context, LongPressStartDetails details, ZIMWrapperMessage message, Function defaultAction)?
      onLongPress;

  void _onPressed(BuildContext context, ZIMWrapperMessage msg) {
    void defaultAction() => playVideo(context);
    if (onPressed != null) {
      onPressed!.call(context, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  void _onLongPress(BuildContext context, LongPressStartDetails details, ZIMWrapperMessage msg) {
    void defaultAction() {}
    if (onLongPress != null) {
      onLongPress!.call(context, details, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => _onPressed(context, message),
        onLongPressStart: (details) => _onLongPress(context, details, message),
        child: ZIMWrapperVideoMessagePreview(
          message,
          key: ValueKey(message.info.messageID),
        ),
      ),
    );
  }

  void playVideo(BuildContext context) {
    showBottomSheet(
            context: context,
            builder: (context) => ZIMWrapperVideoMessagePlayer(message, key: ValueKey(message.info.messageID)))
        .closed
        .then((value) {
      ZIMWrapperLogger.fine('ZIMWrapperVideoMessage: playVideo end');
    });
  }
}
