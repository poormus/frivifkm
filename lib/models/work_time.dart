import 'package:firebase_calendar/shared/utils.dart';

class WorkTime{
  final String id;
  final String groupId;
  final String organizationId;
  final String uid;
  final DateTime workDate;
  final int hourWorked;
  final bool isApproved;

  const WorkTime({
    required this.id,
    required this.groupId,
    required this.organizationId,
    required this.uid,
    required this.workDate,
    required this.hourWorked,
    required this.isApproved
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'groupId': this.groupId,
      'organizationId':this.organizationId,
      'uid':this.uid,
      'workDate': this.workDate,
      'hourWorked': this.hourWorked,
      'isApproved':this.isApproved
    };
  }
  factory WorkTime.fromMap(Map<String, dynamic> map) {
    return WorkTime(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      organizationId: map['organizationId'],
      uid:map['uid'],
      workDate:  Utils.toDateTime(map['workDate']),
      hourWorked: map['hourWorked'] as int,
      isApproved: map['isApproved']
    );
  }
}