import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class SelectUserForGroupDialog extends StatefulWidget {
  final UserList userList;
  final String orgId;

  const SelectUserForGroupDialog({Key? key, required this.userList, required this.orgId})
      : super(key: key);

  @override
  _SelectUserForGroupDialogState createState() => _SelectUserForGroupDialogState();
}

class _SelectUserForGroupDialogState extends State<SelectUserForGroupDialog> {

  String query = '';
  List<CurrentUserData> allUserData = [];
  int clickCounter=0;

  CurrentUserData? selectedLeader;
  bool isLeaderSelected=false;

  void dismissDialog() {
    Future.delayed(const Duration(milliseconds: 200), () {
      // When task is over, close the dialog
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyProvider>(context);
    final size = MediaQuery.of(context).size;
    List<CurrentUserData> userList=[];
    if(isLeaderSelected){
      final newUserList=provider.getCurrentOrganizationUserList(widget.orgId);
      newUserList.remove(selectedLeader);
      userList=newUserList;
    }else{
      userList=provider.getCurrentOrganizationUserList(widget.orgId);
    }

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
            height: size.height * 0.55,
            width: size.width * 0.40,
            child: Stack(
              children: [
                Column(
                  children: [
                    if(!isLeaderSelected)...[
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('No leader selected'.tr())
                      )
                    ]else...[
                      ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(selectedLeader!.userUrl)),
                        title: Text(selectedLeader!.userName),
                        subtitle: Text('Leader'.tr()),
                      )
                    ],
                    Divider(color: Constants.CANCEL_COLOR,thickness: 1,),
                    Container(
                      height: size.height*0.32,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: userList.length,
                          itemBuilder: (_, index) {
                            return buildUserTile(userList[index]);
                            // return SelectUserTile(
                            //     currentUserData: userList[index],
                            //     userList: allUserData,
                            //     clickCounter: clickCounter);
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedCustomButton(text: 'Add Selected Users'.tr(), press: (){
                          widget.userList(SelectUser(userDataList: allUserData));
                          dismissDialog();
                        }, color: Constants.BUTTON_COLOR),
                        SizedBox(width: 20)
                      ],
                    ),
                  ],
                ),
                Align(
                  // These values are based on trial & error method
                  alignment: Alignment(1.1, -1.1),
                  child: InkWell(
                    onTap: () {
                      dismissDialog();
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


 Widget buildUserTile(CurrentUserData currentUserData){
   return ListTile(
       leading: CircleAvatar(
           backgroundImage:
           NetworkImage(currentUserData.userUrl)),
       title: Text(Utils.getUserName(currentUserData.userName, currentUserData.userSurname)),
       trailing: Icon(isInTheList(currentUserData)?Icons.check:null),
       onTap:!isInTheList(currentUserData)?(){
         setState(() {
           isLeaderSelected=true;
           clickCounter++;
           if(clickCounter==1){
             selectedLeader=currentUserData;
           }
           allUserData.add(currentUserData);
         });
       }:(){
         setState(() {
           allUserData.removeWhere((element) => element.uid==currentUserData.uid);
         });
       }
   );
 }

  bool isInTheList(CurrentUserData currentUserData){
    bool isInTheList=false;
    for(var index=0;index<allUserData.length;index++){
      if(allUserData[index].uid==currentUserData.uid){
        isInTheList=true;
        break;
      }
    }
    return isInTheList;
  }
}

//not used
class SelectUserTile extends StatefulWidget {
  final CurrentUserData currentUserData;
  final List<CurrentUserData> userList;
  int clickCounter;
   SelectUserTile({Key? key,
     required this.currentUserData,
     required this.userList,
     required this.clickCounter,
     }) : super(key: key);

  @override
  _SelectUserTileState createState() => _SelectUserTileState();
}

class _SelectUserTileState extends State<SelectUserTile> {


 bool isInTheList(){
   bool isInTheList=false;
   for(var index=0;index<widget.userList.length;index++){
     if(widget.userList[index].uid==widget.currentUserData.uid){
       isInTheList=true;
       break;
     }
   }
   return isInTheList;
 }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          backgroundImage:
          NetworkImage(widget.currentUserData.userUrl)),
      title: Text(Utils.getUserName(widget.currentUserData.userName, widget.currentUserData.userSurname)),
      trailing: Icon(isInTheList()?Icons.check:null),
      subtitle: widget.clickCounter==1 && widget.userList[0].uid==widget.currentUserData.uid?Text('Leader'):null,
      onTap:!isInTheList()?(){
        setState(() {
          widget.clickCounter++;
          widget.userList.add(widget.currentUserData);
        });
      }:(){
        setState(() {
          if(widget.userList.length==1){
            widget.clickCounter=1;
            return;
          }
          widget.userList.removeWhere((element) => element.uid==widget.currentUserData.uid);
        });
      }
    );
  }
}




class SelectUser {
  final List<CurrentUserData> userDataList;

  const SelectUser({
    required this.userDataList,
  });
}

typedef UserList = void Function(SelectUser selectUser);
