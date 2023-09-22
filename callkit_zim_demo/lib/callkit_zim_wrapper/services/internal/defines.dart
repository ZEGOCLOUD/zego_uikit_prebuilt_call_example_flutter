import 'package:flutter/foundation.dart';

import '../../callkit_zim_wrapper.dart';

class ZIMWrapperDB {
  ZIMWrapperConversationList conversations = ZIMWrapperConversationList();
  ZIMWrapperMessageList messages(String id, ZIMConversationType type) {
    _messageList[type] ??= {};
    _messageList[type]![id] ??= ZIMWrapperMessageList();
    return _messageList[type]![id]!;
  }

  final Map<ZIMConversationType, Map<String, ZIMWrapperMessageList>> _messageList = {};

  void clear() {
    conversations.clear();
    _messageList.forEach((type, map) => map.forEach((id, list) => list.clear()));
  }
}

class ZIMWrapperConversationList {
  bool inited = false;
  bool get notInited => !inited;

  bool hasMore = true;
  bool get noMore => !hasMore;
  set noMore(bool noMore) => hasMore = !noMore;

  bool loading = false;

  ListNotifier<ValueNotifier<ZIMWrapperConversation>> notifier = ListNotifier([]);

  void init(List<ZIMConversation> zimConversationList) {
    notifier.value = zimConversationList.map((e) => ValueNotifier(e.tokit())).toList();
    inited = true;
  }

  bool get isEmpty => notifier.isEmpty;
  bool get isNotEmpty => notifier.isNotEmpty;

  void clear() {
    notifier.clear();
    inited = false;
    hasMore = true;
  }

  ValueNotifier<ZIMWrapperConversation> get(String id, ZIMConversationType type) {
    ValueNotifier<ZIMWrapperConversation>? ret;
    for (var i = 0; i < notifier.length; i++) {
      if (notifier[i].value.equal(id, type)) {
        ret = notifier[i];
        break;
      }
    }

    if (ret == null) {
      final zimConversation = ZIMConversation()
        ..id = id
        ..type = type;
      // so here do not notify ui, will notify later
      notifier.insert(0, ValueNotifier(zimConversation.tokit()), notify: false);
      ret = get(id, type);
      if (type == ZIMConversationType.peer) {
        ZIMWrapper().queryUser(id).then((ZIMUserFullInfo zimResult) {
          final newConversation = ret!.value.clone()
            ..name = zimResult.baseInfo.userName
            ..avatarUrl = zimResult.userAvatarUrl;
          ret.value = newConversation;
        });
      } else if (type == ZIMConversationType.group) {
        ZIMWrapperCore.instance.queryGroup(id).then((ZIMGroupFullInfo? zimResult) {
          if (zimResult != null) {
            ret!.value = ret.value.clone()
              ..name = zimResult.name
              ..avatarUrl = zimResult.url
              ..notificationStatus = ZIMConversationNotificationStatus.values[zimResult.notificationStatus.index];
          } else {
            notifier.triggerNotify();
          }
        });
      }
    }

    return ret;
  }

  void addAll(List<ZIMConversation> zimConversationList) {
    notifier.addAll(zimConversationList.map((e) => ValueNotifier(e.tokit())).toList());
  }

  void delete(String id, ZIMConversationType type) {
    notifier.removeWhere((element) {
      if (element.value.equal(id, type)) {
        return true;
      } else {
        return false;
      }
    });
  }

  void insert(ZIMWrapperConversation wrapperConversation) {
    notifier.value.removeWhere((element) => element.value.equal(wrapperConversation.id, wrapperConversation.type));
    notifier.insert(0, ValueNotifier(wrapperConversation));
  }

  void update(ZIMWrapperConversation wrapperConversation) {
    final index =
        notifier.value.indexWhere((element) => element.value.equal(wrapperConversation.id, wrapperConversation.type));
    if (index != -1) {
      notifier.value.removeAt(index);
      notifier.insert(0, ValueNotifier(wrapperConversation));
      sort();
    }
  }

  void disable(ZIMWrapperConversation wrapperConversation) {
    for (var i = 0; i < notifier.length; i++) {
      if (notifier[i].value.equal(wrapperConversation.id, wrapperConversation.type)) {
        notifier[i].value = (notifier[i].value.clone()..disable = true);
        break;
      }
    }
    sort();
  }

  void remove(String id, ZIMConversationType type) {
    notifier.removeWhere((element) => element.value.equal(id, type));
  }

  void sort() {
    notifier.sort((a, b) {
      return b.value.orderKey.compareTo(a.value.orderKey);
    });
  }
}

class ZIMWrapperMessageList {
  ListNotifier<ValueNotifier<ZIMWrapperMessage>> notifier = ListNotifier([]);
  bool inited = false;
  bool get notInited => !inited;

  bool hasMore = true;
  bool get noMore => !hasMore;
  set noMore(bool noMore) => hasMore = !noMore;

  bool loading = false;

  void init(List<ZIMMessage> messageList) {
    notifier.value = messageList.map((e) => ValueNotifier(e.tokit())).toList();
    inited = true;
  }

  bool isEmpty() => notifier.isEmpty;
  bool isNotEmpty() => notifier.isNotEmpty;

  void clear() {
    notifier.clear();
    inited = false;
    hasMore = true;
  }

  void receive(List<ZIMMessage> receiveMessages) {
    notifier.addAll(receiveMessages.reversed.map((e) => ValueNotifier(e.tokit())));
  }

  void insertAll(List<ZIMMessage> receiveMessages) {
    notifier.insertAll(0, receiveMessages.map((e) => ValueNotifier(e.tokit())));
  }

  void delete(List<ZIMWrapperMessage> deleteMessages) {
    for (final message in deleteMessages) {
      notifier.removeWhere((element) {
        return element.value.info.localMessageID == message.info.localMessageID;
      }, notify: false);
    }
    notifier.triggerNotify();
  }

  ZIMWrapperMessageNotifier onAttach(ZIMMessage zimMessage) {
    final wrapperMessage = ValueNotifier(zimMessage.tokit());
    notifier.add(wrapperMessage);
    return wrapperMessage;
  }

  void onSendSuccess(int localMessageID) {
    for (final wrapperMessage in notifier.value) {
      if (wrapperMessage.value.info.localMessageID == localMessageID) {
        wrapperMessage.value = (wrapperMessage.value.clone()..info.sentStatus = ZIMMessageSentStatus.success);
        break;
      }
    }
  }

  void onSendFaild(int localMessageID) {
    for (final wrapperMessage in notifier.value) {
      if (wrapperMessage.value.info.localMessageID == localMessageID) {
        wrapperMessage.value = (wrapperMessage.value.clone()..info.sentStatus = ZIMMessageSentStatus.failed);
        break;
      }
    }
  }
}

extension ZIMWrapperMessageExtension on ZIMWrapperMessage {
  void sendFaild() => info.sentStatus = ZIMMessageSentStatus.failed;
  void sendSuccess() => info.sentStatus = ZIMMessageSentStatus.success;
  void updateExtraInfo(Map extraInfo) {
    this.extraInfo = (Map.from(this.extraInfo)..addAll(extraInfo));
  }

  void downloadDone(ZIMMediaFileType downloadType, ZIMMessage zimMessage) {
    switch (downloadType) {
      case ZIMMediaFileType.originalFile:
        autoContent!.fileLocalPath = (zimMessage as ZIMMediaMessage).fileLocalPath;
        break;
      case ZIMMediaFileType.largeImage:
        autoContent!.fileLocalPath = (zimMessage as ZIMImageMessage).largeImageLocalPath;
        break;
      case ZIMMediaFileType.thumbnail:
        autoContent!.fileLocalPath = (zimMessage as ZIMImageMessage).thumbnailLocalPath;
        break;
      case ZIMMediaFileType.videoFirstFrame:
        autoContent!.videoFirstFrameLocalPath = (zimMessage as ZIMVideoMessage).videoFirstFrameLocalPath;
        break;
    }
  }

  dynamic get autoContent {
    switch (type) {
      case ZIMMessageType.image:
        return imageContent;
      case ZIMMessageType.file:
        return fileContent;
      case ZIMMessageType.audio:
        return audioContent;
      case ZIMMessageType.video:
        return videoContent;
      case ZIMMessageType.system:
        return systemContent;
      case ZIMMessageType.text:
        return textContent;
      default:
        throw Exception('not support type');
    }
  }
}
