import 'dart:async';

import 'package:flutter/material.dart';

import 'callkit_zim_wrapper/callkit_zim_wrapper.dart';
import 'home_page.dart';

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
          return demoMessageListPage(context, ZIMWrapperConversation()..id = userIDController.text);
        }));
      }
    });
  });
}

void onCallInvitationSent(BuildContext context, String code, String message, List<String> errorInvitees) {
  var log = '';
  if (errorInvitees.isNotEmpty) {
    log = "User doesn't exist or is offline: ${errorInvitees[0]}";
    if (code.isNotEmpty) {
      log += ', code: $code, message:$message';
    }
  } else if (code.isNotEmpty) {
    log = 'code: $code, message:$message';
  }

  if (log.isEmpty) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(log)),
  );
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

void showDefaultAddUserToGroupDialog(BuildContext context, String groupID) {
  final groupUsersController = TextEditingController();
  Timer.run(() {
    showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: 3,
                  controller: groupUsersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User IDs',
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
      if (groupUsersController.text.isNotEmpty) {
        ZIMWrapper().addUersToGroup(groupID, groupUsersController.text.split(',')).then((int? errorCode) {
          if (errorCode != 0) {
            debugPrint('addUersToGroup faild');
          }
        });
      }
    });
  });
}

void showDefaultRemoveUserFromGroupDialog(BuildContext context, String groupID) {
  final groupUsersController = TextEditingController();
  Timer.run(() {
    showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Remove User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: 3,
                  controller: groupUsersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User IDs',
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
      if (groupUsersController.text.isNotEmpty) {
        ZIMWrapper().removeUesrsFromGroup(groupID, groupUsersController.text.split(',')).then((int? errorCode) {
          if (errorCode != 0) {
            debugPrint('addUersToGroup faild');
          }
        });
      }
    });
  });
}

Future<dynamic> showDefaultUserListDialog(BuildContext context, String groupID) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MemberList', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                ValueListenableBuilder(
                  valueListenable: ZIMWrapper().queryGroupMemberList(groupID),
                  builder: (BuildContext context, List<ZIMGroupMemberInfo> memberList, Widget? child) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      height: 200,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        scrollDirection: Axis.vertical,
                        itemCount: memberList.length,
                        itemBuilder: (context, index) {
                          final member = memberList[index];
                          return GestureDetector(
                            onTap: () async {},
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Image.network(
                                    member.memberAvatarUrl.isEmpty
                                        ? 'https://robohash.org/${member.userID}.png?set=set4'
                                        : member.memberAvatarUrl,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    memberList[index].userName,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      });
}
