import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/screens/admin_panel/approve_work_time.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../anim/slide_in_right.dart';

class ViewUserWorkTimesDialog extends StatelessWidget {
  final List<WorkTime>? workTimes;
  final CurrentUserData currentUserData;

  const ViewUserWorkTimesDialog(
      {Key? key, required this.workTimes, required this.currentUserData})
      : super(key: key);

  List<WorkTime> getWorkTimesOfAGroup(
      String groupId, List<WorkTime> workTimes) {
    List<WorkTime> myWorkTimes = [];
    workTimes.forEach((element) {
      if (element.groupId == groupId) {
        myWorkTimes.add(element);
      }
    });
    return myWorkTimes;
  }

  int getApprovedWorkTime(String groupId){
    int approvedTime=0;
    workTimes?.forEach((element) {
      if(element.groupId==groupId && element.isApproved){
        approvedTime+=element.hourWorked;
      }
    });
    return approvedTime;
  }


  List<Group> getMyGroups(MyProvider provider) {
    final allGroupsOfOrganization = provider.allGroupsOfAnOrganization;
    List<Group> myGroups = [];
    allGroupsOfOrganization.forEach((element) {
      if (element.uidList.contains(currentUserData.uid)) {
        myGroups.add(element);
      }
    });
    return myGroups;
  }

  int getWorkHoursOfAGroup(String groupId, List<WorkTime> workTimes) {
    int totalWorkHours = 0;
    final totalWorkHoursOfAGroup = getWorkTimesOfAGroup(groupId, workTimes);
    totalWorkHoursOfAGroup.forEach((element) {
      totalWorkHours += element.hourWorked;
    });
    return totalWorkHours;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    final myGroups = getMyGroups(provider);
    final userName = Utils.getUserName(
        currentUserData.userName, currentUserData.userSurname);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      backgroundColor: Constants.BACKGROUND_COLOR,
      child: Container(
          height: size.height * 0.4,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          imageUrl: currentUserData.userUrl,
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                        ),
                      ),
                      title: Text(userName),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: myGroups.length,
                          itemBuilder: (context, index) {
                            final workTimeOfAGroup = getWorkTimesOfAGroup(
                                myGroups[index].groupId, workTimes!);
                            final workHoursOfAGroup = getWorkHoursOfAGroup(
                                myGroups[index].groupId, workTimeOfAGroup);

                            return buildListTile(context, workTimeOfAGroup,
                                myGroups[index], workHoursOfAGroup);
                          }),
                    ),
                  ],
                ),
              ),
              Align(
                // These values are based on trial & error method
                alignment: Alignment(1.1, -1.1),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Constants.CANCEL_COLOR,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget buildListTile(BuildContext context, List<WorkTime> workTimeOfAGroup,
      Group group, int workHoursOfAGroup) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //     context,
          //     SlideInRight(ApproveWorkTimeScreen(
          //         workTimes: workTimeOfAGroup,
          //         uid: currentUserData.uid,
          //         groupName: group.groupName,
          //         currentTotalPoint: currentUserData.totalPoint)));
        },
        child: Card(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
                color: Constants.CONTAINER_COLOR,
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    child: Text(
                      group.groupName,
                      style: appTextStyle.copyWith(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  Row(
                    children: [
                      // Container(
                      //   height: 40,
                      //   width: 50,
                      //   decoration: BoxDecoration(
                      //       color: Constants.BUTTON_COLOR,
                      //       borderRadius: BorderRadius.circular(8)),
                      //   child: Center(
                      //     child: Text(
                      //       '${getApprovedWorkTime(group.groupId)}' + 'h'.tr(),
                      //       style: appTextStyle.copyWith(fontSize: 20,color: Colors.white),
                      //     ),
                      //   )),
                      SizedBox(width: 4),
                      Container(
                          height: 40,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Constants.BACKGROUND_COLOR,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Text(
                              '${workHoursOfAGroup}' + 'h'.tr(),
                              style: appTextStyle.copyWith(fontSize: 20),
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
