// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Project imports:
import 'package:call_with_invitation/constants.dart';
import 'package:call_with_invitation/login_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Stack(
            children: [
              const Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Text('Home Page', textAlign: TextAlign.center),
              ),
              Positioned(
                top: 20,
                right: 10,
                child: logoutButton(),
              ),
              Positioned(
                top: 50,
                left: 10,
                child: Text('Your user ID: ${currentUser.id}'),
              ),
              userListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget logoutButton() {
    return ElevatedButton(
      child: const Text('Logout', style: textStyle),
      onPressed: () async {
        logout().then((value) {
          onUserLogout();

          Navigator.pushNamed(
            context,
            PageRouteNames.login,
          );
        });
      },
    );
  }

  Widget userListView() {
    return Center(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          final userName = 'User $index';
          return Row(
            children: [
              const SizedBox(width: 20),
              Text(userName, style: textStyle),
              Expanded(child: Container()),
              ElevatedButton(
                child: const Text('Details', style: textStyle),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    PageRouteNames.call,
                  );
                },
              ),
              const SizedBox(width: 20),
            ],
          );
        },
      ),
    );
  }
}
