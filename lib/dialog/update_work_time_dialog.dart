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
class UpdateWorkTimeDialog extends StatefulWidget {

  final WorkTime workTime;
  final String groupName;
  final int index;
  final onUpdateWorkTime onUpdate;
  final String uid;
  final String organizationId;
  UpdateWorkTimeDialog({
    Key? key, required this.workTime, required this.groupName,
    required this.onUpdate, required this.index, required this.uid, required this.organizationId
  }) : super(key: key);

  @override
  State<UpdateWorkTimeDialog> createState() => _UpdateWorkTimeDialogState();
}

class _UpdateWorkTimeDialogState extends State<UpdateWorkTimeDialog> {

  final groupService=GroupServices();

  late DateTime workDate;
  List<String> timeSelect = ['1', '2', '3', '4', '5', '6'];
  late int workHour;
  late WorkTimeServices workTimeService;
  @override
  void initState() {
    workTimeService=WorkTimeServices(organizationId: widget.organizationId);
    workTimeService.init();
    workDate=widget.workTime.workDate;
    workHour=widget.workTime.hourWorked;
    super.initState();
  }

  Future updateWorkTime() async{
    await workTimeService.updateWorkTime(widget.workTime.id,widget.uid,context,workDate,workHour)
        .then((value){
          widget.onUpdate(UpdateWorkTimeDetails(workDate: workDate, workHour: workHour, index: widget.index)
          );
    });
    dismissDialog(context);
  }

  void dismissDialog(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 200), () {
      // When task is over, close the dialog
      Navigator.pop(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Container(
                      width: size.width*0.8,
                        height: 45,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white,
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child:Center(child: Text(widget.groupName,style: appTextStyle.copyWith(fontWeight: FontWeight.bold),))
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
                            height: 35,
                            width: size.width * 0.3,
                            containerColor: Constants.BUTTON_COLOR,
                            textColor: Colors.white,
                            text: 'Update'.tr(),
                            press: () {
                              updateWorkTime();
                            }),
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


typedef onUpdateWorkTime(UpdateWorkTimeDetails details);

class UpdateWorkTimeDetails{
  final DateTime workDate;
  final int workHour;
  final int index;
  const UpdateWorkTimeDetails( {
    required this.workDate,
    required this.workHour,
    required this.index
  });
}

