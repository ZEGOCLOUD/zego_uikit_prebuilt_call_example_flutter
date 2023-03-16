// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'constants.dart';
import 'login_service.dart';
import 'util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  var userIDNotifier = ValueNotifier<String>('');

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
                  onPressed: userID.isEmpty
                      ? null
                      : () async {
                          login(userID: userID, userName: 'user_$userID')
                              .then((value) {
                            onUserLogin();

                            Navigator.pushNamed(
                              context,
                              PageRouteNames.home,
                            );
                          });
                        },
                  child: const Text('Login', style: textStyle),
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
