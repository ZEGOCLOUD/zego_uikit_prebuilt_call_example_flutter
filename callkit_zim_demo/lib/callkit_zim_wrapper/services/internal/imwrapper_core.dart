import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../../callkit_zim_wrapper.dart';
import 'defines.dart';
import 'event.dart';
import 'utils/frequency_limiter.dart';

part 'imwrapper_core_conversation.dart';
part 'imwrapper_core_group.dart';
part 'imwrapper_core_message.dart';
part 'imwrapper_core_user.dart';
part 'imwrapper_logger.dart';

const int kdefaultLoadCount = 30; // default is 30
const bool kEnableAutoDownload = true;

class ZIMWrapperCore with ZIMWrapperCoreEvent, ZIMWrapperCoreUserData {
  factory ZIMWrapperCore() => instance;

  ZIMWrapperCore._internal();

  static ZIMWrapperCore instance = ZIMWrapperCore._internal();

  int appID = 0;
  String appSign = '';
  String appSecret = '';
  bool useToken = false;

  bool isInited = false;
  ZIMUserFullInfo? currentUser;
  ZIMWrapperDB db = ZIMWrapperDB();

  final Map<String, FrequencyLimiter> _queryGroupMemberFrequencyLimiter = {};
  final Map<String, AsyncCache<ZIMGroupFullInfo?>> _queryGroupCache = {};
  final Map<String, AsyncCache<int?>> _queryGroupMemberCountCache = {};
  final Map<String, AsyncCache<ZIMGroupMemberInfo?>> _queryGroupMemberInfoCache = {};
  final Map<int, AsyncCache<ZIMUserFullInfo>> _queryUserCache = {};

  Completer? loginCompleter;

  ValueNotifier<int> totalUnreadMessageCount = ValueNotifier<int>(0);

  Future<String> getVersion() async {
    final signalingVersion = await ZegoUIKitSignalingPlugin().getVersion();
    return 'ZIMWrapper:1.7.0;plugin:$signalingVersion';
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    Level logLevel = Level.ALL,
    bool enablePrint = true,
  }) async {
    if (isInited) {
      ZIMWrapperLogger.info('has inited.');
      return;
    }
    isInited = true;
    ZIMWrapperLogger.init(logLevel: logLevel, enablePrint: enablePrint);
    initEventHandler();

    this.appID = appID;
    this.appSign = appSign;
    this.appSecret = appSecret;

    ZIMWrapperLogger.info('init, appID:$appID');

    ZegoUIKitSignalingPlugin().init(appID: appID, appSign: appSign);

    getVersion().then((value) {
      ZIMWrapperLogger.info('Zego IM SDK version: $value');
    });
  }

  Future<void> uninit() async {
    if (!isInited) {
      ZIMWrapperLogger.info('is not inited.');
      return;
    }
    uninitEventHandler();
    ZIMWrapperLogger.info('destroy.');
    await disconnectUser();
    ZegoUIKitSignalingPlugin().uninit();
    isInited = false;
  }

  void clear() {
    _queryGroupCache.clear();
    _queryUserCache.clear();
    db.clear();
    currentUser = null;
  }

  Stream<ZegoSignalingPluginErrorEvent> getErrorEventStream() {
    return ZegoUIKitSignalingPlugin().getErrorEventStream();
  }

  Stream<ZegoSignalingPluginTokenWillExpireEvent> getTokenWillExpireEventStream() {
    return ZegoUIKitSignalingPlugin().getTokenWillExpireEventStream();
  }
}
