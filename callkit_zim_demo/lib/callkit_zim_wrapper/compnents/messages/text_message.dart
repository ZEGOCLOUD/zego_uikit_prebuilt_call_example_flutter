import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/services.dart';

class ZIMWrapperTextMessage extends StatelessWidget {
  const ZIMWrapperTextMessage({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  final ZIMWrapperMessage message;
  final void Function(BuildContext context, ZIMWrapperMessage message, Function defaultAction)? onPressed;
  final void Function(
          BuildContext context, LongPressStartDetails details, ZIMWrapperMessage message, Function defaultAction)?
      onLongPress;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => onPressed?.call(context, message, () {}),
        onLongPressStart: (details) => onLongPress?.call(context, details, message, () {
          Clipboard.setData(ClipboardData(text: message.textContent!.text));
        }),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(message.isMine ? 1 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            message.textContent!.text,
            textAlign: TextAlign.left,
            style: TextStyle(color: message.isMine ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color),
          ),
        ),
      ),
    );
  }
}
