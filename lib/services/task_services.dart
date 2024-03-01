import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/models/task.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../config/key_config.dart';
import '../shared/utils.dart';

class TaskServices {
  final String organizationId;

  late CollectionReference<Map<String, dynamic>> taskRef;

  TaskServices({
    required this.organizationId,
  });

  init() {
    taskRef = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('task/${organizationId}/tasks')
        : FirebaseFirestore.instance
            .collection('task_test/${organizationId}/tasks');
  }

  bool validateTask(
      BuildContext context, String title, String desc, List<String> userList) {
    if (title.trim().isEmpty) {
      Utils.showSnackBar(context, 'Title can not be empty'.tr());
      return false;
    } else if (desc.trim().isEmpty) {
      Utils.showSnackBar(context, 'Description can not be empty'.tr());
      return false;
    } else
      return true;
  }

  Future createTask(
      String title,
      String desc,
      String organizationId,
      List<String> userList,
      int maxUsers,
      DateTime dueDate,
      List<SubTask> subTasks) async {
    final taskId = Uuid().v1().toString();
    final task = Task(
        taskId: taskId,
        organizationId: organizationId,
        taskTitle: title,
        taskDescription: desc,
        progress: maxUsers == userList.length ? '1' : '0',
        maxUsersForOpenTask: maxUsers,
        assignees: userList,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        subTasks: subTasks);

    taskRef.doc(taskId).set(task.toMap());
  }

  Stream<List<Task>> getTasks() {
    return taskRef
        .snapshots()
        .map((event) => event.docs.map((e) => Task.fromMap(e.data())).toList());
  }

  void updateTaskProgress(String taskId, String type) {
    taskRef.doc(taskId).update({'progress': type});
  }

  void updateOpenTaskUserId(String uid, Task task) {
    final assignees = task.assignees;
    if (assignees.contains(uid)) return;
    assignees.add(uid);
    if (assignees.length >= task.maxUsersForOpenTask) {
      taskRef
          .doc(task.taskId)
          .update({'progress': '1', 'assignees': assignees});
    } else
      taskRef.doc(task.taskId).update({'assignees': assignees});
  }

  dropOpenTaskUserId(String uid, Task task) {
    final assignees = task.assignees;
    if (assignees.contains(uid)) assignees.remove(uid);
    taskRef.doc(task.taskId).update({'assignees': assignees,'progress':'0'});
  }

  void updateTask(
      String title,
      String desc,
      String currentOrganizationId,
      List<String> currentUids,
      int currentValue,
      DateTime dueDate,
      String taskId,
      List<SubTask> subTasks) {
    final task = Task(
        taskId: taskId,
        organizationId: organizationId,
        taskTitle: title,
        taskDescription: desc,
        progress: currentValue == currentUids.length ? '1' : '0',
        maxUsersForOpenTask: currentValue,
        assignees: currentUids,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        subTasks: subTasks);
    taskRef.doc(taskId).update(task.toMap());
  }

  Future<void> updateSubTaskStatus(List<SubTask> subTasks,String taskId) async {
    try {
      List<Map<String,dynamic>> subTasksMap=[];
      subTasks.forEach((element) {
        final newSubTask=SubTask(subTaskTitle: element.subTaskTitle,isDone: element.isDone).toMap();
        subTasksMap.add(newSubTask);
      });
       taskRef.doc(taskId).update({
         'subTasks':subTasksMap
       });

    } on Exception catch (e) {
      Utils.showErrorToast();
    }
  }

  deleteTask(String taskId){
    taskRef.doc(taskId).delete();
  }


}
