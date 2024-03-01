import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/extensions/extensions.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/task_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../shared/my_provider.dart';

class TasksScreenViewTasks extends StatelessWidget {

 final  CurrentUserData currentUserData;
 final String userRole;
 final List<String> taskProgress=['Open'.tr(),'In progress'.tr(),'Done'.tr()];
 final List<Task> tasks;
 final TaskServices taskServices;


 TasksScreenViewTasks(

     {Key? key,
   required this.currentUserData,
   required this.userRole,
   required this.tasks,
   required this.taskServices}

   ) : super(key: key);


  List<Task> getTasks(String taskProgress){
    List<Task> tasksToGet=[];
    tasks.forEach((element) {
      if(element.progress==taskProgress){
        tasksToGet.add(element);
      }
    });
    return tasksToGet;
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

 @override
 Widget build(BuildContext context) {
    final provider=Provider.of<MyProvider>(context);
    final size=MediaQuery.of(context).size;
   return Expanded(
     child: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: ExpansionPanelList.radio(
             children: taskProgress.mapIndexed((element, index) {
               return ExpansionPanelRadio(value: element,
                   canTapOnHeader: true,
                   headerBuilder: (context, isExpanded){
                     return buildListTile(element,index);
                   }, body: buildBody(index,context,provider,size));
             }).toList()
         ),
       ),
     ),
   );
 }

 Widget buildListTile(String element,int index){
   final length=getTasks(index.toString()).length.toString();
   Widget widget=Container();
   switch(index){
     case 0:
       widget=ListTile(title: Text(element,style: TextStyle(color: Colors.black26)),trailing: Text(length,style: TextStyle(color: Colors.black26)),);
       break;
     case 1:
       widget=ListTile(title: Text(element,style: TextStyle(color: Colors.green)),trailing: Text(length,style: TextStyle(color: Colors.green)));
       break;
     case 2:
       widget=ListTile(title: Text(element,style: TextStyle(color: Constants.BUTTON_COLOR)),trailing: Text(length,style: TextStyle(color:Constants.BUTTON_COLOR)));
       break;
   }
   return widget;
 }

 Widget buildBody(int index,BuildContext context,MyProvider provider,Size size){
    Widget widget=Container(child: Text(index.toString()),);
    switch(index){
      case 0:
        widget=buildOpenTasks(context,size,provider);
        break;
      case 1:
        widget=buildInProgressTaskTasks(context,provider,size);
        break;
      case 2:
        widget=buildCompletedTaskTasks(context,provider,size);
        break;
    }
    return widget;
 }

 Widget buildAssigneeList(Size size,Task task,MyProvider provider){
    final userList= getUsersFromUid(provider, task.assignees);
    return Container(
      height: 40,
      width: size.width * 0.4,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: userList.length.clamp(0, 4),
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 30,
                  height: 40,
                  imageUrl: userList[index].userUrl,
                  placeholder: (context, url) =>
                  new LinearProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  new Icon(Icons.error),
                ),
              ),
            );
          }),
    );
 }


 Widget buildOpenTasks(BuildContext context,Size size,MyProvider provider){
    final tasks=getTasks('0');
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (_,index){
        final task=tasks[index];
        return GestureDetector(
          onTap: ()=>navigate(task, context),
          child: Card(
              color: Constants.CONTAINER_COLOR,
              child: Padding(
                padding: const EdgeInsets.only(left: 4,right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: size.width*0.7,
                            child: Text(task.taskTitle,style: TextStyle(fontSize: 22),)),
                        userRole=='3'||userRole=='4'?IconButton(onPressed: ()=>navigateToEdit(task,context), icon: Icon(Icons.edit,color: Constants.BUTTON_COLOR))
                            :Container(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 5,),
                        Text(Utils.toDateTranslated(task.dueDate, context))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildAssigneeList(size, task, provider),
                        Row(
                          children: [
                            Text('${task.assignees.length}/${task.maxUsersForOpenTask}'),
                            SizedBox(width: 5),
                            ElevatedCustomButton(
                                text: task.assignees.contains(currentUserData.uid)?'Drop'.tr():'Pick'.tr(),
                                press: (){
                                  task.assignees.contains(currentUserData.uid)?taskServices.dropOpenTaskUserId(currentUserData.uid,task):taskServices.updateOpenTaskUserId(currentUserData.uid,task);
                            }, color: Constants.BACKGROUND_COLOR,textColor: Constants.CANCEL_COLOR),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )),
        );
      },
    );
 }

 Widget buildInProgressTaskTasks(BuildContext context,MyProvider provider,Size size){
   final tasks=getTasks('1');
   return ListView.builder(
     physics: NeverScrollableScrollPhysics(),
     shrinkWrap: true,
     itemCount: tasks.length,
     itemBuilder: (_,index){
       final task=tasks[index];
       return GestureDetector(
         onTap: ()=>navigate(task, context),
         child: Card(
             color: Colors.green[200],
             child: Padding(
               padding: const EdgeInsets.only(left: 4,right: 4),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                           width: size.width*0.7,
                           child: Text(task.taskTitle,style: TextStyle(fontSize: 22),)),
                       userRole=='3'||userRole=='4'?IconButton(onPressed: ()=>navigateToEdit(task,context), icon: Icon(Icons.edit,color: Constants.BUTTON_COLOR))
                           :Container(),
                     ],
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.access_time),
                       SizedBox(width: 5,),
                       Text(Utils.toDateTranslated(task.dueDate, context))
                     ],
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       buildAssigneeList(size, task, provider),
                       Row(
                         children: [
                           Text('${task.assignees.length}/${task.maxUsersForOpenTask}'),
                           SizedBox(width: 5),
                           ElevatedCustomButton(text: 'Complete'.tr(), press: (){
                             taskServices.updateTaskProgress(task.taskId,'2');
                           }, color: Constants.BACKGROUND_COLOR,textColor: Constants.BUTTON_COLOR,)
                         ],
                       )
                     ],
                   ),
                 ],
               ),
             )),
       );
     },
   );
 }

 Widget buildCompletedTaskTasks(BuildContext context,MyProvider provider,Size size){
   final tasks=getTasks('2');
   return ListView.builder(
     physics: NeverScrollableScrollPhysics(),
     shrinkWrap: true,
     itemCount: tasks.length,
     itemBuilder: (_,index){
       final task=tasks[index];
       return GestureDetector(
         onTap: ()=>navigate(task, context),
         child: Card(
             color: Constants.BACKGROUND_COLOR,
             child: Padding(
               padding: const EdgeInsets.only(left: 4,right: 4),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                           width: size.width*0.7,
                           child: Text(task.taskTitle,style: TextStyle(fontSize: 22),)),
                       userRole=='3'||userRole=='4'?IconButton(onPressed: ()=>navigateToEdit(task,context), icon: Icon(Icons.edit,color: Constants.BUTTON_COLOR))
                           :Container(),
                     ],
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.access_time),
                       SizedBox(width: 5,),
                       Text(Utils.toDateTranslated(task.dueDate, context))
                     ],
                   ),
                   buildAssigneeList(size, task, provider),

                 ],
               ),
             )),
       );
     },
   );
 }


 void navigate(Task task,BuildContext context){
    Navigation.navigateToTaskDetail(context, currentUserData, task,taskServices);
 }

 void navigateToEdit(Task task,BuildContext context){
    Navigation.navigateToAddEditTask(context, currentUserData, task);
 }

}


