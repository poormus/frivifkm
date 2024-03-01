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

class GroupServices {

  final userRef = Configuration.isProduction?FirebaseFirestore.instance.collection('users'):FirebaseFirestore.instance.collection('users_test');
  final groupRef = Configuration.isProduction?FirebaseFirestore.instance.collection('groups'):FirebaseFirestore.instance.collection('groups_test');
  final workTimeRef=Configuration.isProduction?FirebaseFirestore.instance.collection('workTime'):FirebaseFirestore.instance.collection('workTime_test');

  ///gets all the users
  List<CurrentUserData> _currentAppUserFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return CurrentUserData.fromMap(e.data());
    }).toList();
  }




  ///adds a group as well as updates user collection group id list...
  Future addAGroup(String organizationId, String groupName,List<String> uidList,String leaderUid,BuildContext context,String createdBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      String groupId = Uuid().v1().toString();
      Group group=Group(groupId: groupId, organizationId: organizationId, groupName: groupName,
          uidList: uidList,leaderUid: leaderUid,createdBy: createdBy);
      await groupRef.doc(groupId).set(group.toMap());
      //updates user group uid list...
      uidList.forEach((element) async {
        DocumentReference docRef = userRef.doc(element);
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> groupIds=docData['groupIds'] ;
        groupIds.add(groupId);
        userRef.doc(element).update({
          'groupIds':groupIds
        });
      });
      Navigator.pop(context);
      Utils.showToastWithoutContext('Group added'.tr());
    }  catch (e) {
      Utils.showErrorToast();
    }

  }


  ///updates a group info...
  ///also must update group ids in user collection
  /// this function  currently doesn't do anything
  Future updateAGroup(String groupName,List<String> uidList,String groupId,String leaderUid,BuildContext context) async {
    // Group group=Group(groupId: groupId, organizationId: organizationId, groupName: groupName,uidList: uidList);
    // await groupRef.doc(groupId).update(group.toMap());
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      groupRef.doc(groupId).update({
        'uidList':uidList,
        'groupName':groupName,
        'leaderUid':leaderUid
      });
      uidList.forEach((element) async {
        DocumentReference docRef = userRef.doc(element);
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> groupIds=docData['groupIds'] ;
        if(!groupIds.contains(groupId)){
          groupIds.add(groupId);
        }
        userRef.doc(element).update({
          'groupIds':groupIds
        });
      });
      Utils.showToastWithoutContext('Updated'.tr());
      Navigator.pop(context);
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  //gets all the groups according to organization
  Stream<List<Group>> getGroupsForOrganization(String organizationId) {
    return groupRef
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map((event) => event.docs.map((e) => Group.fromMap(e.data())).toList());
  }


  ///deletes a group
  ///currently this function does not update users group list field.
  Future deleteAGroup(String groupId,List<String> uidList) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      groupRef.doc(groupId).delete();
      //removes group id from user user group uid list...
      uidList.forEach((element) async {
        DocumentReference docRef = userRef.doc(element);
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> groupIds=docData['groupIds'] ;
        groupIds.remove(groupId);
        userRef.doc(element).update({
          'groupIds':groupIds
        });
      });
      Utils.showToastWithoutContext('Deleted'.tr());
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  Future getGroupsForVoluntaryWork(String organizationId, MyProvider provider) async {
    //  await groupRef
    //     .where('organizationId', isEqualTo: organizationId)
    //     .snapshots()
    //     .map((event) => event.docs.map((e) => Group.fromMap(e.data())).toList())
    //     .forEach((element) {
    //          provider.setGroupList(element);
    // });

      final groups=await groupRef.where('organizationId', isEqualTo: organizationId).get();
      final list=groups.docs.map((e) => Group.fromMap(e.data())).toList();
      provider.setGroupList(list);
  }

  Future getUsersForOrganization(MyProvider provider,String organizationId)  async{
    // await userRef.
    // where('adminRegistry',arrayContains: {'organizationId':organizationId,'isApproved':true})
    //     .snapshots().map(_currentAppUserFromSnapShot).forEach((element) {
    //   provider.setUserList(element);
    // });
    final users= await userRef.
    where('adminRegistry',arrayContains: {'organizationId':organizationId,'isApproved':true}).get();
    final userList=users.docs.map((e) => CurrentUserData.fromMap(e.data())).toList();
    provider.setUserList(userList);
    // List<CurrentUserDataDb> dbUsers=[];
    // List<UserOrganizationsDb> dbOrgs=[];
    // provider.allUsersOfOrganization.forEach((element) {
    //   final user=CurrentUserDataDb(uid: element.uid, email: element.email, userName: element.userName, userSurname: element.userName, currentOrganizationId: element.currentOrganizationId, userPhone: element.userPhone,
    //       userUrl: element.userUrl, totalPoint: element.totalPoint);
    //   element.userOrganizations.forEach((org) {
    //     final orgDb=UserOrganizationsDb(uid: element.uid, organizationId: org.organizationId, organizationName: org.organizationName, organizationUrl: org.organizationUrl, isApproved: org.isApproved, userRole: org.userRole);
    //         dbOrgs.add(orgDb);
    //   });
    //      dbUsers.add(user);
    // });
    // UserDataBase.instance.addAllUsers(dbUsers,dbOrgs);

  }


  Future saveWorkTime(String groupId, String uid,String organizationId, DateTime workDate, int hourWorked) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      final id=Uuid().v4().toString();
      final ref=Configuration.isProduction?
      FirebaseFirestore.instance.collection('workTime/$uid/times'):
      FirebaseFirestore.instance.collection('workTime_test/$uid/times');
      final workTime=WorkTime(id: id, groupId: groupId, organizationId: organizationId,
          uid: uid,workDate: workDate, hourWorked:hourWorked,isApproved: false);
      ref.doc(id).set(workTime.toMap());
      Utils.showToastWithoutContext('Added'.tr());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Stream<List<WorkTime>> getAllWorkTimes(String uid){
    return Configuration.isProduction?
    FirebaseFirestore.instance.collection('workTime/$uid/times').
    snapshots().map((event) {
      return event.docs.map((e) {
        return WorkTime.fromMap(e.data());
      }).toList();
    }):FirebaseFirestore.instance.collection('workTime_test/$uid/times').
    snapshots().map((event) {
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
      await Configuration.isProduction?
      FirebaseFirestore.instance.collection('workTime/$uid/times').doc(id).delete():
      FirebaseFirestore.instance.collection('workTime_test/$uid/times').doc(id).delete();
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
      await Configuration.isProduction?
      FirebaseFirestore.instance.collection('workTime/$uid/times').doc(id).update({
        'workDate':workDate,
        'hourWorked':workHour,
        'isApproved':false
      }):
      FirebaseFirestore.instance.collection('workTime_test/$uid/times').doc(id).update({
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
    if(Configuration.isProduction){
      final list=provider.getCurrentOrganizationUserList(currentOrganizationId);
      list.forEach((user) async {
        final collectionRef=FirebaseFirestore.instance.collection('workTime/${user.uid}/times');
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await collectionRef.get();
        final list=querySnapshot.docs.map((e) => WorkTime.fromMap(e.data())).toList();
        allWorkTimeOfAnOrganization.putIfAbsent(user.uid, () => list);
        provider.setAllWorkTimeOfAnOrganization(allWorkTimeOfAnOrganization);
      });

    }else{
      final list=provider.getCurrentOrganizationUserList(currentOrganizationId);
      list.forEach((user) async {
        final collectionRef=FirebaseFirestore.instance.collection('workTime_test/${user.uid}/times');
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await collectionRef.get();
        final list=querySnapshot.docs.map((e) => WorkTime.fromMap(e.data())).toList();
        allWorkTimeOfAnOrganization.putIfAbsent(user.uid, () => list);
        provider.setAllWorkTimeOfAnOrganization(allWorkTimeOfAnOrganization);
      });

    }
  }

  Future approveWorkTime(String uid, List<String> workTimesId,int totalPoint,
      MyProvider provider,List<WorkTime>? userWorkTimes) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      final collectionRef=Configuration.isProduction?FirebaseFirestore.instance.collection('workTime/$uid/times'):
      FirebaseFirestore.instance.collection('workTime_test/$uid/times');
      workTimesId.forEach((element) {
        collectionRef.doc(element).update({'isApproved':true});
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
            await Configuration.isProduction?
            FirebaseFirestore.instance.collection('workTime/${ev.uid}/times').doc(element.id).set({
              'isApproved':false
            },SetOptions(merge: true)):
            FirebaseFirestore.instance.collection('workTime_test/${ev.uid}/times').doc(element.id).set({
            'isApproved':false
            },SetOptions(merge: true));
          });
        });
      });
    });
  }


}
