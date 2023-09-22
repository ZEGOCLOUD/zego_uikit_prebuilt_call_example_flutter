import 'dart:async';

import 'package:flutter/material.dart';

import '../callkit_zim_wrapper.dart';
import '../compnents/messages/widgets/pick_file_button.dart';

class ZIMWrapperMessageListPage extends StatelessWidget {
  const ZIMWrapperMessageListPage({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.appBarBuilder,
    this.appBarActions,
    this.messageInputActions,
    this.onMessageSent,
    this.preMessageSending,
    this.inputDecoration,
    this.showPickFileButton = true,
    this.showPickMediaButton = true,
    this.editingController,
    this.messageListScrollController,
    this.onMessageItemPressd,
    this.onMessageItemLongPress,
    this.messageItemBuilder,
    this.messageListErrorBuilder,
    this.messageListLoadingBuilder,
    this.messageListBackgroundBuilder,
    this.theme,
    this.onMediaFilesPicked,
    this.sendButtonWidget,
    this.pickMediaButtonWidget,
    this.pickFileButtonWidget,
    this.inputFocusNode,
    this.inputBackgroundDecoration,
  }) : super(key: key);

  /// this page's conversationID
  final String conversationID;

  /// this page's conversationType
  final ZIMConversationType conversationType;

  /// if you just want add some actions to the appBar, use [appBarActions].
  ///
  /// use it like this:
  /// appBarActions:[
  ///   IconButton(icon: const Icon(Icons.local_phone), onPressed: () {}),
  ///   IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
  /// ],
  final List<Widget>? appBarActions;

  // if you want customize the appBar, use appBarBuilder return your custom appBar
  // if you don't want use appBar, return null
  final AppBar? Function(BuildContext context, AppBar defaultAppBar)? appBarBuilder;

  /// To add your own action, use the [messageInputActions] parameter like this:
  ///
  /// use [messageInputActions] like this to add your custom actions:
  ///
  /// actions: [
  ///   ZIMWrapperMessageInputAction.left(
  ///     IconButton(icon: Icon(Icons.mic), onPressed: () {})
  ///   ),
  ///   ZIMWrapperMessageInputAction.leftInside(
  ///     IconButton(icon: Icon(Icons.sentiment_satisfied_alt_outlined), onPressed: () {})
  ///   ),
  ///   ZIMWrapperMessageInputAction.rightInside(
  ///     IconButton(icon: Icon(Icons.cabin), onPressed: () {})
  ///   ),
  ///   ZIMWrapperMessageInputAction.right(
  ///     IconButton(icon: Icon(Icons.sd), onPressed: () {})
  ///   ),
  /// ],
  final List<ZIMWrapperMessageInputAction>? messageInputActions;

  /// Called when a message is sent.
  final void Function(ZIMWrapperMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMWrapperMessage> Function(ZIMWrapperMessage)? preMessageSending;

  /// By default, [ZIMWrapperMessageInput] will show a button to pick file.
  /// If you don't want to show this button, set [showPickFileButton] to false.
  final bool showPickFileButton;

  /// By default, [ZIMWrapperMessageInput] will show a button to pick media.
  /// If you don't want to show this button, set [showPickMediaButton] to false.
  final bool showPickMediaButton;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use.
  /// if not provided, a default one will be created.
  final TextEditingController? editingController;

  /// The [ScrollController] to use.
  /// if not provided, a default one will be created.
  final ScrollController? messageListScrollController;

  final void Function(BuildContext context, ZIMWrapperMessage message, Function defaultAction)? onMessageItemPressd;
  final void Function(
          BuildContext context, LongPressStartDetails details, ZIMWrapperMessage message, Function defaultAction)?
      onMessageItemLongPress;
  final Widget Function(BuildContext context, ZIMWrapperMessage message, Widget defaultWidget)? messageItemBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? messageListErrorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? messageListLoadingBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? messageListBackgroundBuilder;

  final void Function(BuildContext context, List<PlatformFile> files, Function defaultAction)? onMediaFilesPicked;

  // theme
  final ThemeData? theme;

  final Widget? sendButtonWidget;

  final Widget? pickMediaButtonWidget;

  final Widget? pickFileButtonWidget;

  final FocusNode? inputFocusNode;

  final BoxDecoration? inputBackgroundDecoration;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme ?? Theme.of(context),
      child: Scaffold(
        appBar: appBarBuilder != null ? appBarBuilder!.call(context, buildAppBar(context)) : buildAppBar(context),
        body: Column(
          children: [
            ZIMWrapperMessageListView(
              key: ValueKey('ZIMWrapperMessageListView:${Object.hash(
                conversationID,
                conversationType,
              )}'),
              conversationID: conversationID,
              conversationType: conversationType,
              onPressed: onMessageItemPressd,
              itemBuilder: messageItemBuilder,
              onLongPress: onMessageItemLongPress,
              loadingBuilder: messageListLoadingBuilder,
              errorBuilder: messageListErrorBuilder,
              scrollController: messageListScrollController,
              theme: theme,
              backgroundBuilder: messageListBackgroundBuilder,
            ),
            ZIMWrapperMessageInput(
              key: ValueKey('ZIMWrapperMessageInput:${Object.hash(
                conversationID,
                conversationType,
              )}'),
              conversationID: conversationID,
              conversationType: conversationType,
              actions: messageInputActions,
              onMessageSent: onMessageSent,
              preMessageSending: preMessageSending,
              inputDecoration: inputDecoration,
              showPickFileButton: showPickFileButton,
              showPickMediaButton: showPickMediaButton,
              editingController: editingController,
              theme: theme,
              onMediaFilesPicked: onMediaFilesPicked,
              sendButtonWidget: sendButtonWidget,
              pickMediaButtonWidget: pickMediaButtonWidget,
              pickFileButtonWidget: pickFileButtonWidget,
              inputFocusNode: inputFocusNode,
              inputBackgroundDecoration: inputBackgroundDecoration,
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: ValueListenableBuilder(
        valueListenable: ZIMWrapper().getConversation(conversationID, conversationType),
        builder: (context, ZIMWrapperConversation conversation, child) {
          return Row(
            children: [
              CircleAvatar(child: conversation.icon),
              child!,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.name, style: const TextStyle(fontSize: 16), overflow: TextOverflow.clip),
                  // Text(conversation.id,
                  //     style: const TextStyle(fontSize: 12),
                  //     overflow: TextOverflow.clip)
                ],
              )
            ],
          );
        },
        child: const SizedBox(width: 20 * 0.75),
      ),
      actions: appBarActions,
    );
  }
}
