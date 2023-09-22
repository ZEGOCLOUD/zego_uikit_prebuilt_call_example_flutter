import '../../services.dart';

class ZIMWrapperMessageUtils {
  static ZIMMediaMessage mediaMessageFactory(String path, ZIMMessageType messageType) {
    ZIMMediaMessage mediaMessage;

    switch (messageType) {
      case ZIMMessageType.image:
        mediaMessage = ZIMImageMessage(path);
        break;
      case ZIMMessageType.video:
        mediaMessage = ZIMVideoMessage(path);
        break;
      case ZIMMessageType.audio:
        mediaMessage = ZIMAudioMessage(path);
        break;
      case ZIMMessageType.file:
        mediaMessage = ZIMFileMessage(path);
        break;
      default:
        throw UnimplementedError();
    }
    return mediaMessage;
  }
}
