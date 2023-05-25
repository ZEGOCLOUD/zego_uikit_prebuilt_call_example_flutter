// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'call_page.dart';
import 'home_page.dart';
import 'login_page.dart';

class PageRouteNames {
  static const String login = '/login';
  static const String home = '/home_page';
  static const String call = '/call';
}

class PageParam {
  static const String localUserID = 'local_user_id';
  static const String call_id = 'call_id';
}

/// Note that the userID needs to be globally unique,
final String localUserID = Random().nextInt(10000).toString();

const TextStyle textStyle = TextStyle(
  color: Colors.black,
  fontSize: 13.0,
  decoration: TextDecoration.none,
);

Map<String, WidgetBuilder> routes = {
  PageRouteNames.login: (context) => const LoginPage(),
  PageRouteNames.home: (context) => const HomePage(),
  PageRouteNames.call: (context) => const CallPage(),
};

class UserInfo {
  String id = '';
  String name = '';

  UserInfo({
    required this.id,
    required this.name,
  });

  bool get isEmpty => id.isEmpty;

  UserInfo.empty();
}

UserInfo currentUser = UserInfo.empty();
const String cacheUserIDKey = 'cache_user_id_key';
