import 'dart:typed_data';

import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';

class MyProvider extends ChangeNotifier {



  List<Organization> organizations = [];



  void setOrganizations(List<Organization> orgs) {
    organizations = orgs;
    notifyListeners();
  }

  void addOrganization(Organization organization) {
    organizations.add(organization);
    notifyListeners();
  }

  void removeOrganization(Organization organization) {
    organizations.remove(organization);
    notifyListeners();
  }

  void clearList() {
    organizations.clear();
    notifyListeners();
  }

  List<Organization> selectedOrganizations = [];
  List<String> alreadyJoinedOrganizations = [];

  void setAlreadyJoinedUserOrganizations(List<String> organizations) {
    alreadyJoinedOrganizations = organizations;
  }

  void setSelectedOrganizations(List<Organization> organizations) {
    selectedOrganizations = organizations;
  }

  void addToSelectedOrganization(Organization organization) {
    selectedOrganizations.add(organization);
    notifyListeners();
  }

  void removeFromSelectedOrganization(Organization organization) {
    selectedOrganizations.remove(organization);
    notifyListeners();
  }

  List<CurrentUserData> allUsersOfOrganization = [];
  List<CurrentUserData> allUsersOfGroup = [];


  ///we need to limit if organization changes its package from premium to freemium
  /// in case user number exceeds its determined value..
  void setUserList(List<CurrentUserData> data) {
    allUsersOfOrganization = data;
  }

  void addCurrentUserIfAbsent(CurrentUserData currentUserData){
    bool isAbsent=false;
    for(var i=0; i<allUsersOfOrganization.length; i++){
      if(allUsersOfOrganization[i].uid==currentUserData.uid){
        isAbsent=true;
        break;
      }
    }
    if(!isAbsent){
      allUsersOfOrganization.add(currentUserData);
    }

  }
  List<String>  getOtherNames(String myName){
    List<String> otherNames=[];
    allUsersOfOrganization.forEach((element) {
      String name=Utils.getUserName(element.userName, element.userSurname);
      otherNames.add(name);
    });

    return otherNames;
  }

  void setUserListForGroup(List<CurrentUserData> data) {
    allUsersOfGroup = data;
  }

  void setUserListForGroupsToNull(){
    allUsersOfGroup=[];
  }

  /// make sure to create another version of this function for
  /// organization update so that users who are not yet approved
  /// will also get org_id and picture updated...
  List<CurrentUserData> getCurrentOrganizationUserList(String orgId) {
    List<CurrentUserData> list = [];
    allUsersOfOrganization.forEach((userData) {
      userData.userOrganizations.forEach((element) {
        if (element.organizationId == orgId && element.isApproved == true) {
          list.add(userData);
        }
      });
    });
    return list;
  }

  CurrentUserData getUserById(String uid) {
    CurrentUserData currentUserData=Constants.CURRENT_USER_HOLDER;

    for (var i = 0; i < allUsersOfOrganization.length; i++) {
      if (allUsersOfOrganization[i].uid == uid) {
        currentUserData = allUsersOfOrganization[i];
        break;
      } else {
        currentUserData = Constants.CURRENT_USER_HOLDER;
      }
    }
    //currentUserData=allUsersOfOrganization.where((element) => element.uid==uid).single;
    return currentUserData;
  }

  void clearUserList() {
    allUsersOfOrganization.clear();
    notifyListeners();
  }

  List<Group> allGroupsOfAnOrganization = [];

  void setGroupList(List<Group> data) {
    allGroupsOfAnOrganization = data;
  }

  String getGroupNameById(String id) {
    String groupName = '';
    for (var i = 0; i < allGroupsOfAnOrganization.length; i++) {
      if (allGroupsOfAnOrganization[i].groupId == id) {
        groupName = allGroupsOfAnOrganization[i].groupName;
        break;
      }
    }
    return groupName;
  }

  List<Organization> organizationsForValidation = [];

  void setOrganizationForValidation(List<Organization> orgs) {
    organizationsForValidation = orgs;
  }

  List<MyAppointment> appointmentsOfARoom = [];

  void setAppointmentsOfARoom(List<MyAppointment> appointments) {
    appointmentsOfARoom = appointments;
  }



  Map<String, List<WorkTime>> allWorkTimeOfAnOrganization = {};
  List<String> workTimesId=[];
  int totalPoint=0;

  void setAllWorkTimeOfAnOrganization(Map<String, List<WorkTime>> workTimes) {
    allWorkTimeOfAnOrganization = workTimes;
  }

  void addWorkTimeId(WorkTime workTime){
    workTimesId.add(workTime.id);
    totalPoint+=workTime.hourWorked;

  }
  void removeWorkTimeId(WorkTime workTime){
    workTimesId.remove(workTime.id);
    totalPoint-=workTime.hourWorked;

  }


  void setWorkTimesIdToZero(){
    workTimesId=[];
    totalPoint=0;
  }
  void selectAllWorkTimes(List<WorkTime> times){
    times.forEach((element) {
      if(!element.isApproved && !isWorkTimeIdInTheList(element.id)){
        workTimesId.add(element.id);
        totalPoint+=element.hourWorked;
      }
    });
  }

  bool isWorkTimeIdInTheList(String id){
    bool isInTheList=false;
    if(workTimesId.contains(id)){
      isInTheList=true;
    }
    return isInTheList;
  }

  void updateApprovedWorkTimes(String uid,List<WorkTime>? userWorkTimes){
    userWorkTimes?.forEach((element) {
      print(element.isApproved);
    });

    List<WorkTime> toBeAdded=[];
    List<WorkTime> toBeRemoved=[];

    userWorkTimes?.forEach((element) {
      if(workTimesId.contains(element.id)){
        final workTime=WorkTime(id: element.id, groupId: element.groupId, organizationId: element.organizationId,
            uid: element.uid,workDate: element.workDate, hourWorked: element.hourWorked, isApproved: true);
        toBeRemoved.add(element);
        toBeAdded.add(workTime);
      }
    });



    print(toBeRemoved.length);
    print(toBeAdded.length);
    userWorkTimes?.removeWhere((element) => toBeRemoved.contains(element));

    toBeAdded.forEach((element) {
      userWorkTimes?.add(element);
    });

    userWorkTimes?.forEach((element) {
      print(element.isApproved);
    });

    allWorkTimeOfAnOrganization.update(uid, (val) => userWorkTimes!);
  }

  bool hasUserClickedAttend=false;

  Map<String,Uint8List> list={};
  void setByteList(Map<String,Uint8List> byteList) {
    list=byteList;
  }

  String selectedCity='';
  List<String> selectedPrefs=[];
  Coordinates coordinates=Coordinates(lat: 0.0, long: 0.0);

}
