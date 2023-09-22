import 'package:flutter/material.dart';

import '../../services/services.dart';

class ZIMWrapperAvatar extends StatelessWidget {
  const ZIMWrapperAvatar({
    Key? key,
    required this.userID,
    this.height,
    this.width,
  }) : super(key: key);
  final String userID;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder(
        future: ZIMWrapper().queryUser(userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data!).icon;
          } else {
            return const Icon(Icons.person);
          }
        },
      ),
    );
  }
}
