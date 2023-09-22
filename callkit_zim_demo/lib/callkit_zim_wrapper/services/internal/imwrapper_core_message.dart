part of 'imwrapper_core.dart';

extension ZIMWrapperCoreMessage on ZIMWrapperCore {
  Future<ZIMWrapperMessageListNotifier> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) async {
    await waitForLoginOrNot();
    final dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.inited) return dbMessages.notifier;

    // start load
    dbMessages.loading = true;
    final config = ZIMMessageQueryConfig()
      ..reverse = true
      ..count = kdefaultLoadCount;
    return ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZIMWrapperLogger.info('queryHistoryMessage: ${zimResult.messageList.length}');
      dbMessages.init(zimResult.messageList);
      autoDownloadMessage(dbMessages.notifier.value);
      if (zimResult.messageList.isEmpty || zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;
      return dbMessages.notifier;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        dbMessages.loading = false;
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry loadMessageList');
          return getMessageListNotifier(conversationID, conversationType);
        } else {
          ZIMWrapperLogger.severe('loadMessageList faild', error);
          throw error;
        }
      });
    });
  }

  Future<int> loadMoreMessage(String conversationID, ZIMConversationType conversationType) async {
    await waitForLoginOrNot();
    final dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.notInited) {
      await getMessageListNotifier(conversationID, conversationType);
    }
    if (dbMessages.noMore || dbMessages.loading) return 0;
    dbMessages.loading = true;
    ZIMWrapperLogger.info('loadMoreMessage start');

    final config = ZIMMessageQueryConfig()
      ..count = kdefaultLoadCount
      ..reverse = true
      ..nextMessage = dbMessages.notifier.value.first.value.zim;
    return ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZIMWrapperLogger.info('queryHistoryMessage: ${zimResult.messageList.length}');

      dbMessages.insertAll(zimResult.messageList);
      autoDownloadMessage(dbMessages.notifier.value);
      ZIMWrapperLogger.info('loadMoreMessage success, length ${zimResult.messageList.length}');
      if (zimResult.messageList.isEmpty || zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;
      return zimResult.messageList.length;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        dbMessages.loading = false;
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry loadMessageList');
          return loadMoreMessage(conversationID, conversationType);
        } else {
          ZIMWrapperLogger.severe('loadMessageList faild', error);
          throw error;
        }
      });
    });
  }

  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String mediaPath,
    ZIMMessageType messageType, {
    FutureOr<ZIMWrapperMessage> Function(ZIMWrapperMessage message)? preMessageSending,
    Function(ZIMWrapperMessage message)? onMessageSent,
  }) async {
    if (mediaPath.isEmpty || !File(mediaPath).existsSync()) {
      ZIMWrapperLogger.info("sendMediaMessage: mediaPath is empty or file doesn't exits");
      return;
    }
    // 1. create message
    var wrapperMessage = ZIMWrapperMessageUtils.mediaMessageFactory(mediaPath, messageType).tokit();
    wrapperMessage.zim.conversationID = conversationID;
    wrapperMessage.zim.conversationType = conversationType;

    // 2. preMessageSending
    wrapperMessage = (await preMessageSending?.call(wrapperMessage)) ?? wrapperMessage;

    // 3. re-generate zim
    // ignore: cascade_invocations
    wrapperMessage.reGenerateZIMMessage();

    final mediaMessagePath =
        // ignore: avoid_dynamic_calls
        wrapperMessage.autoContent.fileDownloadUrl.isNotEmpty
            // ignore: avoid_dynamic_calls
            ? wrapperMessage.autoContent.fileDownloadUrl
            : mediaPath;
    ZIMWrapperLogger.info('sendMediaMessage: $mediaMessagePath');

    // 3. call service
    late ZIMWrapperMessageNotifier wrapperMessageNotifier;
    await ZIM
        .getInstance()!
        .sendMediaMessage(
          wrapperMessage.zim as ZIMMediaMessage,
          conversationID,
          conversationType,
          ZIMMessageSendConfig(),
          ZIMMediaMessageSendNotification(
            onMessageAttached: (zimMessage) {
              ZIMWrapperLogger.info('sendMediaMessage.onMessageAttached: '
                  '${(zimMessage as ZIMMediaMessage).fileName}');
              wrapperMessageNotifier = db.messages(conversationID, conversationType).onAttach(zimMessage);
            },
            onMediaUploadingProgress: (message, currentFileSize, totalFileSize) {
              final zimMessage = message as ZIMMediaMessage;
              ZIMWrapperLogger.info(
                  'onMediaUploadingProgress: ${zimMessage.fileName}, $currentFileSize/$totalFileSize');

              wrapperMessageNotifier.value = (wrapperMessageNotifier.value.clone()
                ..updateExtraInfo({
                  'upload': {
                    ZIMMediaFileType.originalFile.name: {
                      'currentFileSize': currentFileSize,
                      'totalFileSize': totalFileSize,
                    }
                  }
                }));
            },
          ),
        )
        .then((result) {
      ZIMWrapperLogger.info('sendMediaMessage: success, $mediaPath}');
      wrapperMessageNotifier.value = result.message.tokit();
      onMessageSent?.call(wrapperMessageNotifier.value);
    }).catchError((error) {
      wrapperMessageNotifier.value = (wrapperMessageNotifier.value.clone()..sendFaild());
      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry sendMediaMessage');
          sendMediaMessage(conversationID, conversationType, mediaPath, messageType,
              preMessageSending: preMessageSending, onMessageSent: onMessageSent);
        } else {
          ZIMWrapperLogger.severe('sendMediaMessage: faild, $mediaPath, error:$error');
          throw error;
        }
      });
    });

    // 4. onMessageSent
    onMessageSent?.call(wrapperMessage);
  }

  Future<void> sendTextMessage(String conversationID, ZIMConversationType conversationType, String text,
      {FutureOr<ZIMWrapperMessage> Function(ZIMWrapperMessage message)? preMessageSending,
      Function(ZIMWrapperMessage message)? onMessageSent}) async {
    if (text.isEmpty) {
      ZIMWrapperLogger.info('sendTextMessage: message is empty');
      return;
    }
    // 1. create message
    var wrapperMessage = ZIMTextMessage(message: text).tokit();
    final sendConfig = ZIMMessageSendConfig();
    final pushConfig = ZIMPushConfig();
    sendConfig.pushConfig = pushConfig;

    // 2. preMessageSending
    wrapperMessage = (await preMessageSending?.call(wrapperMessage)) ?? wrapperMessage;
    ZIMWrapperLogger.info('sendTextMessage: $text');

    // 3. re-generate zim
    wrapperMessage.reGenerateZIMMessage();

    // 3. call service
    late ZIMWrapperMessageNotifier wrapperMessageNotifier;
    await ZIM.getInstance()!.sendMessage(
      wrapperMessage.zim,
      conversationID,
      conversationType,
      sendConfig,
      ZIMMessageSendNotification(
        onMessageAttached: (zimMessage) {
          wrapperMessageNotifier = db.messages(conversationID, conversationType).onAttach(zimMessage);
        },
      ),
    ).then((result) {
      ZIMWrapperLogger.info('sendTextMessage: success, $text');
      wrapperMessageNotifier.value = result.message.tokit();
      onMessageSent?.call(wrapperMessageNotifier.value);
    }).catchError((error) {
      wrapperMessageNotifier.value =
          (wrapperMessageNotifier.value.clone()..info.sentStatus = ZIMMessageSentStatus.failed);
      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry sendTextMessage');
          sendTextMessage(conversationID, conversationType, text,
              preMessageSending: preMessageSending, onMessageSent: onMessageSent);
        } else {
          ZIMWrapperLogger.severe('sendTextMessage: faild, $text,error:$error');
          onMessageSent?.call(wrapperMessageNotifier.value);
          throw error;
        }
      });
    });
  }

  Future<void> deleteMessage(List<ZIMWrapperMessage> messages) async {
    if (messages.isEmpty) return;

    final conversationType = messages.first.info.conversationType;
    final conversationID = messages.first.info.conversationID;
    final config = ZIMMessageDeleteConfig()..isAlsoDeleteServerMessage = true;
    final zimMessages = messages.map((e) => e.zim).toList();

    db.messages(conversationID, conversationType).delete(messages);

    await ZIM.getInstance()!.deleteMessages(zimMessages, conversationID, conversationType, config).then((result) {
      ZIMWrapperLogger.info('deleteMessage: success');
    }).catchError((error) {
      ZIMWrapperLogger.severe('deleteMessage: faild,error:$error');
      throw error;
    });
  }

  Future<void> recallMessage(ZIMWrapperMessage message) async {
    if (message.type == ZIMMessageType.revoke) return;
    final conversationType = message.info.conversationType;
    final conversationID = message.info.conversationID;
    final config = ZIMMessageRevokeConfig();
    final zimMessage = message.zim;

    ZIMWrapperLogger.info('recallMessage: id:${zimMessage.messageID}');
    await ZIM.getInstance()!.revokeMessage(zimMessage, config).then((result) {
      final index = db.messages(conversationID, conversationType).notifier.value.indexWhere((e) =>
          (e.value.info.messageID == message.info.messageID) ||
          (e.value.info.localMessageID == message.info.localMessageID));
      if (index == -1) {
        ZIMWrapperLogger.warning("recallMessage: can't find message");
      } else {
        db.messages(conversationID, conversationType).notifier.value[index].value = result.message.tokit();
        ZIMWrapperLogger.info('recallMessage: success');
      }
    }).catchError((error) {
      ZIMWrapperLogger.severe('recallMessage: faild,error:$error');
      throw error;
    });
  }

  void addMessage(String id, ZIMConversationType type, ZIMMessage message) {
    onReceiveMessage(id, type, [message]);
  }

  void downloadMediaFile(ZIMWrapperMessage wrapperMessage) {
    final wrapperMessageNotifier = db
        .messages(
          wrapperMessage.info.conversationID,
          wrapperMessage.info.conversationType,
        )
        .notifier
        .value
        .firstWhere((element) => element.value.info.localMessageID == wrapperMessage.info.localMessageID);
    _downloadMediaFile(wrapperMessageNotifier);
  }

  void _downloadMediaFile(ZIMWrapperMessageNotifier wrapperMessageNotifier) {
    if (wrapperMessageNotifier.value.zim is! ZIMMediaMessage) {
      ZIMWrapperLogger.severe('downloadMediaFile: ${wrapperMessageNotifier.value.zim.runtimeType} '
          'is not ZIMMediaMessage');
      return;
    }

    if (wrapperMessageNotifier.value.isNetworkUrl) {
      ZIMWrapperLogger.severe('downloadMediaFile: ${wrapperMessageNotifier.value.zim.runtimeType} '
          'is network url.');
      return;
    }

    final downloadTypes = <ZIMMediaFileType>[];

    switch (wrapperMessageNotifier.value.zim.runtimeType) {
      case ZIMVideoMessage:
        if ((wrapperMessageNotifier.value.zim as ZIMVideoMessage).videoFirstFrameLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.videoFirstFrame);
        }
        if ((wrapperMessageNotifier.value.zim as ZIMMediaMessage).fileLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMImageMessage:
        // just use flutter cache manager
        break;
      case ZIMAudioMessage:
        if ((wrapperMessageNotifier.value.zim as ZIMMediaMessage).fileLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMFileMessage:
        if ((wrapperMessageNotifier.value.zim as ZIMMediaMessage).fileLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;

      default:
        ZIMWrapperLogger.severe('not support download ${wrapperMessageNotifier.value.zim.runtimeType}');
        return;
    }

    for (final downloadType in downloadTypes) {
      final zimMediaMessage = wrapperMessageNotifier.value.zim as ZIMMediaMessage;
      ZIMWrapperLogger.info('downloadMediaFile: ${zimMediaMessage.fileName} - '
          '${downloadType.name} start');
      ZIM.getInstance()!.downloadMediaFile(wrapperMessageNotifier.value.zim as ZIMMediaMessage, downloadType,
          (ZIMMessage zimMessage, int currentFileSize, int totalFileSize) {
        ZIMWrapperLogger.info('downloadMediaFile: ${zimMediaMessage.fileName} - '
            '${downloadType.name} $currentFileSize/$totalFileSize');

        wrapperMessageNotifier.value = (wrapperMessageNotifier.value.clone()
          ..updateExtraInfo({
            'download': {
              downloadType.name: {
                'currentFileSize': currentFileSize,
                'totalFileSize': totalFileSize,
              }
            }
          }));
      }).then((ZIMMediaDownloadedResult result) {
        ZIMWrapperLogger.info('downloadMediaFile: ${zimMediaMessage.fileName} - '
            '${downloadType.name} success');
        wrapperMessageNotifier.value =
            (wrapperMessageNotifier.value.clone()..downloadDone(downloadType, result.message));
      });
    }
  }
}

extension ZIMWrapperCoreMessageEvent on ZIMWrapperCore {
  void onReceivePeerMessage(ZIM zim, List<ZIMMessage> messageList, String fromUserID) =>
      onReceiveMessage(fromUserID, ZIMConversationType.peer, messageList);

  void onReceiveRoomMessage(ZIM zim, List<ZIMMessage> messageList, String fromRoomID) =>
      onReceiveMessage(fromRoomID, ZIMConversationType.group, messageList);

  void onReceiveGroupMessage(ZIM zim, List<ZIMMessage> messageList, String fromGroupID) =>
      onReceiveMessage(fromGroupID, ZIMConversationType.group, messageList);

  void onMessageRevokeReceived(ZIM zim, List<ZIMRevokeMessage> messageList) => onMessageRecalled(messageList);

  Future<void> onReceiveMessage(String id, ZIMConversationType type, List<ZIMMessage> receiveMessages) async {
    ZIMWrapperLogger.info('onReceiveMessage: $id, $type, ${receiveMessages.length}');

    if (db.conversations.notInited) {
      await getConversationListNotifier();
    }

    if (db.messages(id, type).notInited) {
      ZIMWrapperLogger.info('onReceiveMessage: notInited, loadMessageList first');
      await getMessageListNotifier(id, type);
    } else {
      db.messages(id, type).receive(receiveMessages);
    }

    db.conversations.sort();

    autoDownloadMessage(db.messages(id, type).notifier.value);
  }

  Future<void> onMessageRecalled(List<ZIMRevokeMessage> recalledMessageList) async {
    ZIMWrapperLogger.info('onMessageRecalled:  ${recalledMessageList.length}');
    for (final recalledMessage in recalledMessageList) {
      final conversationID = recalledMessage.conversationID;
      final conversationType = recalledMessage.conversationType;

      if (db.messages(conversationID, conversationType).notInited) {
        ZIMWrapperLogger.info('onMessageRecalled: notInited, loadMessageList first');
        await getMessageListNotifier(conversationID, conversationType);
      }

      final index = db.messages(conversationID, conversationType).notifier.value.indexWhere((e) =>
          (e.value.info.messageID == recalledMessage.messageID) ||
          (e.value.info.localMessageID == recalledMessage.localMessageID));
      if (index == -1) {
        ZIMWrapperLogger.warning("onMessageRecalled: can't find message");
      } else {
        db.messages(conversationID, conversationType).notifier.value[index].value = recalledMessage.tokit();
        ZIMWrapperLogger.info('recallMessage: success');
      }
    }
  }

  void autoDownloadMessage(List<ZIMWrapperMessageNotifier> wrapperMessages) {
    if (!kEnableAutoDownload) return;
    for (final wrapperMessage in wrapperMessages) {
      if (wrapperMessage.value.zim is ZIMMediaMessage) {
        _downloadMediaFile(wrapperMessage);
      }
    }
  }
}
