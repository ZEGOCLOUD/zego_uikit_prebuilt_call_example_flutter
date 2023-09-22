part of 'imwrapper_core.dart';

extension ZIMWrapperCoreGroup on ZIMWrapperCore {
  Future<String?> createGroup(String name, List<String> inviteUserIDs, {String id = ''}) async {
    if (currentUser == null) return null;
    final groupInfo = ZIMGroupInfo()
      ..groupName = name
      ..groupID = id;
    return ZIM.getInstance()!.createGroup(groupInfo, inviteUserIDs).then((ZIMGroupCreatedResult zimResult) {
      ZIMWrapperLogger.info('createGroup: success, groupID: $id');
      db.conversations.insert(zimResult.groupInfo.toConversation());
      return Future<String?>.value(zimResult.groupInfo.baseInfo.groupID);
    }).catchError((error) {
      ZIMWrapperLogger.severe('createGroup: faild, name: $name, error: $error');
      return Future<String?>.error(error);
    });
  }

  Future<int> joinGroup(String id) async {
    if (currentUser == null) return -1;

    return ZIM.getInstance()!.joinGroup(id).then((ZIMGroupJoinedResult zimResult) {
      ZIMWrapperLogger.info('joinGroup: success, groupID: $id');
      db.conversations.insert(zimResult.groupInfo.toConversation());
      return 0;
    }).catchError((error) {
      final errorCode = int.tryParse(error.code) ?? -2;
      if (errorCode == ZIMErrorCode.groupModuleMemberIsAlreadyInTheGroup) {
        ZIM.getInstance()!.queryGroupList().then((ZIMGroupListQueriedResult zimResult) {
          var gotIt = false;
          for (final group in zimResult.groupList) {
            if (group.baseInfo!.id == id) {
              final wrapperConversation = db.conversations.get(id, ZIMConversationType.group);
              wrapperConversation.value = wrapperConversation.value.clone()
                ..name = group.baseInfo!.name
                ..avatarUrl = group.baseInfo!.url;
              gotIt = true;
              break;
            }
          }
          if (!gotIt) {
            ZIMWrapperLogger.info('joinGroup: warning, already in, but query faild: $id, '
                'insert a dummy conversation');
            db.conversations.insert(
              (ZIMConversation()
                    ..id = id
                    ..type = ZIMConversationType.group)
                  .tokit(),
            );
          }
        }).catchError((error) {
          ZIMWrapperLogger.severe('joinGroup: faild, already in, but query '
              'faild: $id, error: $error');
        });
      } else {
        ZIMWrapperLogger.severe('joinGroup: faild, groupID: $id, error: $error');
      }
      return errorCode;
    });
  }

  Future<int> addUersToGroup(String id, List<String> userIDs) async {
    if (currentUser == null) return -1;
    return ZIM.getInstance()!.inviteUsersIntoGroup(userIDs, id).then((ZIMGroupUsersInvitedResult zimResult) {
      ZIMWrapperLogger.info('addUersToGroup: success, groupID: $id');
      return 0;
    }).catchError((error) {
      ZIMWrapperLogger.severe('addUersToGroup: faild, groupID: $id, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> leaveGroup(String groupID) async {
    if (currentUser == null) return -1;

    return ZIM.getInstance()!.leaveGroup(groupID).then((ZIMGroupLeftResult zimResult) {
      ZIMWrapperLogger.info('leaveGroup: success, groupID: $groupID');
      db.conversations.remove(groupID, ZIMConversationType.group);
      return 0;
    }).catchError((error) {
      final errorCode = int.tryParse(error.code) ?? -2;
      if (errorCode == ZIMErrorCode.groupModuleUserIsNotInTheGroup) {
        db.conversations.remove(groupID, ZIMConversationType.group);
        return 0;
      }
      ZIMWrapperLogger.severe('leaveGroup: faild, groupID: $groupID, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> removeUesrsFromGroup(String groupID, List<String> userIDs) async {
    if (currentUser == null) return -1;
    return ZIM.getInstance()!.kickGroupMembers(userIDs, groupID).then((ZIMGroupMemberKickedResult zimResult) {
      ZIMWrapperLogger.info('removeUesrsFromGroup: success');
      return 0;
    }).catchError((error) {
      ZIMWrapperLogger.severe('removeUesrsFromGroup: faild, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> disbandGroup(String groupID) async {
    if (currentUser == null) return -1;

    return ZIM.getInstance()!.dismissGroup(groupID).then((ZIMGroupDismissedResult zimResult) {
      ZIMWrapperLogger.info('disbandGroup: success');
      return 0;
    }).catchError((error) {
      ZIMWrapperLogger.severe('disbandGroup: faild, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> transferGroupOwner(String groupID, String toUserID) async {
    if (currentUser == null) return -1;
    return ZIM.getInstance()!.transferGroupOwner(toUserID, groupID).then((ZIMGroupOwnerTransferredResult zimResult) {
      ZIMWrapperLogger.info('transferGroupOwner: success');
      return 0;
    }).catchError((error) {
      return ZIMWrapperCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry transferGroupOwner');
          return transferGroupOwner(groupID, toUserID);
        } else {
          ZIMWrapperLogger.severe('transferGroupOwner faild', error);
          return Future.value(int.tryParse(error.code) ?? -2);
        }
      });
    });
  }

  Future<ZIMGroupMemberInfo?> queryGroupMemberInfo(String groupID, String userID) async {
    final queryHash = '$groupID,$userID';
    _queryGroupMemberInfoCache[queryHash] ??= AsyncCache(const Duration(minutes: 1));
    if (currentUser == null) {
      _queryGroupMemberInfoCache.clear();
      return null;
    }

    return _queryGroupMemberInfoCache[queryHash]!.fetch(() async {
      return ZIM.getInstance()!.queryGroupMemberInfo(userID, groupID).then((ZIMGroupMemberInfoQueriedResult zimResult) {
        ZIMWrapperLogger.info('queryGroupMemberInfo: success');
        return Future<ZIMGroupMemberInfo?>.value(zimResult.userInfo);
      }).catchError((error) async {
        final errorCode = int.tryParse(error.code) ?? -2;
        if (errorCode == 6000012) {
          ZIMWrapperLogger.info('queryGroupMemberInfo faild, retry later');

          return Future.delayed(
            Duration(milliseconds: Random().nextInt(5000)),
            () => queryGroupMemberInfo(groupID, userID),
          );
        }

        return ZIMWrapperCore.instance.checkNeedReloginOrNot(error).then((retryCode) async {
          if (retryCode == 0) {
            ZIMWrapperLogger.info('relogin success, retry queryUser');
            return queryGroupMemberInfo(groupID, userID);
          } else {
            ZIMWrapperLogger.severe('queryGroupMemberInfo faild', error);
            return Future<ZIMGroupMemberInfo?>.value(null);
          }
        });
      });
    });
  }

  ListNotifier<ZIMGroupMemberInfo> queryGroupMemberList(String groupID, {int nextFlag = 0}) {
    if (currentUser == null) return ListNotifier([]);

    final groupMemberList = db.conversations.get(groupID, ZIMConversationType.group).value.groupMemberList;

    _queryGroupMemberFrequencyLimiter[groupID] ??= FrequencyLimiter(const Duration(seconds: 1));
    return _queryGroupMemberFrequencyLimiter[groupID]!.run(groupMemberList, () {
      ZIM
          .getInstance()!
          .queryGroupMemberList(
            groupID,
            ZIMGroupMemberQueryConfig()
              ..count = 100
              ..nextFlag = nextFlag,
          )
          .then((ZIMGroupMemberListQueriedResult zimResult) {
        _addUsersToGroupDB(groupID, zimResult.userList);
        if (zimResult.nextFlag != nextFlag) {
          queryGroupMemberList(groupID, nextFlag: zimResult.nextFlag);
        }
      }).catchError((error) {
        final errorCode = int.tryParse(error.code) ?? -2;
        if (errorCode == 6000012) {
          ZIMWrapperLogger.info('queryGroup faild, retry later');

          Future.delayed(
            Duration(milliseconds: Random().nextInt(5000)),
            () => queryGroupMemberList(groupID, nextFlag: nextFlag),
          );
          return;
        }

        ZIMWrapperCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
          if (retryCode == 0) {
            ZIMWrapperLogger.info('relogin success, retry queryUser');
            queryGroupMemberList(groupID, nextFlag: nextFlag);
          } else {
            ZIMWrapperLogger.severe('queryGroupMemberList: faild, error: $error');
            throw error;
          }
        });
      });
      return groupMemberList;
    });
  }

  Future<ZIMGroupFullInfo?> queryGroup(String groupID) async {
    final queryHash = groupID;
    _queryGroupCache[queryHash] ??= AsyncCache(const Duration(minutes: 1));

    if (currentUser == null) {
      _queryGroupCache.clear();
      return null;
    }

    return _queryGroupCache[queryHash]!.fetch(() async {
      ZIMWrapperLogger.info('queryGroup, groupID:$groupID');
      return ZIM.getInstance()!.queryGroupInfo(groupID).then<ZIMGroupFullInfo?>((ZIMGroupInfoQueriedResult result) {
        return Future.value(result.groupInfo);
      });
    }).catchError((error) {
      final errorCode = int.tryParse(error.code) ?? -2;
      if (errorCode == 6000012) {
        ZIMWrapperLogger.info('queryGroup faild, retry later');

        return Future.delayed(
          Duration(milliseconds: Random().nextInt(5000)),
          () => queryGroup(groupID),
        );
      }

      return ZIMWrapperCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMWrapperLogger.info('relogin success, retry queryUser');
          return queryGroup(groupID);
        } else {
          Timer.run(() => _queryGroupCache[queryHash]?.invalidate());
          ZIMWrapperLogger.severe('queryGroup faild', error);
          return Future.value(null);
        }
      });
    });
  }

  Future<int?> queryGroupMemberCount(String groupID) async {
    final queryHash = groupID;
    _queryGroupMemberCountCache[queryHash] ??= AsyncCache(const Duration(minutes: 1));
    if (currentUser == null) {
      _queryGroupMemberCountCache.clear();
      return null;
    }

    return _queryGroupMemberCountCache[queryHash]!.fetch(() async {
      return ZIM.getInstance()!.queryGroupMemberCount(groupID).then((ZIMGroupMemberCountQueriedResult zimResult) {
        ZIMWrapperLogger.info('queryGroupMemberCount: success');
        return Future<int?>.value(zimResult.count);
      }).catchError((error) {
        return ZIMWrapperCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
          if (retryCode == 0) {
            ZIMWrapperLogger.info('relogin success, retry queryGroupMemberCount');
            return queryGroupMemberCount(groupID);
          } else {
            ZIMWrapperLogger.severe('queryGroupMemberCount faild', error);
            return Future<int?>.value(0);
          }
        });
      });
    });
  }
}

extension ZIMWrapperCoreGroupEvent on ZIMWrapperCore {
  void onGroupStateChanged(ZIM zim, ZIMGroupState state, ZIMGroupEvent event, ZIMGroupOperatedInfo operatedInfo,
      ZIMGroupFullInfo groupInfo) {
    ZIMWrapperLogger.info('onGroupStateChanged');
  }

  void onGroupNameUpdated(ZIM zim, String groupName, ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMWrapperLogger.info('onGroupNameUpdated');
  }

  void onGroupAvatarUrlUpdated(ZIM zim, String groupAvatarUrl, ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMWrapperLogger.info('onGroupAvatarUrlUpdated');
  }

  void onGroupNoticeUpdated(ZIM zim, String groupNotice, ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMWrapperLogger.info('onGroupNoticeUpdated');
  }

  void onGroupAttributesUpdated(
      ZIM zim, List<ZIMGroupAttributesUpdateInfo> updateInfo, ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMWrapperLogger.info('onGroupAttributesUpdated');
  }

  void onGroupMemberStateChanged(ZIM zim, ZIMGroupMemberState state, ZIMGroupMemberEvent event,
      List<ZIMGroupMemberInfo> userList, ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMWrapperLogger.info('onGroupMemberStateChanged');
    final groupMemberList = db.conversations.get(groupID, ZIMConversationType.group).value.groupMemberList;
    if (state == ZIMGroupMemberState.enter) {
      _addUsersToGroupDB(groupID, userList);
    } else {
      _removeUsersToGroupDB(groupID, userList);
    }
  }

  void onGroupMemberInfoUpdated(
      ZIM zim, List<ZIMGroupMemberInfo> userInfo, ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMWrapperLogger.info('onGroupMemberInfoUpdated');
  }

  void _addUsersToGroupDB(String groupID, List<ZIMGroupMemberInfo> userList) {
    final groupMemberList = db.conversations.get(groupID, ZIMConversationType.group).value.groupMemberList;
    groupMemberList.addAll(
      userList,
      add: (newUser) => groupMemberList.value.indexWhere((e) => e.userID == newUser.userID) == -1,
    );
  }

  void _removeUsersToGroupDB(String groupID, List<ZIMGroupMemberInfo> userList) {
    final groupMemberList = db.conversations.get(groupID, ZIMConversationType.group).value.groupMemberList;
    for (final user in userList) {
      groupMemberList.removeWhere((e) => e.userID == user.userID);
    }
    groupMemberList.triggerNotify();
  }
}
