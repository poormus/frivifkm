import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class SelectUserForChannelDialog extends StatefulWidget {
  final List<CurrentUserData> userData;
  final UserList userList;
  final String orgId;

  const SelectUserForChannelDialog({Key? key, required this.userList,
    required this.orgId, required this.userData})
      : super(key: key);

  @override
  _SelectUserForGroupDialogState createState() => _SelectUserForGroupDialogState();
}

class _SelectUserForGroupDialogState extends State<SelectUserForChannelDialog> {

  String query = '';
  List<CurrentUserData> allUserData = [];


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
    List<CurrentUserData> userList=provider.getCurrentOrganizationUserList(widget.orgId);
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
                    Container(
                      height: size.height*0.45,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: userList.length,
                          itemBuilder: (_, index) {
                            return buildUserTile(userList[index]);
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedCustomButton(text: 'Add Selected Users'.tr(), press: (){
                          widget.userList(SelectUser(userDataList: widget.userData));
                          dismissDialog();
                        }, color: Constants.BUTTON_COLOR),

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
           widget.userData.add(currentUserData);
         });
       }:(){
         setState(() {
           widget.userData.removeWhere((element) => element.uid==currentUserData.uid);
         });
       }
   );
 }

  bool isInTheList(CurrentUserData currentUserData){
    bool isInTheList=false;
    for(var index=0;index<widget.userData.length;index++){
      if(widget.userData[index].uid==currentUserData.uid){
        isInTheList=true;
        break;
      }
    }
    return isInTheList;
  }
}






class SelectUser {
  final List<CurrentUserData> userDataList;

  const SelectUser({
    required this.userDataList,
  });
}

typedef UserList = void Function(SelectUser selectUser);
