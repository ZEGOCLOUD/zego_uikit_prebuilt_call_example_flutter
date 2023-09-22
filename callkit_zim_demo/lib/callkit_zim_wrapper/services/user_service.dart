part of 'services.dart';

mixin ZIMWrapperUserService {
  Future<int> connectUser({
    required String id,
    String name = '',
    String avatarUrl = '',
  }) async {
    return ZIMWrapperCore.instance.connectUser(id: id, name: name, avatarUrl: avatarUrl);
  }

  Future<void> disconnectUser() async {
    return ZIMWrapperCore.instance.disconnectUser();
  }

  ZIMUserFullInfo? currentUser() {
    return ZIMWrapperCore.instance.currentUser;
  }

  Future<ZIMUserFullInfo> queryUser(String id) async {
    return ZIMWrapperCore.instance.queryUser(id);
  }

  Future<void> updateUserInfo({String name = '', String avatarUrl = ''}) async {
    return ZIMWrapperCore.instance.updateUserInfo(name: name, avatarUrl: avatarUrl);
  }

  Stream<ZegoSignalingPluginConnectionStateChangedEvent> getConnectionStateChangedEventStream() {
    return ZIMWrapperCore.instance.getConnectionStateChangedEventStream();
  }
}
