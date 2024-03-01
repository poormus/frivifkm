import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/extensions/extensions.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/survey_services.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../dialog/select_group_for_event.dart';
import '../../models/survey.dart';
import '../../shared/constants.dart';
import '../../shared/utils.dart';

class AddEditSurvey extends StatefulWidget {
  final Survey? survey;
  final CurrentUserData currentUserData;

  const AddEditSurvey({Key? key, this.survey, required this.currentUserData})
      : super(key: key);

  @override
  _AddEditPollState createState() => _AddEditPollState();
}

class _AddEditPollState extends State<AddEditSurvey> {
  late String surveyTitle;
  late List<String> toWho;
  late List<String> surveyQuestions;
  late MyProvider provider;
  late SurveyServices services;
  final controller = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  List<String> items = ['1-5', 'Agree-Disagree'.tr(), 'Good-Poor'.tr()];
  String? dropDownValue;

  @override
  void initState() {
    provider = Provider.of<MyProvider>(context, listen: false);
    services = SurveyServices(
        organizationId: widget.currentUserData.currentOrganizationId);
    services.init();
    surveyTitle = widget.survey == null ? '' : widget.survey!.surveyTitle;
    toWho = widget.survey == null ? [] : widget.survey!.toWho;
    surveyQuestions =
        widget.survey == null ? [] : widget.survey!.surveyQuestions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Create survey'.tr(),
        body: buildBody(size),
        shouldScroll: true,
        actions: [
          IconButton(
              onPressed: () => saveSurvey(),
              icon: Icon(Icons.save, color: Constants.CANCEL_COLOR))
        ]);
  }

  saveSurvey() {
    final expiresAt = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, selectedTime.hour, selectedTime.minute);
    if (services.validateCreateSurvey(
        context, surveyQuestions, toWho, surveyTitle, dropDownValue)) {
      services.createSurvey(surveyTitle, widget.currentUserData.uid,
          surveyQuestions, toWho, dropDownValue!, expiresAt, provider);
      Navigator.pop(context);
    }
  }

  Widget buildBody(Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildPopUp(),
            buildTargetList(provider),
            _buildTextFieldTitle(),
            buildSelectType(size),
            buildDateTimePicker(size),
            _buildTextFieldAddSurveyQuestion(size),
            buildSurveyList()
          ],
        ),
      ),
    );
  }

  Widget buildDateTimePicker(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101));
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  width: 120,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Constants.CONTAINER_COLOR,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                      child: Text(Utils.toDateTranslated(selectedDate, context),
                          style: appTextStyle.copyWith(
                              color: Constants.CANCEL_COLOR))),
                ),
              ),
              Positioned.fill(
                  child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('Expire date'.tr(),
                        style: appTextStyle.copyWith(color: Colors.grey))),
              ))
            ],
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  pickFromDateTime(pickDate: false);
                },
                child: Container(
                  width: 120,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Constants.CONTAINER_COLOR,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                      child: Text(Utils.toTime(selectedTime),
                          style: appTextStyle.copyWith(
                              color: Constants.CANCEL_COLOR))),
                ),
              ),
              Positioned.fill(
                  child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Expire time'.tr(),
                      style: appTextStyle.copyWith(color: Colors.grey),
                    )),
              ))
            ],
          ),
        ],
      ),
    );
  }

  showGroupListDialog() {
    toWho = [];
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return SelectUserForGroupDialog(groupList: (SelectGroup group) {
            setState(() {
              toWho = group.groupDataList;
            });
          });
        }).then((value) => null);
  }

  Widget _buildPopUp() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Constants.CONTAINER_COLOR),
      child: ListTile(
        onTap: () {
          showGroupListDialog();
        },
        leading: Text(
          'To'.tr(),
          style: appTextStyle,
        ),
        trailing: Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget buildSurveyList() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: surveyQuestions.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(surveyQuestions[index]),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      surveyQuestions.removeAt(index);
                    });
                  },
                  icon: Icon(Icons.delete, color: Constants.CANCEL_COLOR),
                ),
              ),
              Divider(
                height: 2,
                color: Colors.grey,
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildTargetList(MyProvider provider) {
    return toWho.isEmpty
        ? Container()
        : Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Constants.CONTAINER_COLOR),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: toWho.length,
              itemBuilder: (context, index) {
                return buildTile(toWho[index], provider);
              },
            ),
          );
  }

  Widget buildTile(String id, MyProvider provider) {
    String text = '';
    if (id == '1' || id == '2' || id == '3') {
      switch (id) {
        case '1':
          text = 'Guests'.tr();
          break;

        case '2':
          text = 'Members'.tr();
          break;

        case '3':
          text = 'Leaders'.tr();
          break;
      }
    } else {
      text = provider.getGroupNameById(id);
    }
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(text),
            IconButton(
                onPressed: () {
                  setState(() {
                    toWho.remove(id);
                  });
                },
                icon: Icon(
                  Icons.cancel,
                  color: Constants.CANCEL_COLOR,
                  size: 20,
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldTitle() {
    final maxLines = 3;
    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextFormField(
          initialValue: surveyTitle,
          textInputAction: TextInputAction.newline,
          maxLength: 100,
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          maxLines: maxLines,
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            hintText: 'Survey title'.tr(),
            fillColor: Constants.CONTAINER_COLOR,
            filled: true,
          ),
          onChanged: (val) => surveyTitle = val),
    );
  }

  Widget _buildTextFieldAddSurveyQuestion(Size size) {
    final maxLines = 3;
    return Row(
      children: [
        Container(
          width: size.width * 0.7,
          margin: EdgeInsets.all(12),
          height: maxLines * 24.0,
          child: TextFormField(
              controller: controller,
              textInputAction: TextInputAction.newline,
              maxLength: 50,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              maxLines: maxLines,
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                hintText: 'Survey question'.tr(),
                fillColor: Constants.CONTAINER_COLOR,
                filled: true,
              )),
        ),
        IconButton(
            onPressed: () {
              if (controller.text.trim().toString() == '') {
                return;
              }
              setState(() {
                surveyQuestions
                    .add(controller.text.toString().replaceAll('\n', ' '));
                controller.text = '';
              });
            },
            icon: Icon(
              Icons.add,
              color: Constants.BUTTON_COLOR,
            ))
      ],
    );
  }

  Widget buildSelectType(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: DropdownButtonFormField<String>(
          decoration:
              dropDownDecoration.copyWith(fillColor: Constants.CONTAINER_COLOR),
          isExpanded: true,
          hint: Text('Type'),
          value: dropDownValue,
          items: items.mapIndexed((element, index) {
            return DropdownMenuItem<String>(
                child: Text(element), value: '${index + 1}');
          }).toList(),
          onChanged: (value) {
            setState(() {
              dropDownValue = value.toString();
            });
            print(dropDownValue);
          }),
    );
  }

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(selectedTime, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      selectedTime = date;
    });
  }

  Future<DateTime?> pickDateTime(DateTime initialDate,
      {required bool pickDate, DateTime? firstDate}) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime(2101));
      if (date == null) return null;
      final time =
          Duration(hours: selectedTime.hour, minutes: selectedTime.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(selectedTime));
      if (timeOfDay == null) return null;
      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }
}
