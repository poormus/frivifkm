import '../shared/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Poll{
  String pollId;
  String pollQuestion;
  String organizationId;
  String createdById;
  List<String> toWHo;
  DateTime createdAt;
  DateTime expiresAt;
  List<PollItem> pollItems;
  List<String> seenBy;

  Poll({
    required this.pollId,
    required this.pollQuestion,
    required this.organizationId,
    required this.createdById,
    required this.toWHo,
    required this.createdAt,
    required this.expiresAt,
    required this.pollItems,
    required this.seenBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'pollId':this.pollId,
      'pollQuestion': this.pollQuestion,
      'organizationId': this.organizationId,
      'createdById': this.createdById,
      'toWHo': this.toWHo,
      'createdAt': this.createdAt,
      'expiresAt':this.expiresAt,
      'pollItems': this.pollItems.map((e) => e.toMap()).toList(),
      'seenBy': this.seenBy,
    };
  }

  factory Poll.fromMap(Map<String, dynamic> map) {
    final List<PollItem> pollItems=[];
    List pollItemFromMap=map['pollItems'];
    pollItemFromMap.forEach((element) {
      PollItem pollItem=PollItem.fromMap(element as Map<String, dynamic>);
      pollItems.add(pollItem);
    });

    // DateTime currentPhoneDate = DateTime.now().add(Duration(hours: 10)); //DateTime
    // Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);

    return Poll(
      pollId: map['pollId'],
      pollQuestion: map['pollQuestion'] as String,
      organizationId: map['organizationId'] as String,
      createdById: map['createdById'] as String,
      toWHo:  List.castFrom(map['toWHo']),
      createdAt: Utils.toDateTime(map['createdAt']),
      expiresAt: Utils.toDateTime(map['expiresAt']),
      pollItems: pollItems,
      seenBy:  List.castFrom(map['seenBy']),
    );
  }
}

class PollItem{
  String item;
  List<String> answeredUserId;

  PollItem({
    required this.item,
    required this.answeredUserId,
  });

  Map<String, dynamic> toMap() {
    return {
      'item': this.item,
      'answeredUserId': this.answeredUserId,
    };
  }

  factory PollItem.fromMap(Map<String, dynamic> map) {
    return PollItem(
      item: map['item'] as String,
      answeredUserId:  List.castFrom(map['answeredUserId']),
    );
  }
}