import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class SelectUserForGroupDialog extends StatefulWidget {
  final GroupList groupList;
  const SelectUserForGroupDialog({Key? key, required this.groupList})
      : super(key: key);

  @override
  _SelectUserForGroupDialogState createState() =>
      _SelectUserForGroupDialogState();
}

class _SelectUserForGroupDialogState extends State<SelectUserForGroupDialog> {

  List<String> groupData = [];
  bool isGuestTapped=false;
  bool isMemberTapped=false;
  bool isLeaderTapped=false;

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
            height: 430,
            width: size.width * 0.40,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    ListTile(leading: Text('Guests'.tr()),
                    onTap: (){
                     setState(() {
                       isGuestTapped=true;
                     });
                     if(!groupData.contains('1')){
                       groupData.add('1');
                     }
                    },
                      trailing: isGuestTapped?Icon(Icons.check):null,
                    ),
                    ListTile(leading: Text('Members'.tr()),
                      onTap: (){
                        setState(() {
                          isMemberTapped=true;
                        });
                        if(!groupData.contains('2')){
                          groupData.add('2');
                        }
                      },
                      trailing: isMemberTapped?Icon(Icons.check):null,
                    ),
                    ListTile(leading: Text('Leaders'.tr()),
                      onTap: (){
                        setState(() {
                          isLeaderTapped=true;
                        });
                        if(!groupData.contains('3')){
                          groupData.add('3');
                        }
                      },
                      trailing: isLeaderTapped?Icon(Icons.check):null,
                    ),
                    Text('Groups'.tr()),
                    Container(
                      height: size.height*0.2,
                      child: ListView.builder(

                          itemCount: provider.allGroupsOfAnOrganization.length,
                          itemBuilder: (_, index) {
                            return GroupTile(group:provider.allGroupsOfAnOrganization[index],groupData: groupData,);
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedCustomButton(text: 'Add selected'.tr(), press: (){
                          widget.groupList(SelectGroup(groupDataList: groupData));
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

}


class GroupTile extends StatefulWidget {
  final Group group;
  final List<String> groupData;

  const GroupTile({Key? key, required this.group, required this.groupData}) : super(key: key);

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {

  bool isInTheList(){
    bool isInTheList=false;
    if(widget.groupData.contains(widget.group.groupId)){
      isInTheList=true;
    }
    return isInTheList;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(

      leading: Text(widget.group.groupName,style: appTextStyle,),
      trailing: Icon(isInTheList()?Icons.check:null),
      onTap: !isInTheList()?(){
        setState(() {
          widget.groupData.add(widget.group.groupId);
        });
      }:null,
    );
  }
}





class SelectGroup {
  final List<String> groupDataList;

  const SelectGroup({
    required this.groupDataList,
  });
}

typedef GroupList = void Function(SelectGroup selectGroup);





