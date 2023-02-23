// Flutter imports:
import 'package:flutter/material.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      initialRoute: PageRouteNames.login,
      color: Colors.red,
      theme:  ThemeData(scaffoldBackgroundColor: const Color(0xFFEFEFEF)),
    );
  }
}
