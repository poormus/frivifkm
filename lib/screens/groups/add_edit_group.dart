import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/dialog/select_user_for_channel.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class AddEditGroupScreen extends StatefulWidget {
  final String organizationId;
  final Group? group;
  final CurrentUserData currentUserData;
  AddEditGroupScreen({Key? key, required this.organizationId, this.group, required this.currentUserData})
      : super(key: key);

  @override
  State<AddEditGroupScreen> createState() => _AddEditGroupScreenState();
}

class _AddEditGroupScreenState extends State<AddEditGroupScreen> {
  final groupService = GroupServices();
  late String groupName ;
  late List<CurrentUserData> users;
  late MyProvider provider;


  Future addGroup() async {
    if (groupName.trim().isEmpty) {
      Utils.showSnackBar(context, 'Group name is required'.tr());
    } else if (users.length < 2) {
      Utils.showSnackBar(context, 'Select at least two users'.tr());
    } else {
      if(widget.group==null){
        List<String> uidList = [];
        users.forEach((element) {
          uidList.add(element.uid);
        });
        String leaderUid=uidList[0];
        await groupService
            .addAGroup(widget.organizationId, groupName, uidList,leaderUid,context,widget.currentUserData.uid)
            .catchError((err) =>
            Utils.showSnackBar(context, err.toString()));
      }else{
        List<String> uidList = [];
        users.forEach((element) {
          uidList.add(element.uid);
        });
        String leaderUid=uidList[0];
        await groupService
            .updateAGroup( groupName, uidList,widget.group!.groupId,leaderUid,context)
            .catchError((err) => Utils.showSnackBar(context, err.toString()));
      }
    }
  }

  List<CurrentUserData> getUsersFromGroupId(MyProvider provider,Group group){
    List<CurrentUserData> users=[];
    group.uidList.forEach((uid) {
      provider.allUsersOfOrganization.forEach((user) {
        if(user.uid==uid){
          users.add(user);
        }
      });
    });
    provider.setUserListForGroup(users);
    return users;
  }

  @override
  void initState() {
    groupName=widget.group==null ?'':widget.group!.groupName;
    super.initState();
  }

  @override
  void dispose() {
   provider.setUserListForGroupsToNull();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    provider=Provider.of<MyProvider>(context);
    users=widget.group!=null?getUsersFromGroupId(provider, widget.group!):[];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(appBarName: 'Add/Edit group'.tr(), body: buildBody(size,provider), shouldScroll: false);
    //return buildScaffold('Add/Edit group'.tr(), context, buildBody(size), null);
  }

  showAddUserToGroupDialog(BuildContext context,MyProvider provider) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return SelectUserForChannelDialog(
              orgId: widget.organizationId, userData: users,
            userList: (SelectUser selectUser) {
                setState(() {
                  users=selectUser.userDataList;
                });
            });
        }).then((value) => null);
  }

  Widget buildBody(Size size,MyProvider provider) {
    users=provider.allUsersOfGroup;
    return Column(
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFieldInput(
            initialValue: groupName,
              hintText: 'Group name'.tr(),
              onChangeValue: (s) => groupName=s,
              isDone: true,
              shouldObscureText: false),
        ),
        SizedBox(height: 20),
        CustomTextButton(
            width: size.width * 0.8,
            height: 35,
            text: 'Select users'.tr(),
            textColor: Colors.black,
            containerColor: Constants.BACKGROUND_COLOR,
            press: () {
              showAddUserToGroupDialog(context,provider);
            }),
        SizedBox(height: 20),
        Expanded(
          child: Container(
            width: size.width,
            child: users.length==0?Center(child: Text('No users selected'.tr())): ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(users[index].userUrl),
                      ),
                      subtitle: index==0?Text('Leader'.tr()):null,
                      title: Text(users[index].userName),
                      trailing: IconButton(onPressed: (){
                        setState(() {
                          users.remove(users[index]);
                        });
                      }, icon: Icon(Icons.cancel,color: Constants.CANCEL_COLOR))
                  );
                }),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
           CustomTextButton(width: size.width*0.4, height: 35, text: widget.group==null?'Save'.tr():'Update'.tr(), textColor: Colors.white, containerColor: Constants.BUTTON_COLOR, press: addGroup),
            SizedBox( width: 20,)
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

}
