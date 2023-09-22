import 'package:flutter/material.dart';

import '../../services/services.dart';

class ZIMWrapperFileMessage extends StatelessWidget {
  const ZIMWrapperFileMessage({
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
    final color = message.isMine ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color;
    final textStyle = TextStyle(color: color);

    return Flexible(
      child: GestureDetector(
        onTap: () => onPressed?.call(context, message, () {}),
        onLongPressStart: (details) => onLongPress?.call(context, details, message, () {}),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(message.isMine ? 1 : 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_copy, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: message.isNetworkUrl
                      ? [
                          Text(message.fileContent!.fileName,
                              style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ]
                      : [
                          Text(message.fileContent!.fileName,
                              style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(
                            fileSizeFormat(message.fileContent!.fileSize),
                            style: textStyle,
                            maxLines: 1,
                          ),
                        ],
                ),
              ),
              const Icon(Icons.download),
            ],
          ),
        ),
      ),
    );
  }

  String fileSizeFormat(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).ceil()} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).ceil()} MB';
    } else {
      return '${(size / 1024 / 1024 / 1024).ceil()} GB';
    }
  }
}
