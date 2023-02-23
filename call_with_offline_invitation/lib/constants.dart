// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'call_page.dart';

class PageRouteNames {
  static const String login = "/login";
  static const String home = "/home_page";
  static const String call = "/call";
}

class PageParam {
  static const String localUserID = "local_user_id";
}

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
