import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class ViewChannelMembers extends StatelessWidget {
  final List<String> memberUids;
  final String organizationId;
  const ViewChannelMembers({Key? key, required this.memberUids, required this.organizationId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final size=MediaQuery.of(context).size;
    return BaseScaffold(appBarName: 'Members'.tr(), body: buildBody(provider,size), shouldScroll: false);
    return buildScaffold('Members'.tr(), context, buildBody(provider,size), null);
  }


  Widget buildBody(MyProvider provider,Size size){
    final userList=getUsersForGroup(provider);
    return userList.length==0?noDataWidget('No Data Found', false):
    ListView.builder(
      scrollDirection: Axis.horizontal,
        itemCount: userList.length,
        itemBuilder: (_,index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    imageUrl: userList[index].userUrl,
                    placeholder: (context, url) =>
                    new LinearProgressIndicator(),
                    errorWidget: (context, url, error) =>
                    new Icon(Icons.error),
                  ),
                ),
              ),
              title: Text('${userList[index].userName} ${userList[index].userSurname}'),
            ),
          );

        });
  }

  List<CurrentUserData> getUsersForGroup(MyProvider provider) {
    List<CurrentUserData> groupUsers = [];
    provider
        .getCurrentOrganizationUserList(organizationId)
        .forEach((element) {
      if (memberUids.contains(element.uid)) {
        groupUsers.add(element);
      }
    });
    return groupUsers;
  }
}
