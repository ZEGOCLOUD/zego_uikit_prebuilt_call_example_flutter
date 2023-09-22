part of 'imwrapper_core.dart';

extension ZIMWrapperCoreUser on ZIMWrapperCore {
  Future<int> connectUser({required String id, String name = '', String avatarUrl = ''}) async {
    if (!isInited) {
      ZIMWrapperLogger.info('is not inited.');
      throw Exception('ZIMWrapper is not inited.');
    }
    if (currentUser != null) {
      ZIMWrapperLogger.info('has login, auto logout');
      await disconnectUser();
    }

    ZIMWrapperLogger.info('login request, user id:$id, user name:$name');
    currentUser = ZIMUserFullInfo()
      ..baseInfo.userID = id
      ..baseInfo.userName = name.isNotEmpty ? name : id;

    ZIMWrapperLogger.info('ready to login..');
    final connectResult = await ZegoUIKitSignalingPlugin().connectUser(id: id, name: name);

    if (connectResult.error == null) {
      ZIMWrapperLogger.info('login success');

      await updateUserInfo(avatarUrl: avatarUrl);

      // query currentUser's full info
      queryUser(currentUser!.baseInfo.userID).then((ZIMUserFullInfo zimResult) {
        currentUser = zimResult;
        loginCompleter?.complete();
      });

      return 0;
    } else {
      ZIMWrapperLogger.info('login error, ${connectResult.error}');
      return int.parse(connectResult.error!.code);
    }
  }

  Future<void> disconnectUser() async {
    ZIMWrapperLogger.info('logout.');
    clear();
    ZegoUIKitSignalingPlugin().disconnectUser().then((result) {
      if (result.timeout) {
        ZIMWrapperLogger.warning('logout timeout');
      }
    });
  }

  Future<void> waitForLoginOrNot() async {
    if (currentUser == null) {
      ZIMWrapperLogger.info('wait for login...');
      loginCompleter ??= Completer();
      await loginCompleter!.future;
      loginCompleter = null;
    }
  }

  Future<int> checkNeedReloginOrNot(Exception error) async {
    if (error is! PlatformException) return -1;
    if (currentUser != null) return -1;
    final errorCode = int.tryParse(error.code) ?? -2;
    if (errorCode != ZIMErrorCode.networkModuleUserIsNotLogged) {
      return -1;
    }
    ZIMWrapperLogger.info('try auto relogin.');
    return connectUser(id: currentUser!.baseInfo.userID, name: currentUser!.baseInfo.userName);
  }

  Future<ZIMUserFullInfo> queryUser(String id, {bool isQueryFromServer = true}) async {
    await waitForLoginOrNot();
    final queryHash = Object.hash(id, isQueryFromServer);
    if (_queryUserCache[queryHash] == null) {
      _queryUserCache[queryHash] = AsyncCache(const Duration(minutes: 5));
    }
    return _queryUserCache[queryHash]!.fetch(() async {
      ZIMWrapperLogger.info('queryUser, id:$id, isQueryFromServer:$isQueryFromServer');
      final config = ZIMUserInfoQueryConfig()..isQueryFromServer = isQueryFromServer;
      return ZIM.getInstance()!.queryUsersInfo([id], config).then((ZIMUsersInfoQueriedResult result) {
        return result.userList.first;
      }).catchError((error) {
        Timer.run(() => _queryUserCache[queryHash]?.invalidate());

        final errorCode = int.tryParse(error.code) ?? -2;
        // qps limit
        if (error is PlatformException && errorCode == 6000012) {
          if (isQueryFromServer) {
            ZIMWrapperLogger.info('queryUser faild, retry queryUser from sdk');
            return queryUser(id, isQueryFromServer: false);
          } else {
            ZIMWrapperLogger.info('queryUser from sdk faild, retry queryUser from server later');
            return Future.delayed(
              Duration(milliseconds: Random().nextInt(5000)),
              () => queryUser(id),
            );
          }
        }

        return checkNeedReloginOrNot(error).then((retryCode) {
          if (retryCode == 0) {
            ZIMWrapperLogger.info('relogin success, retry queryUser');
            return queryUser(id);
          } else {
            ZIMWrapperLogger.severe('queryUser faild', error);
            throw error;
          }
        });
      });
    });
  }

  Future<void> updateUserInfo({String name = '', String avatarUrl = ''}) async {
    if (name.isNotEmpty) {
      await ZIM.getInstance()!.updateUserName(name).then((value) {
        ZIMWrapperLogger.info('updateUserName success: $name');
        currentUser?.baseInfo.userName = name;
      }).catchError((error) {
        ZIMWrapperLogger.info('updateUserName faild', error);
        throw error;
      });
    }
    if (avatarUrl.isNotEmpty) {
      await ZIM.getInstance()!.updateUserAvatarUrl(avatarUrl).then((value) {
        ZIMWrapperLogger.info('updateUserAvatarUrl success: $avatarUrl');
        currentUser?.userAvatarUrl = avatarUrl;
      }).catchError((error) {
        ZIMWrapperLogger.info('updateUserAvatarUrl faild', error);
        throw error;
      });
    }
  }
}

mixin ZIMWrapperCoreUserData {
  ZIMConnectionState get connectionState => ZegoUIKitSignalingPlugin().eventCenter.connectionState;
}

extension ZIMWrapperCoreUserEvent on ZIMWrapperCore {
  Stream<ZegoSignalingPluginConnectionStateChangedEvent> getConnectionStateChangedEventStream() {
    return ZegoUIKitSignalingPlugin().getConnectionStateChangedEventStream();
  }

  Stream<ZegoSignalingPluginTokenWillExpireEvent> getTokenWillExpireEventStream() {
    return ZegoUIKitSignalingPlugin().getTokenWillExpireEventStream();
  }
}
