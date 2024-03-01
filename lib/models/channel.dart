import 'package:firebase_calendar/shared/utils.dart';

class Channel{

  final String organizationId;
  final String channelId;
  final String channelName;
  final List<String> membersIds;
  final DateTime createdAt;
  final List<RemovedUser>? removedUsers;

  const Channel( {
    required this.organizationId,
    required this.channelId,
    required this.channelName,
    required this.membersIds,
    required this.createdAt,
    this.removedUsers,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationId':this.organizationId,
      'channelId': this.channelId,
      'channelName': this.channelName,
      'membersIds': this.membersIds,
      'createdAt': Utils.fromDateTimeToJson(createdAt),
      'removedUsers':this.removedUsers?.map((e) => e.toMap()).toList()
    };
  }

  factory Channel.fromMap(Map<String, dynamic> map) {
    List<RemovedUser>? removedUsers=[];
    List? removedUsersFromMap=map['removedUsers'];
    removedUsersFromMap?.forEach((element) {
      final removedUser=RemovedUser.fromMap(element as Map<String, dynamic>);
      removedUsers.add(removedUser);
    });
    return Channel(
      organizationId: map['organizationId'],
      channelId: map['channelId'] as String,
      channelName: map['channelName'] as String,
      membersIds: List.castFrom(map['membersIds']),
      createdAt:  Utils.toDateTime(map['createdAt']),
      removedUsers: removedUsers
    );
  }
}


class RemovedUser{
  final String uid;
  final DateTime removedAt;

  const RemovedUser({
    required this.uid,
    required this.removedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'removedAt': this.removedAt,
    };
  }

  factory RemovedUser.fromMap(Map<String, dynamic> map) {
    return RemovedUser(
      uid: map['uid'] as String,
      removedAt: Utils.toDateTime(map['removedAt'])
    );
  }
}