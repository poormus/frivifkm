import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/select_user_for_channel.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/task_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';
import '../../models/task.dart';
import '../../shared/constants.dart';
import '../../shared/my_provider.dart';
import '../../shared/utils.dart';

class AddEditTaskScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final Task? task;
  const AddEditTaskScreen({Key? key, required this.currentUserData, this.task})
      : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final taskTitleController = TextEditingController();
  final taskDescController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  final controller = TextEditingController();

  late MyProvider provider;
  late int currentValue;
  late TaskServices taskServices;
  List<CurrentUserData> userList = [];
   late List<SubTask> subTasks;
  @override
  void initState() {
    provider=Provider.of<MyProvider>(context,listen: false);
    currentValue=widget.task==null?1:widget.task!.maxUsersForOpenTask;
    userList=widget.task==null?[]:getUsersFromUid(provider,widget.task!.assignees);
    taskTitleController.text=widget.task==null?'':widget.task!.taskTitle;
    taskDescController.text=widget.task==null?'':widget.task!.taskDescription;
    subTasks=widget.task==null?[]:widget.task!.subTasks;
    taskServices=TaskServices(organizationId: widget.currentUserData.currentOrganizationId);
    taskServices.init();
    super.initState();
  }

  List<CurrentUserData> getUsersFromUid(MyProvider provider,List<String> uids){
    List<CurrentUserData> users=[];
    uids.forEach((uid) {
      provider.allUsersOfOrganization.forEach((user) {
        if(user.uid==uid){
          users.add(user);
        }
      });
    });
    return users;
  }

  void saveTask(){
    List<String> currentUids=[];
    userList.forEach((element) {
      currentUids.add(element.uid);
    });
    final dueDate=DateTime(selectedDate.year,selectedDate.month,selectedDate.day,23,59);
    if(widget.task==null){
      if(taskServices.validateTask(context, taskTitleController.text, taskDescController.text,currentUids)){
        taskServices.createTask(taskTitleController.text, taskDescController.text,
            widget.currentUserData.currentOrganizationId, currentUids, currentValue, dueDate,subTasks);
        Utils.showToastWithoutContext('Saved'.tr());
        Navigator.pop(context);
      }
    }else{
      if(taskServices.validateTask(context, taskTitleController.text, taskDescController.text, currentUids)){
        taskServices.updateTask(taskTitleController.text, taskDescController.text,
            widget.currentUserData.currentOrganizationId, currentUids, currentValue,
            dueDate,widget.task!.taskId,subTasks);
        Utils.showToastWithoutContext('Updated'.tr());
        Navigator.pop(context);
      }
    }
  }

  void deleteTask(){
    final dialog=BlurryDialogNew(title: "Delete This task?".tr(), continueCallBack: (){
      taskServices.deleteTask(widget.task!.taskId);
      Navigator.pop(context);
      Navigator.pop(context);
    });
    showDialog(context: context, builder: (_){
      return dialog;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffold(
        appBarName: 'Add/Edit task'.tr(),
        body: body(size, provider),
        shouldScroll: true,
        actions: [
          IconButton(
              onPressed: () => saveTask(),
              icon: Icon(Icons.save, color: Constants.CANCEL_COLOR)),
          widget.task!=null?IconButton(
              onPressed: () => deleteTask(),
              icon: Icon(Icons.delete, color: Constants.BUTTON_COLOR)):Container(),
        ],
    );
  }

  Widget body(Size size, MyProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          _buildTextFieldTitle(),
          _buildTextField(),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text('Max number of users'.tr()),
          ),
          NumberPicker(
            textStyle: TextStyle(color: Constants.CANCEL_COLOR),
            selectedTextStyle:TextStyle(color: Constants.BUTTON_COLOR,fontSize: 20) ,
            itemHeight: 40,
            axis: Axis.horizontal,
            value: currentValue,
            minValue: 1,
            maxValue: 10,
            onChanged: (value) => setState(() => currentValue = value),
          ),
          buildAssigneeRow(size),
          _buildTextFieldSubTask(size),
          subTasks.length==0?Container():buildSubTaskList(),
          buildDateTimePicker(size)
        ],
      ),
    );
  }

  Widget _buildTextField() {
    final maxLines = 7;
    return Container(
      margin: EdgeInsets.only(top: 12,bottom: 0,left: 12,right: 12),
      height: maxLines * 24.0,
      child: TextField(
        controller: taskDescController,
        textInputAction: TextInputAction.newline,
        maxLength: 250,
        inputFormatters: [
          LengthLimitingTextInputFormatter(250),
        ],
        maxLines: maxLines,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          hintText: 'Task description'.tr(),
          fillColor: Constants.CONTAINER_COLOR,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildTextFieldTitle() {
    final maxLines = 3;
    return Container(
      margin: EdgeInsets.only(top: 12,bottom: 0,left: 12,right: 12),
      height: maxLines * 24.0,
      child: TextFormField(
          controller: taskTitleController,
          textInputAction: TextInputAction.newline,
          maxLength: 100,
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          maxLines: maxLines,
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            hintText: 'Task title'.tr(),
            fillColor: Constants.CONTAINER_COLOR,
            filled: true,
          )),
    );
  }

  Widget buildAssigneeRow(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Constants.CONTAINER_COLOR),
          child: ListTile(
            title: Text('Select assignee(s)'.tr()),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (c) {
                    return SelectUserForChannelDialog(
                      userData: userList,
                      orgId:
                      widget.currentUserData.currentOrganizationId,
                      userList: (SelectUser selectUser) {
                        if(userList.length>currentValue){
                          Utils.showSnackBar(context, 'Max user limit is exceeded'.tr());
                          userList=[];
                          return;
                        }
                        setState(() {
                          userList = selectUser.userDataList;
                        });
                      },
                    );
                  });
            },
          ),
        ),
        userList.isEmpty?Container():Container(
          margin: EdgeInsets.only(left: 5),
          height: 50,
          width: size.width * 0.8,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: userList.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 30,
                      height: 50,
                      imageUrl: userList[index].userUrl,
                      placeholder: (context, url) =>
                      new LinearProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      new Icon(Icons.error),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget buildDateTimePicker(Size size){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 8),
      child:Stack(
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
              width: size.width,
              height: 80,
              decoration: BoxDecoration(
                  color: Constants.CONTAINER_COLOR,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Center(child: Text(Utils.toDateTranslated(selectedDate, context),
                  style: appTextStyle.copyWith(color: Constants.CANCEL_COLOR,fontSize: 22))),
            ),
          ),
          Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('Expire date'.tr(),style: appTextStyle.copyWith(color: Colors.grey))),
              ))
        ],
      ),
    );
  }

  Widget _buildTextFieldSubTask(Size size) {
    final maxLines = 3;
    return Row(
      children: [
        Container(
          width: size.width * 0.8,
          margin: EdgeInsets.only(top: 12,bottom: 0,left: 12),
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
                hintText: 'Sub task'.tr(),
                fillColor: Constants.CONTAINER_COLOR,
                filled: true,
              )),
        ),
        SizedBox(width: 6),
        IconButton(
            onPressed: () {
              if (controller.text.trim().toString() == '') {
                return;
              }else if(subTasks.length>4){
                Utils.showToastWithoutContext('max sub task reached'.tr());
                return;
              }
              setState(() {
                subTasks.add(SubTask(isDone: false, subTaskTitle: controller.text.toString().replaceAll('\n', ' ')));
                controller.text = '';
              });
            },
            icon: Icon(
              Icons.add,
              color: Constants.BUTTON_COLOR,
              size: 30,
            ))
      ],
    );
  }

  Widget buildSubTaskList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: subTasks.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(subTasks[index].subTaskTitle),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      subTasks.removeAt(index);
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
      final time = Duration(hours: selectedTime.hour, minutes: selectedTime.minute);
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
