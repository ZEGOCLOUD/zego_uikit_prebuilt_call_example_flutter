import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

import '../callkit_zim_wrapper.dart';

export 'defines.dart';
export 'internal/internal.dart';

part 'conversation_service.dart';
part 'group_service.dart';
part 'input_service.dart';
part 'message_service.dart';
part 'user_service.dart';

class ZIMWrapper
    with
        ZIMWrapperConversationService,
        ZIMWrapperUserService,
        ZIMWrapperMessageService,
        ZIMWrapperInputService,
        ZIMWrapperGroupService {
  factory ZIMWrapper() => instance;

  ZIMWrapper._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static final ZIMWrapper instance = ZIMWrapper._internal();

  Future<void> init({required int appID, String appSign = '', String appSecret = ''}) async {
    return ZIMWrapperCore.instance.init(appID: appID, appSign: appSign, appSecret: appSecret);
  }

  Future<void> uninit() async {
    return ZIMWrapperCore.instance.uninit();
  }
}
