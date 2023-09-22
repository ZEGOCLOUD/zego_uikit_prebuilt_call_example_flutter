part of 'services.dart';

mixin ZIMWrapperInputService {
  Future<List<PlatformFile>> pickFiles({FileType type = FileType.any, bool allowMultiple = true}) async {
    try {
      await requestPermission();
      ZIMWrapperLogger.info('pickFiles: start, ${DateTime.now().millisecondsSinceEpoch}');
      // see https://github.com/miguelpruivo/flutter_file_picker/wiki/API#-filepickerpickfiles
      final ret = (await FilePicker.platform.pickFiles(
            type: type,
            allowMultiple: allowMultiple,
            onFileLoading: (p0) {
              ZIMWrapperLogger.info('onFileLoading: '
                  '$p0,${DateTime.now().millisecondsSinceEpoch}');
            },
          ))
              ?.files ??
          [];
      ZIMWrapperLogger.info('pickFiles: $ret, ${DateTime.now().millisecondsSinceEpoch}');
      return ret;
    } on PlatformException catch (e) {
      ZIMWrapperLogger.severe('Unsupported operation $e');
    } catch (e) {
      ZIMWrapperLogger.severe(e.toString());
    }
    return [];
  }

  ZIMMessageType getMessageTypeByFileExtension(PlatformFile file) {
    const supportImageList = <String>['jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff']; // <10M
    const supportVideoList = <String>['mp4', 'mov']; // <100M
    const supportAudioList = <String>['mp3', 'm4a']; // <300s, <6M

    var messageType = ZIMMessageType.file;

    if (file.extension == null) {
      return messageType;
    }
    if (supportImageList.contains(file.extension!.toLowerCase())) {
      messageType = ZIMMessageType.image;
    } else if (supportVideoList.contains(file.extension!.toLowerCase())) {
      messageType = ZIMMessageType.video;
    } else if (supportAudioList.contains(file.extension!.toLowerCase())) {
      messageType = ZIMMessageType.audio;
    }

    return messageType;
  }

  Future<void> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return;
    }
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      ZIMWrapperLogger.severe('Warn: Permission.storage not granted, $status');
      if (Platform.isAndroid) {
        ZIMWrapperLogger.severe(
            'Warn: On Android TIRAMISU and higher this permission is deprecrated and always returns `PermissionStatus.denied`');
      }
    }

    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (status != PermissionStatus.granted) {
        ZIMWrapperLogger.severe('Error: Permission.storage not granted, $status');
      }
    }

    if (Platform.isAndroid) {
      final status = await Permission.audio.request();
      if (status != PermissionStatus.granted) {
        ZIMWrapperLogger.severe('Error: Permission.storage not granted, $status');
      }
    }
    if (Platform.isAndroid) {
      final status = await Permission.videos.request();
      if (status != PermissionStatus.granted) {
        ZIMWrapperLogger.severe('Error: Permission.storage not granted, $status');
      }
    }
  }
}
