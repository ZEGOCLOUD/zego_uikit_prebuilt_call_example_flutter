import 'dart:async';

import 'package:flutter/material.dart';

import '../pages/message_list_page.dart';
import '../services/services.dart';
import 'conversation.dart';

export 'conversation_list.dart';

class ZIMWrapperConversationListView extends StatefulWidget {
  const ZIMWrapperConversationListView({
    Key? key,
    this.filter,
    this.sorter,
    this.onPressed,
    this.onLongPress,
    this.itemBuilder,
    this.lastMessageTimeBuilder,
    this.lastMessageBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.scrollController,
    this.theme,
  }) : super(key: key);

  // logic function
  final List<ZIMWrapperConversationNotifier> Function(BuildContext context, List<ZIMWrapperConversationNotifier>)?
      filter;
  final List<ZIMWrapperConversationNotifier> Function(BuildContext context, List<ZIMWrapperConversationNotifier>)?
      sorter;

  // item event
  final void Function(BuildContext context, ZIMWrapperConversation conversation, Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZIMWrapperConversation conversation, LongPressStartDetails longPressDetails,
      Function defaultAction)? onLongPress;

  // ui builder
  final Widget Function(BuildContext context, Widget defaultWidget)? errorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? emptyBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? loadingBuilder;

  // item ui builder
  final Widget Function(BuildContext context, DateTime? messageTime, Widget defaultWidget)? lastMessageTimeBuilder;
  final Widget Function(BuildContext context, ZIMWrapperMessage? message, Widget defaultWidget)? lastMessageBuilder;

  // item builder
  final Widget Function(BuildContext context, ZIMWrapperConversation conversation, Widget defaultWidget)? itemBuilder;

  // scroll controller
  final ScrollController? scrollController;

  // theme
  final ThemeData? theme;

  @override
  State<ZIMWrapperConversationListView> createState() => _ZIMWrapperConversationListViewState();
}

class _ZIMWrapperConversationListViewState extends State<ZIMWrapperConversationListView> {
  final ScrollController _defaultScrollController = ScrollController();
  ScrollController get _scrollController => widget.scrollController ?? _defaultScrollController;
  Completer? _loadMoreCompleter;
  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }

  Future<void> scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >= 0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 == await ZIMWrapper().loadMoreConversation()) {
          _scrollController.removeListener(scrollControllerListener);
        }
        _loadMoreCompleter!.complete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: FutureBuilder(
        future: ZIMWrapper().getConversationListNotifier(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ValueListenableBuilder(
              valueListenable: snapshot.data!,
              builder: (BuildContext context, List<ZIMWrapperConversationNotifier> conversationList, Widget? child) {
                if (conversationList.isEmpty) {
                  return widget.emptyBuilder?.call(context, const SizedBox.shrink()) ?? const SizedBox.shrink();
                }
                conversationList = widget.filter?.call(context, conversationList) ?? conversationList;
                conversationList = widget.sorter?.call(context, conversationList) ?? conversationList;
                return LayoutBuilder(
                  builder: (context, BoxConstraints constraints) {
                    return ListView.builder(
                      cacheExtent: constraints.maxHeight * 3,
                      controller: _scrollController,
                      itemCount: conversationList.length,
                      itemBuilder: (context, index) {
                        final conversation = conversationList[index];

                        return ValueListenableBuilder(
                          valueListenable: conversation,
                          builder: (BuildContext context, ZIMWrapperConversation conversation, Widget? child) {
                            // defaultWidget
                            final Widget defaultWidget = ZIMWrapperConversationWidget(
                              conversation: conversation,
                              lastMessageTimeBuilder: widget.lastMessageTimeBuilder,
                              lastMessageBuilder: widget.lastMessageBuilder,
                              onLongPress: (BuildContext context, LongPressStartDetails longPressDetails) {
                                void onLongPressDefaultAction() {
                                  _onLongPressDefaultAction(
                                    context,
                                    longPressDetails,
                                    conversation.id,
                                    conversation.type,
                                  );
                                }

                                if (widget.onLongPress != null) {
                                  widget.onLongPress!(
                                      context, conversation, longPressDetails, onLongPressDefaultAction);
                                } else {
                                  onLongPressDefaultAction();
                                }
                              },
                              onPressed: (BuildContext context) {
                                void onPressedDefaultAction() {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ZIMWrapperMessageListPage(
                                        conversationID: conversation.id,
                                        conversationType: conversation.type,
                                        theme: widget.theme,
                                      );
                                    },
                                  ));
                                }

                                if (widget.onPressed != null) {
                                  widget.onPressed!(context, conversation, onPressedDefaultAction);
                                } else {
                                  onPressedDefaultAction();
                                }
                              },
                            );

                            // customWidget
                            return widget.itemBuilder?.call(context, conversation, defaultWidget) ?? defaultWidget;
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            // defaultWidget
            final Widget defaultWidget = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  const Text('Load failed, please click to retry'),
                ],
              ),
            );

            // customWidget
            return GestureDetector(
              onTap: () => setState(() {}),
              child: widget.errorBuilder?.call(context, defaultWidget) ?? defaultWidget,
            );
          } else {
            // defaultWidget
            const Widget defaultWidget = Center(child: CircularProgressIndicator());

            // customWidget
            return widget.loadingBuilder?.call(context, defaultWidget) ?? defaultWidget;
          }
        },
      ),
    );
  }

  void _onLongPressDefaultAction(context, LongPressStartDetails longPressDetails, id, type) {
    final conversationBox = context.findRenderObject()! as RenderBox;
    final offset = conversationBox.localToGlobal(Offset(0, conversationBox.size.height / 2));
    final position = RelativeRect.fromLTRB(
      longPressDetails.globalPosition.dx,
      offset.dy,
      longPressDetails.globalPosition.dx,
      offset.dy,
    );

    showMenu(context: context, position: position, items: [
      const PopupMenuItem(value: 0, child: Text('Delete')),
      if (type == ZIMConversationType.group) const PopupMenuItem(value: 1, child: Text('Quit'))
    ]).then((value) {
      switch (value) {
        case 0:
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Do you want to delete this conversation?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ZIMWrapper().deleteConversation(id, type);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          break;
        case 1:
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Do you want to leave this group?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ZIMWrapper().leaveGroup(id);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          break;
      }
    });
  }
}
