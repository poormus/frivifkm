import 'package:firebase_calendar/shared/utils.dart';

class StartedGroupChat{
  final String organizationId;
  final String channelId;
  final String channelName;
  final String lastMessage;
  final String senderId;
  final String senderName;
  final List<String> membersIds;
  final int unseenMessageCount;
  final DateTime createdAt;

  const StartedGroupChat({
    required this.organizationId,
    required this.channelId,
    required this.channelName,
    required this.lastMessage,
    required this.senderId,
    required this.senderName,
    required this.membersIds,
    required this.unseenMessageCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationId': this.organizationId,
      'channelId': this.channelId,
      'channelName':this.channelName,
      'lastMessage': this.lastMessage,
      'senderId': this.senderId,
      'senderName': this.senderName,
      'membersIds':this.membersIds,
      'unseenMessageCount': this.unseenMessageCount,
      'createdAt': Utils.fromDateTimeToJson(this.createdAt),
    };
  }

  factory StartedGroupChat.fromMap(Map<String, dynamic> map) {
    return StartedGroupChat(
      organizationId: map['organizationId'] as String,
      channelId: map['channelId'] as String,
      channelName: map['channelName'] as String,
      lastMessage: map['lastMessage'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      membersIds: List.castFrom(map['membersIds']),
      unseenMessageCount: map['unseenMessageCount'] as int,
      createdAt: Utils.toDateTime(map['createdAt']),
    );
  }
}