import 'dart:ui';

import 'package:firebase_calendar/shared/utils.dart';

class MyAppointment {
  final String userId;
  final String appointmentId;
  final String roomId;
  final String organizationId;
  final String roomName;
  final DateTime startTime;
  final DateTime endTime;
  final String subject;
  final Color color;
  final String? note;
  final bool isConfirmed;
  //new fields
  final String userName;
  final bool isActive;

  const MyAppointment({
    required this.userId,
    required this.appointmentId,
    required this.roomId,
    required this.organizationId,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.color,
    this.note,
    this.isConfirmed=false,
    this.isActive=false,
    required this.userName
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': this.userId,
      'appointmentId': this.appointmentId,
      'roomId': this.roomId,
      'organizationId': this.organizationId,
      'roomName':this.roomName,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'subject': this.subject,
      'color': this.color,
      'note': this.note,
      'isConfirmed': this.isConfirmed,
    };
  }

  factory MyAppointment.fromMap(Map<String, dynamic> map) {
    return MyAppointment(
      userId: map['userId'] as String,
      appointmentId: map['appointmentId'] as String,
      roomId: map['roomId'] as String,
      organizationId: map['organizationId'] as String,
      roomName: map['roomName'],
      startTime: Utils.toDateTime(map['startTime']),
      endTime: Utils.toDateTime(map['endTime']),
      subject: map['subject'] as String,
      color: Color(int.parse(map['color'])),
      note: map['note'] as String,
      isConfirmed: map['isConfirmed'] as bool,
      isActive: map['isActive'] as bool,
      userName: map['userName'] as String,
    );
  }
}
