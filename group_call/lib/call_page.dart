// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'constants.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CallPageState();
}

class CallPageState extends State<CallPage> {
  /// Users who use the same callID can in the same call.
  final callIDTextCtrl = TextEditingController(text: 'group_call_id');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: backButton(),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: callIDTextCtrl,
                          decoration: const InputDecoration(
                            labelText: 'join a group call by id',
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              PageRouteNames.prebuilt_call,
                              arguments: <String, String>{
                                PageParam.call_id: callIDTextCtrl.text,
                              },
                            );
                          },
                          child: const Text('join'))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget backButton() {
    return ElevatedButton(
      child: const Text('Back', style: textStyle),
      onPressed: () async {
        Navigator.pop(context);
      },
    );
  }
}
