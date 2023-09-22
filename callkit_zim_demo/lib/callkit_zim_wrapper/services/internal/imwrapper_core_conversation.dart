part of 'imwrapper_core.dart';

extension ZIMWrapperCoreConversation on ZIMWrapperCore {
  Future<ZIMWrapperConversationListNotifier> getConversationListNotifier() async {
    await waitForLoginOrNot();
    if (db.conversations.inited) return db.conversations.notifier;

    final config = ZIMConversationQueryConfig()..count = kdefaultLoadCount;
    return ZIM.getInstance()!.queryConversationList(config).then((zimResult) {
      ZIMWrapperLogger.info('queryHistoryMessage: ${zimResult.conversationList.length}');
      db.conversations.init(zimResult.conversationList);
      if (zimResult.conversationList.isEmpty || zimResult.conversationList.length < config.count) {
        db.conversations.noMore = true;
      }
      db.conversations.loading = false;
      return db.conversations.notifier;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        db.conversations.loading = false;
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry loadConversationList');
          return getConversationListNotifier();
        } else {
          ZIMWrapperLogger.severe('loadConversationList faild', error);
          throw error;
        }
      });
    });
  }

  ValueNotifier<int> getTotalUnreadMessageCount() {
    return totalUnreadMessageCount;
  }

  Future<int> loadMoreConversation() async {
    await waitForLoginOrNot();
    if (db.conversations.noMore || db.conversations.loading) return 0;
    if (db.conversations.notInited) await getConversationListNotifier();
    if (db.conversations.isEmpty) return 0;
    ZIMWrapperLogger.info('loadMoreConversation start');

    db.conversations.loading = true;
    // start loading
    final config = ZIMConversationQueryConfig()
      ..count = kdefaultLoadCount
      ..nextConversation = db.conversations.notifier.value.last.value.tozim();
    return ZIM.getInstance()!.queryConversationList(config).then((zimResult) {
      db.conversations.addAll(zimResult.conversationList);
      db.conversations.loading = false;
      if (zimResult.conversationList.isEmpty || zimResult.conversationList.length < config.count) {
        db.conversations.noMore = true;
      }
      db.conversations.loading = false;
      return zimResult.conversationList.length;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        db.conversations.loading = false;
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry loadConversationList');
          return loadMoreConversation();
        } else {
          ZIMWrapperLogger.severe('loadConversationList faild', error);
          throw error;
        }
      });
    });
  }

  Future<void> deleteConversation(
    String id,
    ZIMConversationType type, {
    bool isAlsoDeleteMessages = false,
  }) async {
    if (currentUser == null) return;
    db.conversations.delete(id, type);

    if (isAlsoDeleteMessages) {
      db.messages(id, type).clear();
      final config = ZIMMessageDeleteConfig()..isAlsoDeleteServerMessage = true;
      await ZIM.getInstance()!.deleteAllMessage(id, type, config);
    }

    final deleteConfig = ZIMConversationDeleteConfig()..isAlsoDeleteServerConversation = true;
    await ZIM.getInstance()!.deleteConversation(id, type, deleteConfig);
  }

  void clearUnreadCount(String conversationID, ZIMConversationType conversationType) {
    final conversation = db.conversations.get(conversationID, conversationType);

    try {
      if (conversation.value.unreadMessageCount > 0) {
        ZIM.getInstance()!.clearConversationUnreadMessageCount(conversationID, conversationType);
      }
    } catch (e) {
      ZIMWrapperLogger.severe('clearUnreadCount: $e');
    }
  }
}

extension ZIMWrapperCoreConversationEvent on ZIMWrapperCore {
  void onConversationChanged(ZIM zim, List<ZIMConversationChangeInfo> conversationChangeInfoList) {
    for (final changeInfo in conversationChangeInfoList) {
      switch (changeInfo.event) {
        case ZIMConversationEvent.added:
          db.conversations.insert(changeInfo.conversation!.tokit());
          break;
        case ZIMConversationEvent.updated:
          db.conversations.update(changeInfo.conversation!.tokit());
          break;
        case ZIMConversationEvent.disabled:
          db.conversations.disable(changeInfo.conversation!.tokit());
          break;
      }
    }
  }

  void onConversationTotalUnreadMessageCountUpdated(ZIM zim, int totalUnreadMessageCount) {
    this.totalUnreadMessageCount.value = totalUnreadMessageCount;
    ZIMWrapperLogger.info('onConversationTotalUnreadMessageCountUpdated: '
        '$totalUnreadMessageCount');
  }
}
