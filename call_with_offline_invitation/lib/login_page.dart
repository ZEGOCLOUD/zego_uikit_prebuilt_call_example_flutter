import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'util.dart';
import 'constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  var userIDNotifier = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();

    getUniqueUserId().then((userID) async {
      userIDNotifier.value = userID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: ValueListenableBuilder<String>(
          valueListenable: userIDNotifier,
          builder: (context, userID, _) {
            return Column(
              children: [
                Expanded(child: Container()),
                ElevatedButton(
                  child: const Text("Login", style: textStyle),
                  onPressed: userID.isEmpty
                      ? null
                      : () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString(cacheUserIDKey, userID);

                          currentUser.id = userID;
                          currentUser.name = 'user_$userID';

                          Navigator.pushNamed(
                            context,
                            PageRouteNames.home,
                          );
                        },
                ),
                Expanded(child: Container()),
              ],
            );
          },
        ),
      ),
    );
  }
}
