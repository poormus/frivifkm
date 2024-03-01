import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

//ignore: must_be_immutable
class CreateGroupScreen extends StatelessWidget {
  final String appUserId;
  final String organizationId;
  final String userRole;
  final CurrentUserData currentUserData;
  GroupServices groupServices = GroupServices();

  CreateGroupScreen(
      {Key? key,
      required this.organizationId,
      required this.userRole,
      required this.appUserId,
      required this.currentUserData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffold(
        appBarName: 'Groups'.tr(),
        body: buildBody(provider),
        shouldScroll: false,
        floatingActionButton: buildFab(context, provider));
  }

  Widget buildBody(MyProvider provider) {
    return StreamBuilder<List<Group>>(
        stream: groupServices.getGroupsForOrganization(organizationId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final myGroups = snapshot.data!;
            if (myGroups.length == 0) {
              return noDataWidget('No groups found'.tr(), false);
            } else {
              return ListView.builder(
                  itemCount: myGroups.length,
                  itemBuilder: (context, index) {
                    return GroupListTile(
                      userRole: userRole,
                      provider: provider,
                      group: myGroups[index],
                      index: index,
                      appUserId: appUserId,
                      currentUserData: currentUserData,
                    );
                  });
            }
          } else if (snapshot.hasError) {
            return noDataWidget(snapshot.error.toString(), false);
          } else {
            return noDataWidget(null, true);
          }
        });
  }

  Widget? buildFab(BuildContext context, MyProvider provider) {
    return userRole == '4' || userRole == '3'
        ? AvatarGlow(
            animate: true,
            repeat: true,
            glowColor: Constants.BUTTON_COLOR,
            child: FloatingActionButton(
              backgroundColor: Constants.BUTTON_COLOR,
              onPressed: () {
                //provider.setUserListForGroup([]);
                Navigation.navigateToAddEditGroupScreen(
                    context, organizationId, null, currentUserData);
              },
              child: Icon(Icons.add),
            ),
          )
        : null;
  }
}

class GroupListTile extends StatelessWidget {
  final Group group;
  final int index;
  final String appUserId;
  final MyProvider provider;
  final CurrentUserData currentUserData;
  final String userRole;

  const GroupListTile(
      {Key? key,
      required this.group,
      required this.index,
      required this.appUserId,
      required this.provider,
      required this.currentUserData,
      required this.userRole})
      : super(key: key);

  void showDeleteGroupDialog(BuildContext context) {
    final groupServices = GroupServices();
    BlurryDialogNew dialog = BlurryDialogNew(
        title: 'Delete this group?'.tr(),
        continueCallBack: () async {
          await groupServices
              .deleteAGroup(group.groupId, group.uidList)
              .catchError((err) => Utils.showToast(context, err.toString()));
          Navigator.pop(context);
        });
    showDialog(
        context: context,
        builder: (_) {
          return dialog;
        });
  }

  void createChannelFromGroup(BuildContext context, Group group) {
    if (group.uidList.length <= 2) {
      Utils.showToastWithoutContext(
          'At least three users required for channel'.tr());
      return;
    }
    final messageService = MessageService();
    showDialog(
        context: context,
        builder: (context) {
          return BlurryDialogNew(
              title: 'Create channel ?'.tr(),
              continueCallBack: () {
                messageService.createChannel(group.organizationId,
                    group.groupName, group.uidList, context);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final leader = getLeaderInfo(group.leaderUid, provider);
    return GestureDetector(
      onTap: () {
        Navigation.navigateToViewGroupMembersScreen(
            group.uidList, group, context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Constants.CONTAINER_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(group.groupName,
                      style: appTextStyle.copyWith(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      imageUrl: leader.userUrl,
                      placeholder: (context, url) =>
                          new LinearProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text('${leader.userName} ${leader.userSurname}'),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                userRole == '4' || group.createdBy == currentUserData.uid
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(),
                          IconButton(
                            onPressed: () {
                              createChannelFromGroup(context, group);
                            },
                            icon: Icon(
                              Icons.chat,
                              color: Colors.blueAccent,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigation.navigateToAddEditGroupScreen(context,
                                  group.organizationId, group, currentUserData);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Constants.BUTTON_COLOR,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDeleteGroupDialog(context);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Constants.CANCEL_COLOR,
                            ),
                          ),
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  CurrentUserData getLeaderInfo(String leaderUid, MyProvider provider) {
    final list = provider.getCurrentOrganizationUserList(group.organizationId);
    CurrentUserData currentUserData = list[1];
    for (var index = 0; index < list.length; index++) {
      if (list[index].uid == leaderUid) {
        currentUserData = list[index];
      }
    }
    return currentUserData;
  }

  ///not used....
// Widget buildMembersList(BuildContext context, MyProvider provider) {
//   final size = MediaQuery.of(context).size;
//   final list = getUsersForGroup(provider);
//   return Container(
//       width: size.width * 0.8,
//       height: 85,
//       child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: list.length,
//           itemBuilder: (context, index) {
//             return Padding(
//               padding: const EdgeInsets.all(6.0),
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     backgroundImage: NetworkImage(list[index].userUrl),
//                   ),
//                   Text(list[index].userName),
//                   if (index == 0) ...[
//                     Text('(leader)'),
//                   ]
//                 ],
//               ),
//             );
//           }));
// }
}
