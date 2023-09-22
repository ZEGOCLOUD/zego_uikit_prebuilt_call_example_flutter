import 'package:flutter/material.dart';

import 'default_dialogs.dart';

class GroupPagePopupMenuButton extends StatefulWidget {
  const GroupPagePopupMenuButton({Key? key, required this.groupID})
      : super(key: key);

  final String groupID;

  @override
  State<GroupPagePopupMenuButton> createState() =>
      _GroupPagePopupMenuButtonState();
}

class _GroupPagePopupMenuButtonState extends State<GroupPagePopupMenuButton> {
  final userIDController = TextEditingController();
  final groupNameController = TextEditingController();
  final groupUsersController = TextEditingController();
  final groupIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      position: PopupMenuPosition.under,
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'Add User',
            child: const ListTile(
                leading: Icon(Icons.group_add),
                title: Text('Add User', maxLines: 1)),
            onTap: () =>
                showDefaultAddUserToGroupDialog(context, widget.groupID),
          ),
          PopupMenuItem(
            value: 'Add User',
            child: const ListTile(
                leading: Icon(Icons.group_remove),
                title: Text('Remove User', maxLines: 1)),
            onTap: () =>
                showDefaultRemoveUserFromGroupDialog(context, widget.groupID),
          ),
          PopupMenuItem(
            value: 'show UserList',
            child: const ListTile(
                leading: Icon(Icons.people),
                title: Text('show UserList', maxLines: 1)),
            onTap: () => showDefaultUserListDialog(context, widget.groupID),
          ),
        ];
      },
    );
  }
}
