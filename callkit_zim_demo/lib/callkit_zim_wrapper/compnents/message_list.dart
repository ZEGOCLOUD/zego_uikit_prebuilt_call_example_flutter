import 'dart:async';

import 'package:flutter/material.dart';

import '../callkit_zim_wrapper.dart';

// featureList
class ZIMWrapperMessageListView extends StatefulWidget {
  const ZIMWrapperMessageListView({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.onPressed,
    this.itemBuilder,
    this.backgroundBuilder,
    this.loadingBuilder,
    this.onLongPress,
    this.errorBuilder,
    this.scrollController,
    this.theme,
  }) : super(key: key);

  final String conversationID;
  final ZIMConversationType conversationType;

  final ScrollController? scrollController;

  final void Function(BuildContext context, ZIMWrapperMessage message, Function defaultAction)? onPressed;
  final void Function(
          BuildContext context, LongPressStartDetails details, ZIMWrapperMessage message, Function defaultAction)?
      onLongPress;
  final Widget Function(BuildContext context, ZIMWrapperMessage message, Widget defaultWidget)? itemBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? errorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? loadingBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? backgroundBuilder;

  // theme
  final ThemeData? theme;

  @override
  State<ZIMWrapperMessageListView> createState() => _ZIMWrapperMessageListViewState();
}

class _ZIMWrapperMessageListViewState extends State<ZIMWrapperMessageListView> {
  final ScrollController _defaultScrollController = ScrollController();
  ScrollController get _scrollController => widget.scrollController ?? _defaultScrollController;

  Completer? _loadMoreCompleter;
  @override
  void initState() {
    ZIMWrapper().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    ZIMWrapper().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }

  Future<void> scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >= 0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 == await ZIMWrapper().loadMoreMessage(widget.conversationID, widget.conversationType)) {
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
      child: Expanded(
        child: FutureBuilder(
          future: ZIMWrapper().getMessageListNotifier(widget.conversationID, widget.conversationType),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ValueListenableBuilder(
                valueListenable: snapshot.data!,
                builder: (BuildContext context, List<ValueNotifier<ZIMWrapperMessage>> messageList, Widget? child) {
                  ZIMWrapper().clearUnreadCount(widget.conversationID, widget.conversationType);
                  return LayoutBuilder(builder: (context, BoxConstraints constraints) {
                    return Stack(
                      children: [
                        SizedBox(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          child: widget.backgroundBuilder?.call(context, const SizedBox.shrink()) ??
                              const SizedBox.shrink(),
                        ),
                        ListView.builder(
                          cacheExtent: constraints.maxHeight * 3,
                          reverse: true,
                          controller: _scrollController,
                          itemCount: messageList.length,
                          itemBuilder: (context, index) {
                            final reversedIndex = messageList.length - index - 1;
                            final message = messageList[reversedIndex];

                            return ValueListenableBuilder(
                              valueListenable: message,
                              builder: (BuildContext context, ZIMWrapperMessage msg, Widget? child) {
                                // defaultWidget
                                final Widget defaultWidget = ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth,
                                    maxHeight: msg.type == ZIMMessageType.text
                                        ? double.maxFinite
                                        : constraints.maxHeight * 0.5,
                                  ),
                                  child: ZIMWrapperMessageWidget(
                                    key: ValueKey(msg.hashCode),
                                    message: msg,
                                    onPressed: widget.onPressed,
                                    onLongPress: widget.onLongPress,
                                  ),
                                );
                                // customWidget
                                return widget.itemBuilder?.call(context, msg, defaultWidget) ?? defaultWidget;
                              },
                            );
                          },
                        ),
                      ],
                    );
                  });
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
                    Text(snapshot.error.toString()),
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
      ),
    );
  }
}
