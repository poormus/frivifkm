
import 'package:firebase_calendar/shared/utils.dart';

class GroupMessage{

 final String messageId;
 final String message;
 final String senderId;
 final String senderName;
 final DateTime createdAt;
 final bool isRead;
 final String messageType;
 final String messageDescription;
 final String repliedMessage;


 const GroupMessage( {
    required this.messageId,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.isRead,
    required this.createdAt,
    required this.messageType,
    required this.messageDescription,
   required this.repliedMessage,
  });

 Map<String, dynamic> toMap() {
    return {
      'messageId': this.messageId,
      'message': this.message,
      'senderId': this.senderId,
      'senderName': this.senderName,
      'isRead':this.isRead,
      'createdAt': Utils.fromDateTimeToJson(this.createdAt),
      'messageType': this.messageType,
      'messageDescription':this.messageDescription,
      'repliedMessage':this.repliedMessage
    };
  }

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      repliedMessage: map['repliedMessage'],
      messageId: map['messageId'] as String,
      message: map['message'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      isRead: map['isRead'],
      createdAt:  Utils.toDateTime(map['createdAt']),
      messageType: map['messageType'] as String,
      messageDescription: map['messageDescription'],
    );
  }
}