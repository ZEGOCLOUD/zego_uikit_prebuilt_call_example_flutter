import 'dart:async';

import 'package:flutter/material.dart';

import '../callkit_zim_wrapper.dart';
import 'messages/widgets/pick_file_button.dart';
import 'messages/widgets/pick_media_button.dart';

class ZIMWrapperMessageInput extends StatefulWidget {
  const ZIMWrapperMessageInput({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.onMessageSent,
    this.preMessageSending,
    this.editingController,
    this.showPickFileButton = true,
    this.showPickMediaButton = true,
    this.actions = const [],
    this.inputDecoration,
    this.theme,
    this.onMediaFilesPicked,
    this.sendButtonWidget,
    this.pickMediaButtonWidget,
    this.pickFileButtonWidget,
    this.inputFocusNode,
    this.inputBackgroundDecoration,
  }) : super(key: key);

  /// The conversationID of the conversation to send message.
  final String conversationID;

  /// The conversationType of the conversation to send message.
  final ZIMConversationType conversationType;

  /// By default, [ZIMWrapperMessageInput] will show a button to pick file.
  /// If you don't want to show this button, set [showPickFileButton] to false.
  final bool showPickFileButton;

  /// By default, [ZIMWrapperMessageInput] will show a button to pick media.
  /// If you don't want to show this button, set [showPickMediaButton] to false.
  final bool showPickMediaButton;

  /// To add your own action, use the [actions] parameter like this:
  ///
  /// use [actions] like this to add your custom actions:
  ///
  /// actions: [
  ///   ZIMWrapperMessageInputAction.left(IconButton(
  ///     icon: Icon(
  ///       Icons.mic,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMWrapperMessageInputAction.leftInside(IconButton(
  ///     icon: Icon(
  ///       Icons.sentiment_satisfied_alt_outlined,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMWrapperMessageInputAction.rightInside(IconButton(
  ///     icon: Icon(
  ///       Icons.cabin,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMWrapperMessageInputAction.right(IconButton(
  ///     icon: Icon(
  ///       Icons.sd,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  /// ],
  final List<ZIMWrapperMessageInputAction>? actions;

  /// Called when a message is sent.
  final void Function(ZIMWrapperMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMWrapperMessage> Function(ZIMWrapperMessage)? preMessageSending;

  final void Function(BuildContext context, List<PlatformFile> files, Function defaultAction)? onMediaFilesPicked;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use. if not provided, a default one will be created.
  final TextEditingController? editingController;

  // theme
  final ThemeData? theme;

  final Widget? sendButtonWidget;

  final Widget? pickMediaButtonWidget;

  final Widget? pickFileButtonWidget;

  final FocusNode? inputFocusNode;

  final BoxDecoration? inputBackgroundDecoration;

  @override
  State<ZIMWrapperMessageInput> createState() => _ZIMWrapperMessageInputState();
}

class _ZIMWrapperMessageInputState extends State<ZIMWrapperMessageInput> {
  final TextEditingController _defaultEditingController = TextEditingController();
  TextEditingController get _editingController => widget.editingController ?? _defaultEditingController;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 32,
              color: Theme.of(context).primaryColor.withOpacity(0.15),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              ...buildActions(ZIMWrapperMessageInputActionLocation.left),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: widget.inputBackgroundDecoration ??
                      BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(40),
                      ),
                  child: Row(
                    children: [
                      ...buildActions(ZIMWrapperMessageInputActionLocation.leftInside),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          focusNode: widget.inputFocusNode,
                          onSubmitted: (value) => sendTextMessage(),
                          controller: _editingController,
                          decoration: widget.inputDecoration ?? const InputDecoration(hintText: 'Type message'),
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _editingController,
                        builder: (context, textEditingValue, child) {
                          return Builder(
                            builder: (context) {
                              if (textEditingValue.text.isNotEmpty || rightInsideActionsIsEmpty) {
                                return Container(
                                  height: 32,
                                  width: 32,
                                  decoration: widget.sendButtonWidget == null
                                      ? BoxDecoration(
                                          color: textEditingValue.text.isNotEmpty
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).primaryColor.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        )
                                      : null,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: widget.sendButtonWidget ??
                                        const Icon(Icons.send, size: 16, color: Colors.white),
                                    onPressed: textEditingValue.text.isNotEmpty ? sendTextMessage : null,
                                  ),
                                );
                              } else {
                                return Row(
                                  children: [
                                    if (widget.showPickMediaButton)
                                      ZIMWrapperPickMediaButton(
                                        icon: widget.pickMediaButtonWidget,
                                        onFilePicked: (List<PlatformFile> files) {
                                          void defaultAction() {
                                            ZIMWrapper().sendMediaMessage(
                                              widget.conversationID,
                                              widget.conversationType,
                                              files,
                                              onMessageSent: widget.onMessageSent,
                                              preMessageSending: widget.preMessageSending,
                                            );
                                          }

                                          if (widget.onMediaFilesPicked != null) {
                                            widget.onMediaFilesPicked!(context, files, defaultAction);
                                          } else {
                                            defaultAction();
                                          }
                                        },
                                      ),
                                    if (widget.showPickFileButton)
                                      ZIMWrapperPickFileButton(
                                        icon: widget.pickFileButtonWidget,
                                        onFilePicked: (List<PlatformFile> files) {
                                          void defaultAction() {
                                            ZIMWrapper().sendFileMessage(
                                              widget.conversationID,
                                              widget.conversationType,
                                              files,
                                              onMessageSent: widget.onMessageSent,
                                              preMessageSending: widget.preMessageSending,
                                            );
                                          }

                                          if (widget.onMediaFilesPicked != null) {
                                            widget.onMediaFilesPicked!(context, files, defaultAction);
                                          } else {
                                            defaultAction();
                                          }
                                        },
                                      ),
                                    ...buildActions(ZIMWrapperMessageInputActionLocation.rightInside),
                                  ],
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ...buildActions(ZIMWrapperMessageInputActionLocation.right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendTextMessage() async {
    ZIMWrapper().sendTextMessage(
      widget.conversationID,
      widget.conversationType,
      _editingController.text,
      onMessageSent: widget.onMessageSent,
      preMessageSending: widget.preMessageSending,
    );
    _editingController.clear();
  }

  List<Widget> buildActions(ZIMWrapperMessageInputActionLocation location) {
    return widget.actions?.where((element) => element.location == location).map((e) => e.child).toList() ?? [];
  }

  bool get rightInsideActionsIsEmpty =>
      (widget.actions
              ?.where((element) => element.location == ZIMWrapperMessageInputActionLocation.rightInside)
              .isEmpty ??
          true) &&
      !widget.showPickFileButton &&
      !widget.showPickMediaButton;
}

enum ZIMWrapperMessageInputActionLocation { left, right, leftInside, rightInside }

class ZIMWrapperMessageInputAction {
  const ZIMWrapperMessageInputAction(this.child, [this.location = ZIMWrapperMessageInputActionLocation.rightInside]);
  const ZIMWrapperMessageInputAction.left(Widget child) : this(child, ZIMWrapperMessageInputActionLocation.left);
  const ZIMWrapperMessageInputAction.right(Widget child) : this(child, ZIMWrapperMessageInputActionLocation.right);
  const ZIMWrapperMessageInputAction.leftInside(Widget child)
      : this(child, ZIMWrapperMessageInputActionLocation.leftInside);
  const ZIMWrapperMessageInputAction.rightInside(Widget child)
      : this(child, ZIMWrapperMessageInputActionLocation.rightInside);

  final Widget child;
  final ZIMWrapperMessageInputActionLocation location;
}
