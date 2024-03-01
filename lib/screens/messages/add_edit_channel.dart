import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/dialog/select_user_for_channel.dart';
import 'package:firebase_calendar/models/channel.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dialog/select_user_for_channel.dart';

class AddEditChannel extends StatefulWidget {
  final String organizationId;
  final Channel? channel;

  AddEditChannel({Key? key, required this.organizationId, this.channel})
      : super(key: key);

  @override
  State<AddEditChannel> createState() => _AddEditChannel();
}

class _AddEditChannel extends State<AddEditChannel> {
  final messageServices = MessageService();
  late String channelName;

  late List<CurrentUserData> users;

  late MyProvider provider;


  Future addChannel() async {
    if (channelName.trim().isEmpty) {
      Utils.showSnackBar(context, 'Channel name is required'.tr());
    } else if (users.length < 3) {
      Utils.showSnackBar(context, 'Select at least three users'.tr());
    } else {
      if (widget.channel == null) {
        List<String> uidList = [];
        users.forEach((element) {
          uidList.add(element.uid);
        });
        await messageServices.createChannel(widget.organizationId, channelName, uidList,context);
      } else {
        List<String> uidList = [];
        users.forEach((element) {
          uidList.add(element.uid);
        });
        await messageServices.updateChannel( channelName,
            uidList,context,widget.channel!.channelId,widget.channel!.membersIds);
      }
    }
  }

  @override
  void initState() {
    channelName = widget.channel == null ? '' : widget.channel!.channelName;
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
    users=widget.channel!=null?getUsersFromMemberId(provider, widget.channel!):[];
    super.didChangeDependencies();
  }
  List<CurrentUserData> getUsersFromMemberId(MyProvider provider,Channel channel){
    List<CurrentUserData> users=[];
    channel.membersIds.forEach((uid) {
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(appBarName: 'Add/Edit channel'.tr(), body: buildBody(size, context), shouldScroll: false);
    return buildScaffold(
        'Add/Edit channel'.tr(), context, buildBody(size, context), null);
  }

  showAddUserToGroupDialog(BuildContext context) {
     showDialog(context: context, builder: (context){
       return SelectUserForChannelDialog(userData: users,orgId:widget.organizationId, userList: (SelectUser selectUser) {
         setState(() {
           users=selectUser.userDataList;
         });
       });
     });
  }

  Widget buildBody(Size size, BuildContext context) {
    users=provider.allUsersOfGroup;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFieldInput(
                initialValue: channelName,
                hintText: 'Channel name'.tr(),
                onChangeValue: (s) => channelName = s,
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
                showAddUserToGroupDialog(context);
              }),
          SizedBox(height: 20),
          Flexible(
            child: Container(
              width: size.width,
              child: users.length==0?Center(child: Text('No users selected'.tr()),):ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(users[index].userUrl),
                        ),
                        title: Text(users[index].userName),
                      trailing: IconButton(onPressed: (){
                        setState(() {
                          users.remove(users[index]);
                        });
                      }, icon: Icon(Icons.cancel,color: Constants.CANCEL_COLOR)),

                    );
                  }),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomTextButton(
                  width: size.width * 0.4,
                  height: 35,
                  text: widget.channel == null ? 'Save'.tr() : 'Update'.tr(),
                  textColor: Colors.white,
                  containerColor: Constants.BUTTON_COLOR,
                  press: addChannel),
              SizedBox(
                width: 20,
              )
            ],
          ),
          SizedBox(height: 5)
        ],
      ),
    );
  }
}
