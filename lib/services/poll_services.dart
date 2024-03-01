import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/models/poll.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

import '../config/key_config.dart';
import '../shared/utils.dart';

class PollServices{
  final String organizationId;

  late CollectionReference<Map<String, dynamic>> pollRef;
   late CountService countService;

   PollServices({
    required this.organizationId,
  });

  init(){
    pollRef = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('poll/${organizationId}/polls')
        : FirebaseFirestore.instance.collection('poll_test/${organizationId}/polls');

    countService=CountService(organizationId: organizationId);
    countService.init();
  }

  bool validateSavePoll(BuildContext context,String pollQuestion,List<String> toWho,List<PollItem> pollItems ){
    if(pollQuestion.trim().isEmpty){
      Utils.showSnackBar(context, 'Add poll question'.tr());
      return false;
    }else if(toWho.isEmpty){
      Utils.showSnackBar(context, 'Select target group'.tr());
      return false;
    }else if(pollItems.isEmpty){
      Utils.showSnackBar(context, 'Add at least one poll item'.tr());
      return false;
    }else return true;
  }


  Future savePoll(String pollQuestion,String createdById,List<String> toWho,
      List<PollItem> pollItems, List<String> seenBy,DateTime expireDate,MyProvider provider
      ) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    String poolId = Uuid().v4().toString();
    final Poll poll=Poll(pollId: poolId, pollQuestion: pollQuestion,
        organizationId: organizationId, createdById: createdById, toWHo: toWho,
        createdAt: DateTime.now(), expiresAt: expireDate,pollItems: pollItems, seenBy: seenBy);
    pollRef.doc(poolId).set(poll.toMap());
    countService.updatePollCountOnCreatePoll(provider, toWho);
  }


  deletePoll(String pollId,MyProvider provider,List<String> toWho,List<String> seenBy)async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    pollRef.doc(pollId).delete();
    countService.updatePollCountOnDeletePoll(provider, toWho, seenBy);
  }


  Stream<List<Poll>> getPolls(){
    return pollRef.snapshots().map((poll) => poll.docs.map((e) => Poll.fromMap(e.data())).toList());
  }

  Stream<Poll> getSinglePoll(String pollId) {
    return pollRef.doc(pollId).snapshots().map((poll) => Poll.fromMap(poll.data()!));
  }

  ///updates poll object's pollItems list...
  updatePollForVote(String pollId, List<PollItem> pollItems){
    List<Map<String,dynamic>> pollItemsMap=[];

    pollItems.forEach((element) {
      final newItem=PollItem(item: element.item, answeredUserId: element.answeredUserId).toMap();
      pollItemsMap.add(newItem);
    });

    pollRef.doc(pollId).update({
      'pollItems':pollItemsMap
    });
  }

  ///updates pool seen by data so that it will not show on the main list;
  void updateSeenBy(Poll poll, String uid) {
    final seenBy=poll.seenBy;
    seenBy.add(uid);
    pollRef.doc(poll.pollId).update({'seenBy':seenBy});
    countService.updateAnnouncementCountOnSeenByUser(uid, ItemType.POLL);
  }

  void updatePoll(String pollId, String pollQuestion, String uid,
      List<String> toWho, List<PollItem> pollItems,DateTime expiresAt,List<String> seenBy,MyProvider provider) {

    List<Map<String,dynamic>> pollItemsMap=[];
    pollItems.forEach((element) {
      final newItem=PollItem(item: element.item, answeredUserId: element.answeredUserId).toMap();
      pollItemsMap.add(newItem);
    });
    pollRef.doc(pollId).update({
      'pollQuestion':pollQuestion,
      'toWHo':toWho,
      'pollItems':pollItemsMap,
      'expiresAt':expiresAt,
      'seenBy':[]
    });
    countService.updatePollCountOnUpdatePoll(provider, toWho, seenBy);
  }

}