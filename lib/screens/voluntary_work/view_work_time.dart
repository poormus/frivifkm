import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/update_work_time_dialog.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

import '../../services/work_time_services.dart';

class ViewWorkTimeScreen extends StatefulWidget {
  final List<WorkTime> workTimes;
  final String groupName;
  final String uid;
  final String organizationId;
  ViewWorkTimeScreen(
      {Key? key, required this.workTimes, required this.groupName, required this.uid, required this.organizationId})
      : super(key: key);

  @override
  State<ViewWorkTimeScreen> createState() => _ViewWorkTimeScreenState();
}

class _ViewWorkTimeScreenState extends State<ViewWorkTimeScreen> {
  GroupServices groupServices = GroupServices();
  late WorkTimeServices workTimeService;

  @override
  void initState() {
    workTimeService=WorkTimeServices(organizationId: widget.organizationId);
    workTimeService.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarName: widget.groupName,
        body: buildBody(context),
        shouldScroll: false);
  }

  void showDeleteWorkTimeDialog(String id, int index) {
    final dialog = BlurryDialogNew(
        title: 'Delete this entry?'.tr(),
        continueCallBack: () async {
          await workTimeService.deleteWorkTime(id, widget.uid).then((value) {
            setState(() {
              widget.workTimes.removeAt(index);
            });
            Navigator.of(context).pop();
          });
        });

    showDialog(context: context, builder: (_) {
      return dialog;
    });
  }

  void updateWorkTimeDialog(WorkTime workTime, int index) {
    final dialog = UpdateWorkTimeDialog(workTime: workTime,organizationId: widget.organizationId,
        groupName: widget.groupName,
        onUpdate: (UpdateWorkTimeDetails details){
            final workTimeBefore=widget.workTimes[details.index];
            final workTimeAfter=WorkTime(id: workTimeBefore.id, groupId: workTimeBefore.groupId,
                organizationId: workTimeBefore.organizationId, uid: workTimeBefore.uid,workDate: details.workDate, hourWorked: details.workHour,isApproved: false);
            setState(() {
              widget.workTimes.removeAt(details.index);
              widget.workTimes.insert(details.index, workTimeAfter);
            });
        },
        index: index,
        uid: widget.uid);
    showDialog(context: context, builder: (_){
      return dialog;
    });
  }


  Widget buildBody(BuildContext context) {
    return ListView.builder(
        itemCount: widget.workTimes.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                    color: Constants.CONTAINER_COLOR,
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Utils.toDateTranslated(
                          widget.workTimes[index].workDate, context)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              height: 40,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: Constants.BACKGROUND_COLOR,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(
                                  '${widget.workTimes[index].hourWorked
                                      .toString()}' +
                                      'h'.tr(),
                                  style: appTextStyle.copyWith(fontSize: 20),),
                              )),
                          widget.workTimes[index].isApproved?Text('Approved by admin'.tr(),
                            style: appTextStyle.copyWith(color: Constants.CANCEL_COLOR),)
                              :Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                        updateWorkTimeDialog(widget.workTimes[index], index);
                                  },
                                  icon: Icon(Icons.edit,
                                      color: Constants.BUTTON_COLOR)),
                              SizedBox(width: 10),
                              IconButton(
                                  onPressed: () {
                                    showDeleteWorkTimeDialog(
                                        widget.workTimes[index].id, index);
                                  },
                                  icon: Icon(Icons.delete_rounded,
                                      color: Constants.CANCEL_COLOR)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
