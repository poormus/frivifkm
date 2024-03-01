class Group{
  final String groupId;
  final String organizationId;
  final String groupName;
  final List<String> uidList;
  final String leaderUid;
  final String createdBy;

  const Group({
    required this.groupId,
    required this.organizationId,
    required this.groupName,
    required this.uidList,
    required this.leaderUid,
    required this.createdBy
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': this.groupId,
      'organizationId': this.organizationId,
      'groupName': this.groupName,
      'uidList': this.uidList,
      'leaderUid':this.leaderUid,
      'createdBy':this.createdBy
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      groupId: map['groupId'] as String,
      organizationId: map['organizationId'] as String,
      groupName: map['groupName'] as String,
      uidList: List.castFrom(map['uidList']),
      leaderUid: map['leaderUid'],
      createdBy: map['createdBy']==null?'':map['createdBy']
    );
  }
}