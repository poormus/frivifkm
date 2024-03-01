import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/dialog/add_work_time_dialog.dart';
import 'package:firebase_calendar/helper/create_pdf.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../services/work_time_services.dart';

class AddWorkTimeScreen extends StatefulWidget {
  final CurrentUserData currentUserData;

  AddWorkTimeScreen({Key? key, required this.currentUserData})
      : super(key: key);

  @override
  State<AddWorkTimeScreen> createState() => _AddWorkTimeScreenState();
}

class _AddWorkTimeScreenState extends State<AddWorkTimeScreen> {
  GroupServices groupServices = GroupServices();
  late WorkTimeServices workTimeService;
  late CreatePdfForUser createPdfForUser;
  String sortString = 'This year';
  int currentClickIndex = 1;

  late Stream<List<WorkTime>> userWorkTimes;

  @override
  void initState() {
    workTimeService = WorkTimeServices(
        organizationId: widget.currentUserData.currentOrganizationId);
    workTimeService.init();
    createPdfForUser =
        CreatePdfForUser(currentUserData: widget.currentUserData);
    Utils.fileFromImageUrl(Utils.getOrgNameAndImage(
        widget.currentUserData.currentOrganizationId,
        widget.currentUserData.userOrganizations)[1]);
    userWorkTimes = workTimeService.getAllWorkTimes(widget.currentUserData.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Work track'.tr(),
        body: buildBody(provider, size),
        floatingActionButton: buildFab(context),
        shouldScroll: false);
  }

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

  int getTotalWorkHour(List<WorkTime> workTimes, String organizationId) {
    int totalWorkHour = 0;
    switch (currentClickIndex) {
      case 1:
        workTimes.forEach((element) {
          if (element.organizationId == organizationId) {
            totalWorkHour += element.hourWorked;
          }
        });
        break;
      case 2:
        workTimes.forEach((element) {
          if (element.workDate.month == DateTime.now().month &&
              element.organizationId == organizationId) {
            totalWorkHour += element.hourWorked;
          }
        });
        break;
      case 3:
        workTimes.forEach((element) {
          if (element.workDate.day == DateTime.now().day &&
              element.workDate.month == DateTime.now().month &&
              element.organizationId == organizationId) {
            totalWorkHour += element.hourWorked;
          }
        });
        break;
    }
    return totalWorkHour;
  }

  int getWorkHoursOfAGroup(String groupId, List<WorkTime> workTimes) {
    int totalWorkHours = 0;
    final totalWorkHoursOfAGroup = getWorkTimesOfAGroup(groupId, workTimes);

    switch (currentClickIndex) {
      case 1:
        totalWorkHoursOfAGroup.forEach((element) {
          totalWorkHours += element.hourWorked;
        });
        break;
      case 2:
        totalWorkHoursOfAGroup.forEach((element) {
          if (element.workDate.month == DateTime.now().month) {
            totalWorkHours += element.hourWorked;
          }
        });
        break;
      case 3:
        totalWorkHoursOfAGroup.forEach((element) {
          if (element.workDate.day == DateTime.now().day &&
              element.workDate.month == DateTime.now().month) {
            totalWorkHours += element.hourWorked;
          }
        });
        break;
    }
    return totalWorkHours;
  }

  int getApprovedTimeOfGroup(String groupId, List<WorkTime> workTimes) {
    int approvedTime = 0;
    workTimes.forEach((element) {
      if (element.groupId == groupId && element.isApproved) {
        approvedTime += element.hourWorked;
      }
    });
    return approvedTime;
  }

  Widget buildBody(MyProvider provider, Size size) {
    final allGroupsOfOrganization = provider.allGroupsOfAnOrganization;
    List<Group> myGroups = [];
    allGroupsOfOrganization.forEach((element) {
      if (element.uidList.contains(widget.currentUserData.uid)) {
        myGroups.add(element);
      }
    });
    return myGroups.length == 0
        ? Center(child: Text('You are not in any group'.tr()))
        : StreamBuilder<List<WorkTime>>(
            stream: userWorkTimes,
            builder: (context, snapshot) {
              List<WorkTime> allWorkTimes = [];
              int totalWorkHour = 0;
              if (snapshot.hasData) {
                allWorkTimes = snapshot.data!;
                totalWorkHour = getTotalWorkHour(
                    allWorkTimes, widget.currentUserData.currentOrganizationId);
              } else if (snapshot.hasError) {
                return noDataWidget(snapshot.error.toString(), false);
              }
              return Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextButton(
                            width: size.width * 0.3,
                            height: 60,
                            text: sortString.tr(),
                            textColor: Colors.black,
                            containerColor: Constants.CONTAINER_COLOR,
                            press: () {
                              currentClickIndex++;
                              if (currentClickIndex > 3) {
                                currentClickIndex = 1;
                              }
                              if (currentClickIndex == 1) {
                                setState(() {
                                  currentClickIndex = 1;
                                  sortString = 'This year';
                                });
                              } else if (currentClickIndex == 2) {
                                setState(() {
                                  currentClickIndex = 2;
                                  sortString = 'This month';
                                });
                              } else if (currentClickIndex == 3) {
                                setState(() {
                                  currentClickIndex = 3;
                                  sortString = 'Today';
                                });
                              }
                            }),
                        CustomTextButton(
                            width: size.width * 0.3,
                            height: 60,
                            text: '${totalWorkHour.toString()}' + 'h'.tr(),
                            textColor: Colors.black,
                            containerColor: Constants.BACKGROUND_COLOR,
                            press: () {}),
                        Platform.isIOS
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  createPdfForUser.createPdf(provider,
                                      allWorkTimes, currentClickIndex);
                                },
                                child: Container(
                                  width: size.width * 0.2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Constants.BUTTON_COLOR,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.download,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                        itemCount: myGroups.length,
                        itemBuilder: (context, index) {
                          final workTimeOfAGroup = getWorkTimesOfAGroup(
                              myGroups[index].groupId, allWorkTimes);
                          final workHoursOfAGroup = getWorkHoursOfAGroup(
                              myGroups[index].groupId, workTimeOfAGroup);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigation.navigateToGroupWorkTime(
                                    workTimeOfAGroup,
                                    context,
                                    myGroups[index].groupName,
                                    widget.currentUserData.uid,
                                    widget
                                        .currentUserData.currentOrganizationId);
                              },
                              child: Card(
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                      color: Constants.CONTAINER_COLOR,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          myGroups[index].groupName,
                                          style: appTextStyle.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(height: 4),
                                            Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    color: Constants
                                                        .BACKGROUND_COLOR,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Center(
                                                  child: Text(
                                                    '${workHoursOfAGroup}' +
                                                        'h'.tr(),
                                                    style: appTextStyle
                                                        .copyWith(fontSize: 18),
                                                  ),
                                                )),
                                            //SizedBox(height: 4),
                                            // Container(
                                            //     height: 30,
                                            //     width: 50,
                                            //     decoration: BoxDecoration(
                                            //         color: Constants.BUTTON_COLOR,
                                            //         borderRadius: BorderRadius.circular(8)),
                                            //     child: Center(
                                            //       child: Text('${getApprovedTimeOfGroup(myGroups[index].groupId, workTimeOfAGroup)}' +
                                            //           'h'.tr(),style: appTextStyle.copyWith(fontSize: 18,color: Colors.white),),
                                            //     ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              );
            });
  }

  showAddTimeDialog(BuildContext context) {
    final dialog = AddWorkTimeDialog(
        uid: widget.currentUserData.uid,
        organizationId: widget.currentUserData.currentOrganizationId);
    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  Widget buildFab(BuildContext context) {
    return AvatarGlow(
      animate: true,
      repeat: true,
      glowColor: Constants.BUTTON_COLOR,
      child: FloatingActionButton(
        backgroundColor: Constants.BUTTON_COLOR,
        onPressed: () {
          showAddTimeDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
