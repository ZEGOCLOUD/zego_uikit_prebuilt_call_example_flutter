import 'package:flutter/material.dart';

import '../../../callkit_zim_wrapper.dart';
import '../../../services/services.dart';

class ZIMWrapperMessageStatusDot extends StatelessWidget {
  const ZIMWrapperMessageStatusDot(this.message, {Key? key}) : super(key: key);
  final ZIMWrapperMessage message;

  Color dotColor(BuildContext context, ZIMMessageSentStatus status) {
    switch (status) {
      case ZIMMessageSentStatus.failed:
        return Theme.of(context).colorScheme.error;
      case ZIMMessageSentStatus.sending:
        return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
      case ZIMMessageSentStatus.success:
        return Theme.of(context).primaryColor;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(context, message.info.sentStatus),
        shape: BoxShape.circle,
      ),
      child: Icon(
        message.info.sentStatus == ZIMMessageSentStatus.failed ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
