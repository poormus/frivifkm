import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_with_title.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/poll.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/services/poll_services.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:googleapis/shared.dart';
import 'package:provider/provider.dart';

import '../../components/elevated_button.dart';
import '../../dialog/select_group_for_event.dart';
import '../../shared/constants.dart';

class AddEditPoll extends StatefulWidget {
  final Poll? poll;
  final CurrentUserData currentUserData;

  const AddEditPoll({Key? key, this.poll, required this.currentUserData})
      : super(key: key);

  @override
  _AddEditPollState createState() => _AddEditPollState();
}

class _AddEditPollState extends State<AddEditPoll> {
  late String pollQuestion;
  late List<String> toWho;
  late List<PollItem> pollItems;
  late MyProvider provider;
  late PollServices pollServices;

  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  final controller = TextEditingController();

  @override
  void initState() {
    pollServices = PollServices(
        organizationId: widget.currentUserData.currentOrganizationId);
    pollServices.init();
    provider = Provider.of<MyProvider>(context, listen: false);
    pollQuestion = widget.poll != null ? widget.poll!.pollQuestion : '';
    toWho = widget.poll != null ? widget.poll!.toWHo : [];
    pollItems = widget.poll != null ? widget.poll!.pollItems : [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Create poll'.tr(),
        body: buildBody(size),
        shouldScroll: true,
        actions: [
          IconButton(
              onPressed: () => savePoll(),
              icon: Icon(Icons.save, color: Constants.CANCEL_COLOR))
        ]);
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
            buildDateTimePicker(size),
            _buildTextFieldAddSurveyQuestion(size),
            buildPollList()
          ],
        ),
      ),
    );
  }

  savePoll() {
    final expireTime = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, selectedTime.hour, selectedTime.minute);

    if (pollServices.validateSavePoll(
        context, pollQuestion, toWho, pollItems)) {
      if (widget.poll == null) {
        pollServices.savePoll(pollQuestion, widget.currentUserData.uid, toWho,
            pollItems, [], expireTime, provider);
      } else {
        pollServices.updatePoll(
            widget.poll!.pollId,
            pollQuestion,
            widget.currentUserData.uid,
            toWho,
            pollItems,
            expireTime,
            widget.poll!.seenBy,
            provider);
      }
      Navigator.pop(context);
    }
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

  showAddPollItemDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AddPoolItemDialog(
              pollItemAdded: (AddedPollItem addedPollItem) {
            final pollItem =
                PollItem(item: addedPollItem.addedPollItem, answeredUserId: []);
            setState(() {
              pollItems.add(pollItem);
            });
          });
        }).then((value) => FocusScope.of(context).unfocus());
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

  Widget buildAddPollQuestionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedCustomButton(
              text: widget.poll == null ? 'Save'.tr() : 'Update'.tr(),
              press: savePoll,
              color: Constants.BUTTON_COLOR),
          ElevatedCustomButton(
              text: 'Add poll item'.tr(),
              press: showAddPollItemDialog,
              color: Constants.BUTTON_COLOR),
        ],
      ),
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
                hintText: 'Poll option'.tr(),
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
                pollItems.add(PollItem(
                    item: controller.text.toString().replaceAll('\n', ' '),
                    answeredUserId: []));
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

  Widget buildDateTimePicker(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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

  Widget buildPollList() {
    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: pollItems.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(pollItems[index].item),
                trailing: IconButton(
                  onPressed: () {
                    removeItem(index, pollItems[index].answeredUserId);
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
          initialValue: pollQuestion,
          textInputAction: TextInputAction.newline,
          maxLength: 100,
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          maxLines: maxLines,
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            hintText: 'Poll title'.tr(),
            fillColor: Constants.CONTAINER_COLOR,
            filled: true,
          ),
          onChanged: (val) => pollQuestion = val),
    );
  }

  void removeItem(int index, List<String> answeredUids) {
    if (widget.poll == null) {
      setState(() {
        pollItems.removeAt(index);
      });
    } else {
      final dialog = BlurryDialogWithTitle(
          title: 'Delete this poll item ?'.tr(),
          continueCallBack: () {
            setState(() {
              pollItems.removeAt(index);
            });
            Navigator.pop(context);
          },
          content: 'This poll item has'.tr() +
              ' ${answeredUids.length} ' +
              'votes'.tr());
      showDialog(
          context: context,
          builder: (_) {
            return dialog;
          });
    }
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

class AddPoolItemDialog extends StatelessWidget {
  final OnPollItemAdded pollItemAdded;

  AddPoolItemDialog({Key? key, required this.pollItemAdded}) : super(key: key);

  String pollItemToAdd = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Theme(
      data: ThemeData.light(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
        backgroundColor: Constants.BACKGROUND_COLOR,
        child: Container(
            height: 152,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                        width: size.width * 0.75,
                        child: TextFormField(
                          maxLength: 50,
                          initialValue: pollItemToAdd,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                          onChanged: (value) => pollItemToAdd = value,
                          decoration: InputDecoration(
                              hintText: 'Poll item'.tr(),
                              border: UnderlineInputBorder()),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedCustomButton(
                            text: 'Add'.tr(),
                            press: () {
                              if (pollItemToAdd.trim() == '') {
                                return;
                              }
                              pollItemAdded(AddedPollItem(
                                  addedPollItem: pollItemToAdd
                                      .trim()
                                      .replaceAll('\n', ' ')));
                              Navigator.pop(context);
                            },
                            color: Constants.BUTTON_COLOR)
                      ],
                    )
                  ],
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
      ),
    );
  }
}

class AddedPollItem {
  final String addedPollItem;

  const AddedPollItem({
    required this.addedPollItem,
  });
}

typedef OnPollItemAdded = void Function(AddedPollItem addedPollItem);
