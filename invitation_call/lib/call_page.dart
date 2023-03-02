// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Project imports:
import 'package:call_with_invitation/constants.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    Key? key,
  }) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final TextEditingController inviteeUsersIDTextCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: backButton(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Your userID: $localUserID'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      inviteeUserIDInput(),
                      const SizedBox(width: 5),
                      callButton(isVideoCall: false),
                      const SizedBox(width: 5),
                      callButton(isVideoCall: true),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
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

  Widget inviteeUserIDInput() {
    return Expanded(
      child: TextFormField(
        controller: inviteeUsersIDTextCtrl,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
        ],
        decoration: const InputDecoration(
          isDense: true,
          hintText: 'Please Enter Invitees ID',
          labelText: "Invitees ID, Separate ids by ','",
        ),
      ),
    );
  }

  Widget callButton({required bool isVideoCall}) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: inviteeUsersIDTextCtrl,
      builder: (context, inviteeUserID, _) {
        final invitees = getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.text);

        return ZegoSendCallInvitationButton(
          isVideoCall: isVideoCall,
          invitees: invitees,
          iconSize: const Size(40, 40),
          buttonSize: const Size(50, 50),
          onPressed: (String code, String message, List<String> errorInvitees) {
            if (errorInvitees.isNotEmpty) {
              var userIDs = '';
              for (var index = 0; index < errorInvitees.length; index++) {
                if (index >= 5) {
                  userIDs += '... ';
                  break;
                }

                final userID = errorInvitees.elementAt(index);
                userIDs += '$userID ';
              }
              if (userIDs.isNotEmpty) {
                userIDs = userIDs.substring(0, userIDs.length - 1);
              }

              var message = "User doesn't exist or is offline: $userIDs";
              if (code.isNotEmpty) {
                message += ', code: $code, message:$message';
              }
              showToast(
                message,
                position: StyledToastPosition.top,
                context: context,
              );
            } else if (code.isNotEmpty) {
              showToast(
                'code: $code, message:$message',
                position: StyledToastPosition.top,
                context: context,
              );
            }
          },
        );
      },
    );
  }

  List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
    final invitees = <ZegoUIKitUser>[];

    final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
    inviteeIDs.split(',').forEach((inviteeUserID) {
      if (inviteeUserID.isEmpty) {
        return;
      }

      invitees.add(ZegoUIKitUser(
        id: inviteeUserID,
        name: 'user_$inviteeUserID',
      ));
    });

    return invitees;
  }
}
