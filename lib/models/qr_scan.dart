
import 'package:firebase_calendar/shared/utils.dart';

class QrScan{

  final String id;
  final String organizationId;
  final String uid;
  final DateTime createdAt;
  final String userName;
  final String logType;
  const QrScan( {
    required this.id,
    required this.organizationId,
    required this.uid,
    required this.createdAt,
    required this.userName,
    required this.logType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'organizationId': this.organizationId,
      'uid': this.uid,
      'createdAt': this.createdAt,
      'userName':this.userName,
      'logType':this.logType
    };
  }

  factory QrScan.fromMap(Map<String, dynamic> map) {
    return QrScan(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      uid: map['uid'] as String,
      createdAt: Utils.toDateTime(map['createdAt']),
      userName: map['userName'],
      logType: map['logType']
    );
  }
}