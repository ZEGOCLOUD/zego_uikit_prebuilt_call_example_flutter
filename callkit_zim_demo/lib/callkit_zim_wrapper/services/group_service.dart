part of 'services.dart';

mixin ZIMWrapperGroupService {
  // return the new group's conversationID
  // If you specify an ID, the group will be created using the ID you specified.
  Future<String?> createGroup(String name, List<String> inviteUserIDs, {String id = ''}) async {
    return ZIMWrapperCore.instance.createGroup(name, inviteUserIDs, id: id);
  }

  // Return error code. 0 means success.
  Future<int> joinGroup(String conversationID) async {
    return ZIMWrapperCore.instance.joinGroup(conversationID);
  }

  // Return error code. 0 means success.
  Future<int> addUersToGroup(String conversationID, List<String> userIDs) async {
    return ZIMWrapperCore.instance.addUersToGroup(conversationID, userIDs);
  }

  Future<int> removeUesrsFromGroup(String conversationID, List<String> userIDs) async {
    return ZIMWrapperCore.instance.removeUesrsFromGroup(conversationID, userIDs);
  }

  // Return error code. 0 means success.
  Future<int> leaveGroup(String conversationID) async {
    return ZIMWrapperCore.instance.leaveGroup(conversationID);
  }

  // Return error code. 0 means success.
  Future<int> disbandGroup(String conversationID) async {
    return ZIMWrapperCore.instance.disbandGroup(conversationID);
  }

  // Return error code. 0 means success.
  Future<int> transferGroupOwner(String conversationID, String toUserID) async {
    return ZIMWrapperCore.instance.transferGroupOwner(conversationID, toUserID);
  }

  Future<ZIMGroupMemberInfo?> queryGroupMemberInfo(String conversationID, String userID) async {
    return ZIMWrapperCore.instance.queryGroupMemberInfo(conversationID, userID);
  }

  ListNotifier<ZIMGroupMemberInfo> queryGroupMemberList(String conversationID) {
    return ZIMWrapperCore.instance.queryGroupMemberList(conversationID);
  }

  Future<int?> queryGroupMemberCount(String conversationID) {
    return ZIMWrapperCore.instance.queryGroupMemberCount(conversationID);
  }
}
