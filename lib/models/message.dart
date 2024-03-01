
import '../shared/utils.dart';

class Message {
  final String messageId;
  final String idUser;
  final String receiverId;
  final String senderId;
  final String username;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String senderOrgId;
  const Message({
    required this.messageId,
    required this.idUser,
    required this.receiverId,
    required this.senderId,
    required this.username,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.senderOrgId
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': this.messageId,
      'idUser': this.idUser,
      'receiverId':this.receiverId,
      'senderId':this.senderId,
      'username': this.username,
      'message': this.message,
      'createdAt': Utils.fromDateTimeToJson(createdAt),
      'isRead':this.isRead,
      'senderOrgId':this.senderOrgId
    };
  }

  factory Message.fromMap(Map<String, dynamic>? map) {
    return Message(
      messageId: map!['messageId'] as String,
      idUser: map['idUser'] as String,
      receiverId: map['receiverId'] as String,
      senderId: map['senderId'] as String,
      username: map['username'] as String,
      message: map['message'] as String,
      createdAt: Utils.toDateTime(map['createdAt']),
      isRead: map['isRead'] as bool,
      senderOrgId: map['senderOrgId']
    );
  }


}