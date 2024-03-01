
import 'package:firebase_calendar/shared/utils.dart';

class Announcement{

  final String announcementId;
  final String announcementTitle;
  final String announcement;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String organizationId;
  final String createdBy;
  final int priority;
  final List<String> toWho;
  final List<String> seenBy;
  final String documentUrl;
  final String? creatorUid;
  const Announcement({
    required this.announcementId,
    required this.announcementTitle,
    required this.announcement,
    required this.createdAt,
    required this.updatedAt,
    required this.organizationId,
    required this.createdBy,
    required this.priority,
    required this.toWho,
    required this.seenBy,
    required this.documentUrl,
    this.creatorUid
  });

  Map<String, dynamic> toMap() {
    return {
      'announcementId': this.announcementId,
      'announcementTitle':this.announcementTitle,
      'announcement': this.announcement,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
      'organizationId': this.organizationId,
      'createdBy': this.createdBy,
      'priority': this.priority,
      'toWho':this.toWho,
      'seenBy':this.seenBy,
      'documentUrl':this.documentUrl,
      'creatorUid':this.creatorUid
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      announcementId: map['announcementId'] as String,
      announcementTitle:  map['announcementTitle'] as String,
      announcement: map['announcement'] as String,
      createdAt: Utils.toDateTime(map['createdAt']),
      updatedAt: Utils.toDateTime(map['updatedAt']),
      organizationId: map['organizationId'] as String,
      createdBy: map['createdBy'] as String,
      priority: map['priority'] as int,
      toWho: List.castFrom(map['toWho']),
      seenBy: List.castFrom(map['seenBy']),
      documentUrl: map['documentUrl'],
      creatorUid: map['creatorUid']==null?'':map['creatorUid']
    );
  }
}