// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'constants.dart';

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
        final prefs = await SharedPreferences.getInstance();
        prefs.remove(cacheUserIDKey);

        Navigator.pushNamed(
          context,
          PageRouteNames.login,
        );
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
