import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/models/channel.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/no_data_or_progres_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class Channels extends StatelessWidget {

  final CurrentUserData currentUserData;
  final String userRole;
  MessageService service = MessageService();

  Channels({Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: buildBody(context),
        floatingActionButton: buildFab(context),
      ),
    );
  }

  List<CurrentUserData> getUsersForGroup(MyProvider provider, Channel channel) {
    List<CurrentUserData> groupUsers = [];
    provider
        .getCurrentOrganizationUserList(currentUserData.currentOrganizationId)
        .forEach((element) {
      if (channel.membersIds.contains(element.uid)) {
        groupUsers.add(element);
      }
    });

    return groupUsers;
  }

  Widget buildBody(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final size=MediaQuery.of(context).size;
    return StreamBuilder<List<Channel>>(
        stream: service.getChannels(currentUserData.currentOrganizationId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Channel> myChannels = [];
            final channels = snapshot.data;

            if(userRole=='4' || userRole=='3'){
              myChannels=channels!;
            }else {
              channels!.forEach((element) {
                if (element.membersIds.contains(currentUserData.uid)) {
                  myChannels.add(element);
                }
              });
            }
            if (myChannels.length == 0) {
              return NoDataWidget(
                  info: 'No channels found'.tr(), isProgress: false);
            }
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final channel = snapshot.data![index];
                  return buildChannels(channel, context, provider,size);
                });
          } else if (snapshot.hasError) {
            return noDataWidget(snapshot.error.toString(), false);
          } else
            return noDataWidget(null, true);
        });
  }

  Widget buildChannels(
      Channel channel, BuildContext context, MyProvider provider,Size size) {
    final userList = getUsersForGroup(provider, channel);
    return  GestureDetector(
            onTap: () {
              Navigation.navigateToGroupChatScreen(context, channel.channelName,
                  channel.channelId, channel.membersIds, currentUserData);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: Constants.CONTAINER_COLOR,
              child: Column(
                children: [
                  ListTile(
                    title: Text('# ${channel.channelName}', style: appTextStyle),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 50,
                        width: size.width*0.8,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: userList.length,
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 30,
                                    height: 50,
                                    imageUrl: userList[index].userUrl,
                                    placeholder: (context, url) =>
                                    new LinearProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                    new Icon(Icons.error),
                                  ),
                                ),
                              );
                            }),
                      ),
                      userRole=='3' || userRole=='4'?IconButton(onPressed: (){
                        Navigation.navigateToAddChannel(context, channel.organizationId, channel);
                      },
                          icon: Icon(Icons.edit,color: Constants.CANCEL_COLOR,)):Container()
                    ],
                  )
                ],
              ),
            ),
          );
  }

  Widget? buildFab(BuildContext context) {
    return userRole == '4' || userRole == '3'
        ? FloatingActionButton(
            backgroundColor: Constants.BUTTON_COLOR,
            onPressed: () {
              Navigation.navigateToAddChannel(
                  context, currentUserData.currentOrganizationId, null);
            },
            child: Icon(Icons.add),
          )
        : null;
  }
}
