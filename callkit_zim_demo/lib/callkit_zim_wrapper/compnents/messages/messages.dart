import 'package:flutter/material.dart';

import '../../services/services.dart';
import '../common/common.dart';
import 'audio_message.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'text_message.dart';
import 'video_message.dart';
import 'widgets/widgets.dart';

export 'audio_message.dart';
export 'text_message.dart';
export 'video_message.dart';

class ZIMWrapperMessageWidget extends StatelessWidget {
  const ZIMWrapperMessageWidget({
    Key? key,
    this.onPressed,
    this.onLongPress,
    this.statusBuilder,
    this.avatarBuilder,
    this.timestampBuilder,
    required this.message,
  }) : super(key: key);

  final ZIMWrapperMessage message;

  final Widget Function(BuildContext context, ZIMWrapperMessage message, Widget defaultWidget)? avatarBuilder;
  final Widget Function(BuildContext context, ZIMWrapperMessage message, Widget defaultWidget)? statusBuilder;
  final Widget Function(BuildContext context, ZIMWrapperMessage message, Widget defaultWidget)? timestampBuilder;
  final void Function(BuildContext context, ZIMWrapperMessage message, Function defaultAction)? onPressed;
  final void Function(
          BuildContext context, LongPressStartDetails details, ZIMWrapperMessage message, Function defaultAction)?
      onLongPress;

  Widget buildMessage(BuildContext context) {
    switch (message.type) {
      case ZIMMessageType.text:
        return ZIMWrapperTextMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.audio:
        return ZIMWrapperAudioMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.video:
        return ZIMWrapperVideoMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.file:
        return ZIMWrapperFileMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.image:
        return ZIMWrapperImageMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.revoke:
        return const Text('Recalled a message.');

      default:
        return Text(message.tostr());
    }
  }

  Widget buildStatus(BuildContext context) {
    final Widget defaultStatusWidget = ZIMWrapperMessageStatusDot(message);
    return statusBuilder?.call(context, message, defaultStatusWidget) ?? defaultStatusWidget;
  }

  Widget buildAvatar(BuildContext context) {
    final Widget defaultAvatarWidget = ZIMWrapperAvatar(userID: message.info.senderUserID, width: 50, height: 50);
    return avatarBuilder?.call(context, message, defaultAvatarWidget) ?? defaultAvatarWidget;
  }

  List<Widget> localMessage(BuildContext context) {
    return [
      buildMessage(context),
      // buildAvatar(context),
      buildStatus(context),
    ];
  }

  List<Widget> remoteMessage(BuildContext context) {
    return [
      buildAvatar(context),
      const SizedBox(width: 10),
      buildMessage(context),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: FractionallySizedBox(
        widthFactor: 0.66,
        alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (message.isMine) ...localMessage(context),
            if (!message.isMine) ...remoteMessage(context),
          ],
        ),
      ),
    );
  }
}
