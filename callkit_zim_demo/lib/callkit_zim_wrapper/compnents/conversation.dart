import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../callkit_zim_wrapper.dart';

class ZIMWrapperConversationWidget extends StatelessWidget {
  const ZIMWrapperConversationWidget({
    Key? key,
    required this.conversation,
    required this.onPressed,
    this.lastMessageTimeBuilder,
    this.lastMessageBuilder,
    required this.onLongPress,
  }) : super(key: key);

  final ZIMWrapperConversation conversation;

  // ui builder
  final Widget Function(BuildContext context, DateTime? messageTime, Widget defaultWidget)? lastMessageTimeBuilder;
  final Widget Function(BuildContext context, ZIMWrapperMessage? message, Widget defaultWidget)? lastMessageBuilder;

  // event
  final Function(BuildContext context) onPressed;
  final Function(BuildContext context, LongPressStartDetails longPressDetails) onLongPress;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => onPressed(context),
      onLongPressStart: (longPressDetails) => onLongPress(context, longPressDetails),
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: min(screenWidth / 10, 20), vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              badges.Badge(
                showBadge: conversation.unreadMessageCount != 0,
                badgeContent: Text('${conversation.unreadMessageCount}'),
                badgeAnimation: const badges.BadgeAnimation.scale(
                  animationDuration: Duration(milliseconds: 150),
                ),
                child: SizedBox(width: 50, height: 50, child: conversation.icon),
              ),
              if (screenWidth >= 100)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.name.isNotEmpty ? conversation.name : conversation.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Builder(builder: (context) {
                          final defaultWidget = defaultLastMessageBuilder(conversation.lastMessage);
                          return lastMessageBuilder?.call(context, conversation.lastMessage, defaultWidget) ??
                              defaultWidget;
                        }),
                      ],
                    ),
                  ),
                ),
              if (screenWidth >= 250)
                Builder(builder: (context) {
                  final messageTime = conversation.lastMessage != null
                      ? DateTime.fromMillisecondsSinceEpoch(conversation.lastMessage!.info.timestamp)
                      : null;
                  final defaultWidget = defaultLastMessageTimeBuilder(messageTime);
                  return lastMessageTimeBuilder?.call(context, messageTime, defaultWidget) ?? defaultWidget;
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget defaultLastMessageBuilder(ZIMWrapperMessage? message) {
    if (message == null) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: 0.64,
      child: Text(message.tostr(), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget defaultLastMessageTimeBuilder(DateTime? messageTime) {
    if (messageTime == null) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    final duration = DateTime.now().difference(messageTime);

    late String timeStr;

    if (duration.inMinutes < 1) {
      timeStr = 'just now';
    } else if (duration.inHours < 1) {
      timeStr = '${duration.inMinutes} minutes ago';
    } else if (duration.inDays < 1) {
      timeStr = '${duration.inHours} hours ago';
    } else if (now.year == messageTime.year) {
      timeStr = '${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    } else {
      timeStr =
          ' ${messageTime.year}/${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    }

    return Opacity(opacity: 0.64, child: Text(timeStr, maxLines: 1, overflow: TextOverflow.clip));
  }
}
