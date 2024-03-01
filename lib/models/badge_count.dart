class BadgeCount{
  final String uid;
  final int announcementCount;
  final int messageCount;
  final int groupChatCount;
  final int surveyCount;
  final int pollCount;

  const BadgeCount({
    required this.uid,
    required this.announcementCount,
    required this.messageCount,
    required this.groupChatCount,
    required this.surveyCount,
    required this.pollCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'announcementCount': this.announcementCount,
      'messageCount': this.messageCount,
      'groupChatCount': this.groupChatCount,
      'surveyCount': this.surveyCount,
      'pollCount': this.pollCount,
    };
  }

  factory BadgeCount.fromMap(Map<String, dynamic> map) {
    return BadgeCount(
      uid: map['uid'] as String,
      announcementCount: map['announcementCount'] as int,
      messageCount: map['messageCount'] as int,
      groupChatCount: map['groupChatCount'] as int,
      surveyCount: map['surveyCount'] as int,
      pollCount: map['pollCount'] as int,
    );
  }
}