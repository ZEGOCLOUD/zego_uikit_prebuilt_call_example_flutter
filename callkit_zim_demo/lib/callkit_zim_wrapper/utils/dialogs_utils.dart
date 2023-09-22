import 'dart:async';

import 'package:flutter/material.dart';

import '../pages/pages.dart';
import '../services/services.dart';

extension ZIMWrapperDefaultDialogService on ZIMWrapper {
  void showDefaultNewPeerChatDialog(BuildContext context) {
    final userIDController = TextEditingController();
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Chat'),
              content: TextField(
                controller: userIDController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User ID',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      ).then((ok) {
        if (ok != true) return;
        if (userIDController.text.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ZIMWrapperMessageListPage(
              conversationID: userIDController.text,
            );
          }));
        }
      });
    });
  }

  void showDefaultNewGroupChatDialog(BuildContext context) {
    final groupIDController = TextEditingController();
    final groupNameController = TextEditingController();
    final groupUsersController = TextEditingController();
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Group'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: groupNameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Group Name',
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: groupIDController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ID(optional)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 3,
                    controller: groupUsersController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Invite User IDs',
                      hintText: 'separate by comma, e.g. 123,987,229',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      ).then((bool? ok) {
        if (ok != true) return;
        if (groupNameController.text.isNotEmpty && groupUsersController.text.isNotEmpty) {
          ZIMWrapper()
              .createGroup(
            groupNameController.text,
            groupUsersController.text.split(','),
            id: groupIDController.text,
          )
              .then((String? conversationID) {
            if (conversationID != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ZIMWrapperMessageListPage(
                  conversationID: conversationID,
                  conversationType: ZIMConversationType.group,
                );
              }));
            }
          });
        }
      });
    });
  }

  void showDefaultJoinGroupDialog(BuildContext context) {
    final groupIDController = TextEditingController();
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Join Group'),
              content: TextField(
                controller: groupIDController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Group ID',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      ).then((bool? ok) {
        if (ok != true) return;
        if (groupIDController.text.isNotEmpty) {
          ZIMWrapper().joinGroup(groupIDController.text).then((int errorCode) {
            if (errorCode == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ZIMWrapperMessageListPage(
                  conversationID: groupIDController.text,
                  conversationType: ZIMConversationType.group,
                );
              }));
            }
          });
        }
      });
    });
  }
}
