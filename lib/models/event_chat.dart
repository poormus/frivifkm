import 'package:firebase_calendar/shared/utils.dart';

class EventChat{


 final String messageId;
 final String eventId;
 final String uid;
 final String message;
 final DateTime createdAt;

 const EventChat({
    required this.messageId,
    required this.eventId,
    required this.uid,
    required this.message,
    required this.createdAt,
  });

 Map<String, dynamic> toMap() {
    return {
      'messageId': this.messageId,
      'eventId': this.eventId,
      'uid': this.uid,
      'message': this.message,
      'createdAt': Utils.fromDateTimeToJson(this.createdAt)
    };
  }

  factory EventChat.fromMap(Map<String, dynamic> map) {
    return EventChat(
      messageId: map['messageId'] as String,
      eventId: map['eventId'] as String,
      uid: map['uid'] as String,
      message: map['message'] as String,
      createdAt: Utils.toDateTime(map['createdAt']),
    );
  }
}