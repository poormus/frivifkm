class CreatedChats{

  final String lastMessage;
  final String chattedUserName;
  final String? chattedUserUrl;
  final String chattedUserUid;
  final String roomId;
  final int unseenMessageCount;
  final String organizationId;

  const CreatedChats({

    required this.lastMessage,
    required this.chattedUserName,
    this.chattedUserUrl,
    required this.chattedUserUid,
    required this.roomId,
    required this.unseenMessageCount,
    required this.organizationId,
  });

  Map<String, dynamic> toMap() {
    return {

      'lastMessage': this.lastMessage,
      'chattedUserName': this.chattedUserName,
      'chattedUserUrl': this.chattedUserUrl,
      'chattedUserUid':this.chattedUserUid,
      'roomId': this.roomId,
      'unseenMessageCount': this.unseenMessageCount,
      'organizationId': this.organizationId,
    };
  }

  factory CreatedChats.fromMap(Map<String, dynamic> map) {
    return CreatedChats(
      lastMessage: map['lastMessage'] as String,
      chattedUserName: map['chattedUserName'] as String,
      chattedUserUrl: map['chattedUserUrl'] as String,
      chattedUserUid: map['chattedUserUid'] as String,
      roomId: map['roomId'] as String,
      unseenMessageCount: map['unseenMessageCount'] as int,
      organizationId: map['organizationId'] as String,
    );
  }
}