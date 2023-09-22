# This demo shows how to integrate the ZIM SDK when using CallKit.

Please read the following carefully before starting.

Please read the following carefully before starting.

Please read the following carefully before starting.

# When using CallKit, how to integrate zimsdk?

Due to the fact that CallKit and zimkit both use the same basic SDK (named zim sdk), they need to share some intricate low-level code in order for everything to work properly. Therefore, it is not recommended to use Kit series products together with the basic SDK(zim sdk).

If zimkit does not meet your requirements, we suggest referring to the implementation of zimkit and gradually modifying it to align with your needs. There are several benefits to this approach:

You can quickly integrate the functions already implemented in zimkit, such as group chat, one-on-one chat, group management, handling of read/unread messages, dynamic loading of message lists, and dynamic loading of conversation lists.
In areas where zimkit does not meet your requirements, you can make any reasonable modifications to the parts that need to be changed according to your needs.
Of course, this requires you to have the ability to read and understand how zimkit's source code works. This may be challenging for some developers, but it is much more stable, reliable, and cost-effective than developing the same features from scratch.

Finally, if you really do not want to use any code from zimkit, you still need to refer to the documentation below and understand the basic limitations when using callkit+zim together, and then develop everything from scratch (which we highly discourage)."


# 1. Basic Guide for Reading Demo Source Code

1. Initialize SDK: `lib/main.dart`
2. User login: `lib/login_page.dart`
3. Conversation list: `lib/callkit_zim_wrapper/components/conversation_list.dart`
4. Chat page: `lib/callkit_zim_wrapper/components/message_list.dart`
5. Chat input box: `lib/callkit_zim_wrapper/components/message_list.dart`

# 2. How to call the API method of ZIM SDK

In fact, there are no restrictions on this. You can read the documentation of ZIM to get an introduction to its features and use the same method as described in the documentation to call the ZIM API.

For example, to send a message:

```dart
ZIM.getInstance()!.sendMessage(...)
```

It is recommended that you use the same method as the demo to call ZIM. Please read the code in `lib/callkit_zim_wrapper/services/message_service.dart` of the Demo, make sure you understand it before making any modifications.

When you need to call the ZIM interface, please follow the steps below:

1. Search for the interface in callkit_zim_wrapper to see if there is already a wrapper for it.
2. If there is, it is recommended to review the code of the existing wrapper and use it directly. If the existing interface does not meet your needs, you can add parameters and modify it (make sure you understand it before making any modifications).
3. If there is no existing wrapper, you can refer to the wrapping method of interfaces like `sendMessage` and create a wrapper for the new interface following these steps:
   1. Add the wrapper for the interface in `lib/callkit_zim_wrapper/services/internal/imwrapper_core_*.dart`.
   2. Call the interface in `lib/callkit_zim_wrapper/services/input_service.dart`. This is a common Interface-Implementation encapsulation method, which is beneficial for code maintenance.
4. If the new interface call involves data maintenance, such as message data or session list data, you can refer to `ZIMWrapperDB` to understand the data maintenance method. In the demo's DB, we often use `ValueNotifier` and `ListNotifier` to encapsulate data, which makes it easy to obtain updates of underlying data when implementing the UI.


# 3. How to listen for event callbacks in the ZIM SDK

You must use `ZegoUIKitSignalingPlugin().eventCenter.passThroughEvent` to listen for events in the ZIM SDK, the timing of the triggers is completely consistent.

> We frequently update the `ZegoUIKitSignalingPlugin` class to have the same callback list as the ZIM SDK.

You can see all the ZIM callback events [here](https://pub.dev/documentation/zego_zim/latest/zego_zim/ZIMEventHandler-class.html).

You can refer to the code in `lib/callkit_zim_wrapper/services/internal/event.dart` for this part.

```dart
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
```

