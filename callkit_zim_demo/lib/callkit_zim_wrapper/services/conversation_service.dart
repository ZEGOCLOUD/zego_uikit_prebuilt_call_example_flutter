part of 'services.dart';

mixin ZIMWrapperConversationService {
  Future<ZIMWrapperConversationListNotifier> getConversationListNotifier() {
    return ZIMWrapperCore.instance.getConversationListNotifier();
  }

  ValueNotifier<ZIMWrapperConversation> getConversation(String id, ZIMConversationType type) {
    return ZIMWrapperCore.instance.db.conversations.get(id, type);
  }

  ValueNotifier<int> getTotalUnreadMessageCount() {
    return ZIMWrapperCore.instance.totalUnreadMessageCount;
  }

  Future<void> deleteConversation(
    String id,
    ZIMConversationType type, {
    bool isAlsoDeleteMessages = false,
  }) async {
    await ZIMWrapperCore.instance.deleteConversation(id, type, isAlsoDeleteMessages: isAlsoDeleteMessages);
  }

  Future<void> clearUnreadCount(String conversationID, ZIMConversationType conversationType) async {
    ZIMWrapperCore.instance.clearUnreadCount(conversationID, conversationType);
  }

  Future<int> loadMoreConversation() async {
    return ZIMWrapperCore.instance.loadMoreConversation();
  }
}
