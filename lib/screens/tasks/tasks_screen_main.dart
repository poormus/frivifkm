import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold_main_screen_item.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/survey.dart';
import 'package:firebase_calendar/screens/surveys_screen/view_statistics_screen.dart';
import 'package:firebase_calendar/screens/tasks/add_edit_task_screen.dart';
import 'package:firebase_calendar/screens/tasks/my_tasks_screen.dart';
import 'package:firebase_calendar/screens/tasks/tasks_screen.dart';
import 'package:firebase_calendar/services/survey_services.dart';
import 'package:firebase_calendar/services/task_services.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../anim/slide_in_right.dart';
import '../../components/cutom_circular.dart';
import '../../models/task.dart';
import '../../shared/constants.dart';

class TasksScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;

  const TasksScreen(
      {Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String currentTab = '1';
  late TaskServices taskServices;
  late Stream<List<Task>> tasks;

  @override
  void initState() {
    taskServices = TaskServices(
        organizationId: widget.currentUserData.currentOrganizationId);
    taskServices.init();
    tasks = taskServices.getTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldMainScreenItem(
      body: buildBody(),
      fab: buildFab(context),
    );
  }

  updateUi(String tabNumber) {
    setState(() {
      currentTab = tabNumber;
    });
  }

  Widget buildBody() {
    return StreamBuilder<List<Task>>(
        stream: tasks,
        builder: (context, snapshot) {
          List<Task> tasks = [];
          if (snapshot.hasData) {
            tasks = snapshot.data!;

            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: Constants.TAB_HEIGHT,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                            onPressed: () {
                              updateUi('1');
                            },
                            child: Text(
                              'Tasks'.tr(),
                              style: TextStyle(
                                  color: currentTab == '1'
                                      ? Constants.BUTTON_COLOR
                                      : Colors.grey),
                            )),
                      ),
                      VerticalDivider(width: 3, color: Colors.grey),
                      Expanded(
                        child: TextButton(
                            onPressed: () {
                              updateUi('2');
                            },
                            child: Text('My Tasks'.tr(),
                                style: TextStyle(
                                    color: currentTab == '2'
                                        ? Constants.BUTTON_COLOR
                                        : Colors.grey))),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
                SizedBox(height: 5),
                if (currentTab == '1') ...[
                  TasksScreenViewTasks(
                    currentUserData: widget.currentUserData,
                    userRole: widget.userRole,
                    tasks: tasks,
                    taskServices: taskServices,
                  )
                ] else if (currentTab == '2') ...[
                  MyTasks(
                    currentUserData: widget.currentUserData,
                    userRole: widget.userRole,
                    tasks: tasks,
                    taskServices: taskServices,
                  )
                ]
              ],
            );
          } else
            return noDataWidget('', true);
        });
  }

  Widget? buildFab(BuildContext context) {
    return widget.userRole == '4' || widget.userRole == '3'
        ? AvatarGlow(
            animate: true,
            repeat: true,
            glowColor: Constants.BUTTON_COLOR,
            child: FloatingActionButton(
              backgroundColor: Constants.BUTTON_COLOR,
              onPressed: () {
                Navigation.navigateToAddEditTask(
                    context, widget.currentUserData, null);
              },
              child: Icon(Icons.add),
            ),
          )
        : null;
  }
}
