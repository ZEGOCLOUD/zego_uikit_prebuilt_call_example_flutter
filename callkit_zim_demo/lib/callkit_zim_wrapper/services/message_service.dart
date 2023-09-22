part of 'services.dart';

mixin ZIMWrapperMessageService {
  Future<ZIMWrapperMessageListNotifier> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) {
    return ZIMWrapperCore.instance.getMessageListNotifier(conversationID, conversationType);
  }

  Future<int> loadMoreMessage(String conversationID, ZIMConversationType conversationType) async {
    return ZIMWrapperCore.instance.loadMoreMessage(conversationID, conversationType);
  }

  Future<void> sendTextMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String text, {
    FutureOr<ZIMWrapperMessage> Function(ZIMWrapperMessage)? preMessageSending,
    Function(ZIMWrapperMessage)? onMessageSent,
  }) async {
    return ZIMWrapperCore.instance.sendTextMessage(
      conversationID,
      conversationType,
      text,
      preMessageSending: preMessageSending,
      onMessageSent: onMessageSent,
    );
  }

  Future<void> sendFileMessage(
    String conversationID,
    ZIMConversationType conversationType,
    List<PlatformFile> files, {
    bool audoDetectType = true,
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMWrapperMessage> Function(ZIMWrapperMessage)? preMessageSending,
    Function(ZIMWrapperMessage)? onMessageSent,
  }) async {
    for (final file in files) {
      ZIMWrapperCore.instance.sendMediaMessage(
        conversationID,
        conversationType,
        file.path!,
        ZIMMessageType.file,
        preMessageSending: preMessageSending,
        onMessageSent: onMessageSent,
      );
    }
  }

  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    List<PlatformFile> files, {
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMWrapperMessage> Function(ZIMWrapperMessage)? preMessageSending,
    Function(ZIMWrapperMessage)? onMessageSent,
  }) async {
    ZIMWrapperLogger.info('sendMediaMessage: ${DateTime.now().millisecondsSinceEpoch}');
    for (final file in files) {
      await ZIMWrapperCore.instance.sendMediaMessage(
        conversationID,
        conversationType,
        file.path!,
        ZIMWrapper().getMessageTypeByFileExtension(file),
        preMessageSending: preMessageSending,
        onMessageSent: onMessageSent,
      );
    }
    return;
  }

  Future<void> deleteMessage(List<ZIMWrapperMessage> messages) async {
    return ZIMWrapperCore.instance.deleteMessage(messages);
  }

  Future<void> recallMessage(ZIMWrapperMessage message) async {
    return ZIMWrapperCore.instance.recallMessage(message);
  }

  void downloadMediaFile(ZIMWrapperMessage message) {
    return ZIMWrapperCore.instance.downloadMediaFile(message);
  }
}
