import 'package:flutter/material.dart';

import 'util.dart';
import 'constants.dart';

var userIDNotifier = ValueNotifier<String>("");

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

    getUniqueUserId().then((userID) {
      userIDNotifier.value = userID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<String>(
        valueListenable: userIDNotifier,
        builder: (context, userID, _) {
          return Column(
            children: [
              Expanded(child: Container()),
              Text('Your userID: $userID', style: textStyle),
              const SizedBox(height: 50),
              ElevatedButton(
                child: const Text("Login", style: textStyle),
                onPressed: userID.isEmpty
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          PageRouteNames.home,
                          arguments: <String, String>{
                            PageParam.localUserID: userIDNotifier.value,
                          },
                        );
                      },
              ),
              Expanded(child: Container()),
            ],
          );
        },
      ),
    );
  }
}
