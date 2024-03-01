import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/work_time_services.dart';

//ignore: must_be_immutable
class AddWorkTimeDialog extends StatefulWidget {
  final String uid;
  final String organizationId;
  WorkTime? workTime;
  AddWorkTimeDialog({
    Key? key,
    required this.uid,
    required this.organizationId,
    this.workTime
  }) : super(key: key);

  @override
  State<AddWorkTimeDialog> createState() => _AddWorkTimeDialogState();
}

class _AddWorkTimeDialogState extends State<AddWorkTimeDialog> {

  final groupService=GroupServices();

  late WorkTimeServices workTimeService;

  String groupId = '';

  DateTime workDate = DateTime.now();

  List<String> timeSelect = ['1', '2', '3', '4', '5', '6'];

  int workHour=0;

  @override
  void initState() {
    workTimeService=WorkTimeServices(organizationId:widget.organizationId);
    workTimeService.init();
    super.initState();
  }
  void dismissDialog(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 200), () {
      // When task is over, close the dialog
      Navigator.pop(context);
    });
  }

  Future saveWorkTime() async{
    if(Utils.validateWorkTime(context,groupId,workHour)){
      workTimeService.saveWorkTime(groupId,widget.uid,widget.organizationId,workDate,workHour);
      Navigator.pop(context);
    }

  }

  List<Group> getMyGroups(MyProvider provider) {
    final allGroupsOfOrganization = provider.allGroupsOfAnOrganization;
    List<Group> myGroups = [];
    allGroupsOfOrganization.forEach((element) {
      if (element.uidList.contains(widget.uid)) {
        myGroups.add(element);
      }
    });
    return myGroups;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    final myGroups = getMyGroups(provider);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      backgroundColor: Constants.BACKGROUND_COLOR,
      child: Container(
          height: 270,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Add time'.tr(),
                      style: appTextStyle.copyWith(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: DropdownButtonFormField(
                          hint: Text('Select group'.tr(),
                              style: appTextStyle.copyWith(
                                  fontWeight: FontWeight.bold)),
                          decoration: dropDownDecoration.copyWith(
                              fillColor: Colors.white),
                          items: myGroups.map((group) {
                            return DropdownMenuItem(
                                value: group.groupId,
                                child: Text(group.groupName));
                          }).toList(),
                          onChanged: (val) {
                            groupId=val.toString();
                          }),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: (){
                        pickDate(pickDate: true);
                      },
                      child: Container(
                          height: 45,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(Utils.toDateTranslated(workDate, context),
                                    style: appTextStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Icon(Icons.arrow_drop_down_outlined),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: DropdownButtonFormField(
                          hint: Text('Select time'.tr(),
                              style: appTextStyle.copyWith(
                                  fontWeight: FontWeight.bold)),
                          decoration: dropDownDecoration.copyWith(
                              fillColor: Colors.white),
                          items: timeSelect.map((int) {
                            return DropdownMenuItem(
                                value: int, child: Text('${int.toString()} h'));
                          }).toList(),
                          onChanged: (val) {
                            workHour=(timeSelect.indexOf(val.toString())+1).toInt();
                          }),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomTextButton(
                            height: 40,
                            width: size.width * 0.3,
                            containerColor: Constants.BUTTON_COLOR,
                            textColor: Colors.white,
                            text: 'Save'.tr(),
                            press: () =>saveWorkTime()),
                        SizedBox(width: 10)
                      ],
                    )
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

  Future pickDate({required bool pickDate}) async {
    final date = await pickDateTime(workDate, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      workDate = date;
    });
  }

  Future<DateTime?> pickDateTime(DateTime initialDate,
      {required bool pickDate, DateTime? firstDate}) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (date == null) return null;
      final time = Duration(hours: date.hour, minutes: date.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (timeOfDay == null) return null;
      final date =
      DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }
}

