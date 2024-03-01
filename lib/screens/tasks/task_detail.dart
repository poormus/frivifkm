import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/task.dart';
import 'package:firebase_calendar/services/task_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/elevated_button.dart';
import '../../shared/my_provider.dart';

class TaskDetail extends StatelessWidget {
  final List<String> taskProgress = ['Open'.tr(),'In progress'.tr(), 'Done'.tr()];

  final CurrentUserData currentUserData;
  final Task task;
  final TaskServices taskServices;

  TaskDetail(
      {Key? key,
      required this.currentUserData,
      required this.task,
      required this.taskServices})
      : super(key: key);

  List<CurrentUserData> getUsersFromUid(
      MyProvider provider, List<String> uids) {
    List<CurrentUserData> users = [];
    uids.forEach((uid) {
      provider.allUsersOfOrganization.forEach((user) {
        if (user.uid == uid) {
          users.add(user);
        }
      });
    });
    return users;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Details'.tr(),
        body: _buildBody(size, context, provider),
        shouldScroll: true);
  }

  Widget buildAssigneeList(Size size, Task task, MyProvider provider) {
    final userList = getUsersFromUid(provider, task.assignees);
    return userList.length==0?Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child:Text('No assignees yet'.tr())),
    ):Container(
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
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildBody(Size size, BuildContext context, MyProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDropDown(size),
            SizedBox(
              height: 5,
            ),
            Container(
              width: size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${task.taskTitle}',
                    style: appTextStyle.copyWith(
                      fontSize: 22
                    )),
              ),
            ),
            Container(
              width: size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${task.taskDescription}'),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Assignees'.tr(),
                  style: appTextStyle.copyWith(
                    fontSize: 22,
                  )),
            ),
            buildAssigneeList(size, task, provider),
            SizedBox(height: 20),
            Container(
              height: 80,
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Due date'.tr(), style: appTextStyle.copyWith(fontSize: 22)),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Utils.toDateTranslated(task.dueDate, context),style: TextStyle(
                          color: task.dueDate.isBefore(DateTime.now())?Colors.red:Colors.black
                        ),),
                        Icon(Icons.access_time),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildButton(context),
              ],
            ),
            task.subTasks.length==0?Container():
            SubTaskStatus(subTasks: task.subTasks, taskId: task.taskId,services: taskServices)
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return task.progress=='2' || task.progress=='3'?Container():ElevatedCustomButton(
        text: task.assignees.contains(currentUserData.uid)
            ? 'Drop'.tr()
            : 'Pick'.tr(),
        press: () {
          task.assignees.contains(currentUserData.uid)
              ? taskServices.dropOpenTaskUserId(currentUserData.uid, task)
              : taskServices.updateOpenTaskUserId(currentUserData.uid, task);
          Navigator.pop(context);
        },
        color: Constants.BACKGROUND_COLOR,textColor: Constants.BUTTON_COLOR,);
  }

  Widget buildDropDown(Size size) {
    return Container(
        width: size.width,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: DropdownButtonFormField(
          value: taskProgress[int.parse(task.progress)],
            hint: Text('Progress'.tr(),
                style: appTextStyle.copyWith(fontWeight: FontWeight.bold)),
            decoration:
                dropDownDecoration.copyWith(fillColor: Colors.grey[100]),
            items: taskProgress.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (val) {
              int index = taskProgress.indexOf(val.toString());
              taskServices.updateTaskProgress(task.taskId, index.toString());
            }));
  }
}

class SubTaskStatus extends StatefulWidget {
  final List<SubTask> subTasks;
  final String taskId;
  final TaskServices services;
  const SubTaskStatus({Key? key, required this.subTasks,
    required this.taskId, required this.services}) : super(key: key);

  @override
  _SubTaskStatusState createState() => _SubTaskStatusState();
}


class _SubTaskStatusState extends State<SubTaskStatus> {
  @override
  Widget build(BuildContext context) {
    return buildSubTaskList();
  }

  late List<SubTask> newSubTasks=[];
  bool isLoading=false;

  @override
  void initState() {
    newSubTasks=widget.subTasks;
    super.initState();
  }
  Widget buildSubTaskList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Sub tasks'.tr()),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: newSubTasks.length,
          itemBuilder: (context, index) {
            final subTask=newSubTasks[index];
            bool isDone=subTask.isDone;
            return Column(
              children: [
                ListTile(
                  title: Text(subTask.subTaskTitle),
                  trailing: Checkbox(
                    activeColor: Constants.CANCEL_COLOR,
                    value: isDone,
                    onChanged: (value){
                      setState(() {
                        newSubTasks[index]=SubTask(isDone: value!,subTaskTitle: subTask.subTaskTitle);
                      });
                    },
                  )
                ),
                Divider(
                  height: 2,
                  color: Colors.grey,
                )
              ],
            );
          },
        ),
        isLoading?LinearProgressIndicator(color: Constants.CANCEL_COLOR):
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedCustomButton(text: 'Update'.tr(), press: ()=>updateSubTask(),
              color: Constants.BACKGROUND_COLOR,textColor: Constants.BUTTON_COLOR,),
          ],
        )
      ],
    );
  }

  updateUi(bool loading){
    setState(() {
      isLoading=loading;
    });
  }
  updateSubTask(){
    updateUi(true);
    widget.services.updateSubTaskStatus(newSubTasks,widget.taskId).then((value) => updateUi(false));
    Utils.showToastWithoutContext('Updated'.tr());
  }
}

