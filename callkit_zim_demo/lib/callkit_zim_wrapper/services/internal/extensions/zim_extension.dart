// ignore_for_file: avoid_dynamic_calls

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../callkit_zim_wrapper.dart';
import '../defines.dart';

extension ZIMMessageExtend on ZIMMessage {
  ZIMWrapperMessage tokit() {
    final ret = ZIMWrapperMessage()
      ..zim = this
      ..type = type
      ..info = (ZIMWrapperMessageBaseInfo()
        ..messageID = messageID
        ..localMessageID = localMessageID
        ..senderUserID = senderUserID
        ..conversationID = conversationID
        ..direction = direction
        ..sentStatus = sentStatus
        ..conversationType = conversationType
        ..timestamp = timestamp
        ..conversationSeq = conversationSeq
        ..orderKey = orderKey
        ..isUserInserted = isUserInserted
        ..receiptStatus = receiptStatus);

    switch (type) {
      case ZIMMessageType.text:
        final zimMessage = this as ZIMTextMessage;
        ret.textContent = ZIMWrapperMessageTextContent()..text = zimMessage.message;
        break;
      case ZIMMessageType.image:
        final zimMessage = this as ZIMImageMessage;
        ret.imageContent = (ZIMWrapperMessageImageContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize
          ..thumbnailDownloadUrl = zimMessage.thumbnailDownloadUrl
          ..thumbnailLocalPath = zimMessage.thumbnailLocalPath
          ..largeImageDownloadUrl = zimMessage.largeImageDownloadUrl
          ..largeImageLocalPath = zimMessage.largeImageLocalPath
          ..originalImageWidth = zimMessage.originalImageWidth
          ..originalImageHeight = zimMessage.originalImageHeight
          ..largeImageWidth = zimMessage.largeImageWidth
          ..largeImageHeight = zimMessage.largeImageHeight
          ..thumbnailWidth = zimMessage.thumbnailWidth
          ..thumbnailHeight = zimMessage.thumbnailHeight);
        break;
      case ZIMMessageType.file:
        final zimMessage = this as ZIMFileMessage;
        ret.fileContent = (ZIMWrapperMessageFileContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize);
        break;
      case ZIMMessageType.audio:
        final zimMessage = this as ZIMAudioMessage;
        ret.audioContent = (ZIMWrapperMessageAudioContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize
          ..audioDuration = zimMessage.audioDuration);
        break;
      case ZIMMessageType.video:
        final zimMessage = this as ZIMVideoMessage;
        ret.videoContent = (ZIMWrapperMessageVideoContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize
          ..videoDuration = zimMessage.videoDuration
          ..videoFirstFrameDownloadUrl = zimMessage.videoFirstFrameDownloadUrl
          ..videoFirstFrameLocalPath = zimMessage.videoFirstFrameLocalPath
          ..videoFirstFrameWidth = zimMessage.videoFirstFrameWidth
          ..videoFirstFrameHeight = zimMessage.videoFirstFrameHeight);
        break;
      case ZIMMessageType.system:
        final zimMessage = this as ZIMSystemMessage;
        ret.systemContent = (ZIMWrapperMessageSystemContent()..info = zimMessage.message);
        break;
      default:
        break;
    }

    if (this is ZIMMediaMessage && ret.isNetworkUrl && ret.autoContent.fileDownloadUrl.isNotEmpty) {
      ret.autoContent.fileName = Uri.parse(ret.autoContent.fileDownloadUrl).pathSegments.last;
    }

    return ret;
  }
}

extension ZIMWrapperMessageExtend on ZIMWrapperMessage {
  bool get isMine => info.direction == ZIMMessageDirection.send;

  String tostr() {
    switch (type) {
      case ZIMWrapperMessageType.text:
        return textContent!.text;
      case ZIMWrapperMessageType.revoke:
        return 'Recalled a message';
      default:
        return '[${type.name}]';
    }
  }

  ZIMWrapperMessage clone() {
    return ZIMWrapperMessage()
      ..type = type
      ..info = info
      ..imageContent = imageContent
      ..videoContent = videoContent
      ..audioContent = audioContent
      ..fileContent = fileContent
      ..textContent = textContent
      ..systemContent = systemContent
      ..zim = zim;
  }

  // if the media message send with fileDownloadUrl
  // the fileUID will be empty
  bool get isNetworkUrl {
    return (zim is ZIMMediaMessage) && autoContent.fileUID.isEmpty;
  }

  void reGenerateZIMMessage() {
    if (type == ZIMMessageType.text) {
      zim = ZIMTextMessage(message: textContent?.text ?? '');
    } else if (type == ZIMMessageType.image ||
        type == ZIMMessageType.audio ||
        type == ZIMMessageType.video ||
        type == ZIMMessageType.file) {
      zim = ZIMWrapperMessageUtils.mediaMessageFactory(autoContent.fileLocalPath, type)
        ..fileDownloadUrl = autoContent.fileDownloadUrl
        ..fileName = autoContent.fileName
        ..fileSize = autoContent.fileSize;
    }
    if (zim is ZIMVideoMessage) {
      (zim as ZIMVideoMessage).videoFirstFrameDownloadUrl = videoContent!.videoFirstFrameDownloadUrl;
    }
  }
}

extension ZIMImageMessageExtend on ZIMImageMessage {
  double get aspectRatio =>
      (originalImageWidth / originalImageHeight) > 0 ? (originalImageWidth / originalImageHeight) : 1.0;
}

extension ZIMUserFullInfoExtend on ZIMUserFullInfo {
  Widget get icon {
    const Widget placeholder = Icon(Icons.person);
    return userAvatarUrl.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: userAvatarUrl,
            fit: BoxFit.cover,
            errorWidget: (context, _, __) => placeholder,
            placeholder: (context, url) => placeholder,
          );
  }
}

extension ZIMString on String {
  ZIMConversationType? toConversationType() {
    try {
      return ZIMConversationType.values.where((element) => element.name == this).first;
    } catch (e) {
      return null;
    }
  }
}

extension ZIMConversationExtend on ZIMConversation {
  ZIMWrapperConversation tokit() {
    return ZIMWrapperConversation()
      ..type = type
      ..id = id
      ..name = name.isEmpty ? 'Chat' : name
      ..avatarUrl = conversationAvatarUrl
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..orderKey = orderKey
      ..disable = false
      ..lastMessage = lastMessage?.tokit();
  }

  String get id => conversationID;

  set id(String value) => conversationID = value;

  String get name => conversationName;

  set name(String value) => conversationName = value;

  String get avatarUrl => conversationAvatarUrl;

  set avatarUrl(String value) => conversationAvatarUrl = value;
}

extension ZIMWrapperConversationExtend on ZIMWrapperConversation {
  ZIMConversation tozim() {
    return ZIMConversation()
      ..type = type
      ..id = id
      ..name = name
      ..avatarUrl = avatarUrl
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..orderKey = orderKey
      ..lastMessage = lastMessage?.zim;
  }

  bool equal(String id, ZIMConversationType type) => (this.id == id) && (this.type == type);

  Widget get icon {
    late Widget placeholder;
    switch (type) {
      case ZIMConversationType.peer:
        return ZIMWrapperAvatar(userID: id);
      case ZIMConversationType.room:
        placeholder = const Icon(Icons.room);
        break;
      case ZIMConversationType.group:
        placeholder = const Icon(Icons.group);
        break;
      case ZIMConversationType.unknown:
        break;
    }

    return avatarUrl.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.cover,
            errorWidget: (context, _, __) => placeholder,
            placeholder: (context, url) => placeholder,
          );
  }

  ZIMWrapperConversation clone() {
    return ZIMWrapperConversation()
      ..type = type
      ..id = id
      ..name = name
      ..avatarUrl = avatarUrl
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..orderKey = orderKey
      ..disable = disable
      ..lastMessage = lastMessage
      ..groupMemberList = groupMemberList;
  }
}

extension ZIMGroupFullInfoExtension on ZIMGroupFullInfo {
  ZIMWrapperConversation toConversation() {
    return baseInfo.toConversation();
  }

  String get id => baseInfo.groupID;

  String get name => baseInfo.groupName;

  String get url => baseInfo.groupAvatarUrl;

  String get notice => groupNotice;

  Map<String, String> get attributes => groupAttributes;
}

extension ZIMGroupExtension on ZIMGroup {
  ZIMWrapperConversation toConversation() {
    return ZIMWrapperConversation()
      ..id = baseInfo?.groupID ?? ''
      ..name = baseInfo?.groupName ?? ''
      ..avatarUrl = baseInfo?.groupAvatarUrl ?? ''
      ..type = ZIMConversationType.group
      ..notificationStatus = (notificationStatus == ZIMGroupMessageNotificationStatus.notify
          ? ZIMConversationNotificationStatus.notify
          : ZIMConversationNotificationStatus.doNotDisturb);
  }

  String get id => baseInfo?.groupID ?? '';

  String get name => baseInfo?.groupName ?? '';

  String get url => baseInfo?.groupAvatarUrl ?? '';
}

extension ZIMGroupInfoExtension on ZIMGroupInfo {
  ZIMWrapperConversation toConversation() {
    return ZIMWrapperConversation()
      ..id = groupID
      ..name = groupName
      ..avatarUrl = groupAvatarUrl
      ..type = ZIMConversationType.group;
  }

  String get id => groupID;

  String get name => groupName;

  String get url => groupAvatarUrl;
}
