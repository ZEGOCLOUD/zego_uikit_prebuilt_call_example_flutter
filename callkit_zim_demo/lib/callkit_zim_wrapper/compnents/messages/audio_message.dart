import 'package:flutter/material.dart';

import '../../services/services.dart';

class ZIMWrapperAudioMessage extends StatelessWidget {
  const ZIMWrapperAudioMessage({
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
        onLongPressStart: (details) => onLongPress?.call(context, details, message, () {}),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).primaryColor.withOpacity(message.isMine ? 1 : 0.1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_arrow,
                color: message.isMine ? Colors.white : Theme.of(context).primaryColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: message.isMine ? Colors.white : Theme.of(context).primaryColor.withOpacity(0.4),
                      ),
                      Positioned(
                        left: 0,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: message.isMine ? Colors.white : Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Text(
                '0:${message.audioContent!.audioDuration < 10 ? "0" : ''}${message.audioContent!.audioDuration < 1 ? 1 : message.audioContent!.audioDuration}',
                style: TextStyle(
                  fontSize: 12,
                  color: message.isMine ? Colors.white : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
