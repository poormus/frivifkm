import '../shared/utils.dart';

class Task{
  final String taskId;
  final String organizationId;
  final String taskTitle;
  final String taskDescription;
  final String progress;
  final int maxUsersForOpenTask;
  final List<String> assignees;
  final DateTime dueDate;
  final DateTime createdAt;
  final List<SubTask> subTasks;

  const Task({
    required this.taskId,
    required this.organizationId,
    required this.taskTitle,
    required this.taskDescription,
    required this.progress,
    required this.maxUsersForOpenTask,
    required this.assignees,
    required this.dueDate,
    required this.createdAt,
    required this.subTasks
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': this.taskId,
      'organizationId': this.organizationId,
      'taskTitle': this.taskTitle,
      'taskDescription': this.taskDescription,
      'progress': this.progress,
      'maxUsersForOpenTask': this.maxUsersForOpenTask,
      'assignees': this.assignees,
      'dueDate': this.dueDate,
      'createdAt': this.createdAt,
      'subTasks':this.subTasks.map((e) => e.toMap()).toList()
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final List<SubTask> subTasks=[];
    List subTasksFromMap=map['subTasks'];
    subTasksFromMap.forEach((element) {
      SubTask subTask=SubTask.fromMap(element as Map<String, dynamic>);
      subTasks.add(subTask);
    });
    return Task(
      taskId: map['taskId'] as String,
      organizationId: map['organizationId'] as String,
      taskTitle: map['taskTitle'] as String,
      taskDescription: map['taskDescription'] as String,
      progress: map['progress'] as String,
      maxUsersForOpenTask: map['maxUsersForOpenTask'] as int,
      assignees: List.castFrom(map['assignees']),
      dueDate: Utils.toDateTime(map['dueDate']),
      createdAt: Utils.toDateTime(map['createdAt']),
      subTasks: subTasks
    );
  }
}

class SubTask{
  final bool isDone;
  final String subTaskTitle;

  const SubTask({
    required this.isDone,
    required this.subTaskTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'isDone': this.isDone,
      'subTaskTitle': this.subTaskTitle,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      isDone: map['isDone'] as bool,
      subTaskTitle: map['subTaskTitle'] as String,
    );
  }
}