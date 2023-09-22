import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../callkit_zim_wrapper.dart';

export 'package:file_picker/file_picker.dart';

class ZIMWrapperPickMediaButton extends StatelessWidget {
  const ZIMWrapperPickMediaButton({
    Key? key,
    required this.onFilePicked,
    this.icon,
  }) : super(key: key);

  final Function(List<PlatformFile> files) onFilePicked;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        ZIMWrapper().pickFiles(type: FileType.media).then(onFilePicked);
      },
      icon: icon ??
          Icon(
            Icons.photo_library,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.64),
          ),
    );
  }
}
