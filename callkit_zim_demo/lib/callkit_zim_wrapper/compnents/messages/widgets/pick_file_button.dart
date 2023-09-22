import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../callkit_zim_wrapper.dart';
import '../../../services/services.dart';

export 'package:file_picker/file_picker.dart';

class ZIMWrapperPickFileButton extends StatelessWidget {
  const ZIMWrapperPickFileButton({
    Key? key,
    required this.onFilePicked,
    this.type = FileType.any,
    this.icon,
  }) : super(key: key);

  final Function(List<PlatformFile> files) onFilePicked;
  final Widget? icon;
  final FileType type;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        ZIMWrapper().pickFiles(type: type).then(onFilePicked);
      },
      icon: icon ??
          Icon(
            Icons.attach_file,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.64),
          ),
    );
  }
}
