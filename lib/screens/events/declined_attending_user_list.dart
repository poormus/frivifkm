import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/events/event_chat_widget.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/external_user.dart';

class DeclineAttendUserListScreen extends StatefulWidget {
  final List<String> declinedUids;
  final List<String> attendingUids;
  final List<ExternalUser> externalUsers;
  final String currentOrganizationId;
  final CurrentUserData currentUserData;
  final String eventId;

  const DeclineAttendUserListScreen(
      {Key? key,
      required this.declinedUids,
      required this.attendingUids,
      required this.currentOrganizationId,
      required this.eventId,
      required this.currentUserData, required this.externalUsers})
      : super(key: key);

  @override
  _DeclineAttendUserListScreenState createState() =>
      _DeclineAttendUserListScreenState();
}

class _DeclineAttendUserListScreenState
    extends State<DeclineAttendUserListScreen> {

  String currentTab = 'going';

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarName: 'User list'.tr(), body: body(), shouldScroll: true);
    return buildScaffold('User List', context, body(), null);
  }

  Widget body() {
    final String userRole=Utils.getUserRole(widget.currentUserData.userOrganizations, widget.currentOrganizationId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: Constants.TAB_HEIGHT,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentTab = 'going';
                      });
                    },
                    child: Text('Going'.tr(),
                        style: TextStyle(
                            color: currentTab == 'going'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey))),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentTab = 'decline';
                      });
                    },
                    child: Text(
                      'Declined'.tr(),
                      style: TextStyle(
                          color: currentTab == 'decline'
                              ? Constants.BUTTON_COLOR
                              : Colors.grey),
                    )),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentTab = 'chat';
                      });
                    },
                    child: Text('Chat'.tr(),
                        style: TextStyle(
                            color: currentTab == 'chat'
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
        if (currentTab == 'decline') ...[
          DeclinedUserList(
              declinedUidList: widget.declinedUids,
              currentOrganizationId: widget.currentOrganizationId)
        ] else if (currentTab == 'going') ...[
          AttendingUserList(
              userRole: userRole,
              attendingUidList: widget.attendingUids,
              currentOrganizationId: widget.currentOrganizationId,
              externalUsers: widget.externalUsers,
          )
        ] else ...[
          EventChatScreen(
              currentUserData: widget.currentUserData, eventId: widget.eventId)
        ]
      ],
    );
  }
}

class DeclinedUserList extends StatelessWidget {
  final List<String> declinedUidList;
  final String currentOrganizationId;

  const DeclinedUserList(
      {Key? key,
      required this.declinedUidList,
      required this.currentOrganizationId})
      : super(key: key);

  List<CurrentUserData> getDeclinedUsers(MyProvider provider) {
    List<CurrentUserData> declinedUsers = [];
    final list = provider.getCurrentOrganizationUserList(currentOrganizationId);
    list.forEach((element) {
      if (declinedUidList.contains(element.uid)) {
        declinedUsers.add(element);
      }
    });
    return declinedUsers;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final list = getDeclinedUsers(provider);
    return Expanded(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Constants.CONTAINER_COLOR),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundImage: NetworkImage(list[index].userUrl)),
                  title: Text(
                    '${list[index].userName} ${list[index].userSurname}',
                    style: appTextStyle.copyWith(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(Utils.getUserRoleFromIndex(Utils.getUserRole(
                      list[index].userOrganizations, currentOrganizationId))),
                ),
              ),
            );
          }),
    );
  }
}




class AttendingUserList extends StatelessWidget {
  final List<String> attendingUidList;
  final String currentOrganizationId;
  final List<ExternalUser> externalUsers;
  final String userRole;
  const AttendingUserList(
      {Key? key,
      required this.attendingUidList,
      required this.currentOrganizationId,
        required this.externalUsers,
        required this.userRole})
      : super(key: key);

  List<CurrentUserData> getDeclinedUsers(MyProvider provider) {
    List<CurrentUserData> declinedUsers = [];
    final list = provider.getCurrentOrganizationUserList(currentOrganizationId);
    list.forEach((element) {
      if (attendingUidList.contains(element.uid)) {
        declinedUsers.add(element);
      }
    });
    return declinedUsers;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final list = getDeclinedUsers(provider);
    final size=MediaQuery.of(context).size;
    return Expanded(
      child: Column(
        children: [
          Container(
            height:size.height*0.4 ,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Constants.CONTAINER_COLOR),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(list[index].userUrl)),
                        title: Text(
                          '${list[index].userName} ${list[index].userSurname}',
                          style: appTextStyle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(Utils.getUserRoleFromIndex(Utils.getUserRole(
                            list[index].userOrganizations, currentOrganizationId))),
                      ),
                    ),
                  );
                }),
          ),
          if(userRole=='4')...[
            Text('External users'),
            Expanded(
              child: Container(
                child: ExternalUsersList(externalUsers: externalUsers),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class ExternalUsersList extends StatelessWidget {
  final List<ExternalUser> externalUsers;
  const ExternalUsersList({Key? key, required this.externalUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: externalUsers.length,
          itemBuilder: (context, index){
        final user=externalUsers[index];
        return ListTile(
          leading: Image.asset('assets/frivi_logo.png'),
          title: Text(user.name),
          subtitle: Text(user.email),
        );
      }),
    );
  }
}

