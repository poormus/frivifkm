import 'package:firebase_calendar/shared/utils.dart';

class Document{
  final String documentId;
  final String organizationId;
  final String documentUrl;
  final String documentName;
  final DateTime createdAt;
  final String createdByUid;

  const Document({
    required this.documentId,
    required this.organizationId,
    required this.documentUrl,
    required this.documentName,
    required this.createdAt,
    required this.createdByUid
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': this.documentId,
      'organizationId': this.organizationId,
      'documentUrl': this.documentUrl,
      'documentName':this.documentName,
      'createdAt': this.createdAt,
      'createdByUid':this.createdByUid
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      documentId: map['documentId'] as String,
      organizationId: map['organizationId'] as String,
      documentUrl: map['documentUrl'] as String,
      documentName: map['documentName'],
      createdAt:  Utils.toDateTime(map['createdAt']),
      createdByUid: map['createdByUid']==null ? '' : map['createdByUid']
    );
  }
}