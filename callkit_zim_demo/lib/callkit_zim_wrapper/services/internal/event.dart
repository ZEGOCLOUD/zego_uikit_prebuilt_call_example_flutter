import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'imwrapper_core.dart';

mixin ZIMWrapperCoreEvent {
  void initEventHandler() {
    ZIMWrapperLogger.info('register event handle.');
    final target = ZIMWrapperCore.instance;
    ZegoUIKitSignalingPlugin().eventCenter.passThroughEvent
      /*Conversation*/
      ..onConversationChanged = target.onConversationChanged
      ..onConversationTotalUnreadMessageCountUpdated = target.onConversationTotalUnreadMessageCountUpdated

      /*Message*/
      ..onReceivePeerMessage = target.onReceivePeerMessage
      ..onReceiveRoomMessage = target.onReceiveRoomMessage
      ..onReceiveGroupMessage = target.onReceiveGroupMessage
      ..onMessageRevokeReceived = target.onMessageRevokeReceived

      /*Group*/
      ..onGroupStateChanged = target.onGroupStateChanged
      ..onGroupNameUpdated = target.onGroupNameUpdated
      ..onGroupAvatarUrlUpdated = target.onGroupAvatarUrlUpdated
      ..onGroupNoticeUpdated = target.onGroupNoticeUpdated
      ..onGroupAttributesUpdated = target.onGroupAttributesUpdated
      ..onGroupMemberStateChanged = target.onGroupMemberStateChanged
      ..onGroupMemberInfoUpdated = target.onGroupMemberInfoUpdated;
  }

  void uninitEventHandler() {
    ZIMWrapperLogger.info('unregister event handle.');
    ZegoUIKitSignalingPlugin().eventCenter.passThroughEvent
      /*Conversation*/
      ..onConversationChanged = null
      ..onConversationTotalUnreadMessageCountUpdated = null

      /*Message*/
      ..onReceivePeerMessage = null
      ..onReceiveRoomMessage = null
      ..onReceiveGroupMessage = null
      ..onMessageRevokeReceived = null

      /*Group*/
      ..onGroupStateChanged = null
      ..onGroupNameUpdated = null
      ..onGroupAvatarUrlUpdated = null
      ..onGroupNoticeUpdated = null
      ..onGroupAttributesUpdated = null
      ..onGroupMemberStateChanged = null
      ..onGroupMemberInfoUpdated = null;
  }
}
