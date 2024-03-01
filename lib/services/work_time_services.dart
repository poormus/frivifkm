import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/db/user_organizations_db.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';

import '../db/db_current_user_data.dart';
import '../db/user_database.dart';

class WorkTimeServices {

  final String organizationId;

  WorkTimeServices({
    required this.organizationId,
  });

  final userRef = Configuration.isProduction?FirebaseFirestore.instance.collection('users'):FirebaseFirestore.instance.collection('users_test');
   late CollectionReference<Map<String, dynamic>> workTimeRef;

  init(){
    workTimeRef=Configuration.isProduction?FirebaseFirestore.instance.collection('workTime/${organizationId}/workTimes')
        :FirebaseFirestore.instance.collection('workTime_test/${organizationId}/workTimes');
  }

  Future saveWorkTime(String groupId, String uid,String organizationId, DateTime workDate, int hourWorked) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      final id=Uuid().v4().toString();
      final workTime=WorkTime(id: id, groupId: groupId, organizationId: organizationId,
          uid: uid,workDate: workDate, hourWorked:hourWorked,isApproved: false);
      workTimeRef.doc(id).set(workTime.toMap());
      Utils.showToastWithoutContext('Added'.tr());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Stream<List<WorkTime>> getAllWorkTimes(String uid){
    return
    workTimeRef.where('organizationId',isEqualTo: organizationId).where('uid',isEqualTo:uid).snapshots().map((event) {
      return event.docs.map((e) {
        return WorkTime.fromMap(e.data());
      }).toList();
    });

  }

  Future deleteWorkTime(String id,String uid) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      await workTimeRef.doc(id).delete();
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  Future updateWorkTime(String id, String uid,BuildContext context, DateTime workDate, int workHour) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      await
      workTimeRef.doc(id).update({
        'workDate':workDate,
        'hourWorked':workHour,
        'isApproved':false
      });
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  Future getWorkTimeForAdmin(String currentOrganizationId,MyProvider provider) async{
    Map<String,List<WorkTime>> allWorkTimeOfAnOrganization={};
      final list=provider.getCurrentOrganizationUserList(currentOrganizationId);
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await workTimeRef.get();
      list.forEach((user) async {
        List<WorkTime> userWorkTime=[];
        final list=querySnapshot.docs.map((e) => WorkTime.fromMap(e.data())).toList();
        list.forEach((element) {
          if(element.uid==user.uid){
            userWorkTime.add(element);
          }
        });
        allWorkTimeOfAnOrganization.putIfAbsent(user.uid, () => userWorkTime);
      });
      provider.setAllWorkTimeOfAnOrganization(allWorkTimeOfAnOrganization);
  }

  Future approveWorkTime(String uid, List<String> workTimesId,int totalPoint,
      MyProvider provider,List<WorkTime>? userWorkTimes) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {

      workTimesId.forEach((element) {
        workTimeRef.doc(element).update({'isApproved':true});
      });
      DocumentReference docRef = userRef.doc(uid);
      docRef.update({'totalPoint':totalPoint});
      provider.updateApprovedWorkTimes(uid,userWorkTimes);
    }  catch (e) {
      Utils.showErrorToast();
    }

  }


  ///adds work time field
  ///not used
  updateAField() async {
    userRef.snapshots().map(
            (event) => event.docs.map((e) => CurrentUserData.fromMap(e.data())).toList()).forEach((element) {
      element.forEach((ev) {
        getAllWorkTimes(ev.uid).forEach((element) {
          element.forEach((element) async {
            await
            FirebaseFirestore.instance.collection('workTime/${ev.uid}/times').doc(element.id).set({
              'uid':ev.uid
            },SetOptions(merge: true));
          });
        });
      });
    });
  }

  // getAhmetWorkTimes() async{
  //   final times=await FirebaseFirestore.instance.collection('workTime/0lNrKMMNE0gszEbeoAATpJmdiXH3/times').get();
  //   final workTimes=times.docs.map((e) => WorkTime.fromMap(e.data())).toList();
  //   print(workTimes);
  //   workTimes.forEach((element) {
  //     workTimeRef.doc(element.id).set(element.toMap());
  //   });
  // }

}
