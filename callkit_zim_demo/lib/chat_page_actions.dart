import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'callkit_zim_wrapper/callkit_zim_wrapper.dart';
import 'popup_group_chat.dart';

List<Widget>? demoAppBarActions(context, ZIMWrapperConversation conversation) {
  return conversation.type == ZIMConversationType.peer
      ? peerChatCallButtons(context, conversation)
      : [GroupPagePopupMenuButton(groupID: conversation.id)];
}

List<Widget> peerChatCallButtons(context, ZIMWrapperConversation conversation) {
  return [
    for (final isVideoCall in [true, false])
      ZegoSendCallInvitationButton(
        iconSize: const Size(40, 40),
        buttonSize: const Size(50, 50),
        isVideoCall: isVideoCall,
        invitees: [ZegoUIKitUser(id: conversation.id, name: conversation.name)],
        onPressed: (String code, String message, List<String> errorInvitees) {
          onCallInvitationSent(context, code, message, errorInvitees);
        },
      )
  ];
}

void onCallInvitationSent(BuildContext context, String code, String message, List<String> errorInvitees) {
  var log = '';
  if (errorInvitees.isNotEmpty) {
    log = "User doesn't exist or is offline: ${errorInvitees[0]}";
    if (code.isNotEmpty) {
      log += ', code: $code, message:$message';
    }
  } else if (code.isNotEmpty) {
    log = 'code: $code, message:$message';
  }
  if (log.isEmpty) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(log)),
  );
}
