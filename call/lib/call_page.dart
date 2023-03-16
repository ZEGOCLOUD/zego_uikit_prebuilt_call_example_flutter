// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'constants.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CallPageState();
}

class CallPageState extends State<CallPage> {
  /// Users who use the same callID can in the same call.
  final callIDTextCtrl = TextEditingController(text: 'call_id');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Center(
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
                      labelText: 'join a call by id',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, PageRouteNames.prebuilt_call,
                        arguments: <String, String>{
                          PageParam.call_id: callIDTextCtrl.text,
                        });
                  },
                  child: const Text('join'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
