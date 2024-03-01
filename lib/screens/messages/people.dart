import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/anim/bouncy_page_route.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/dialog/sort_users_dialog.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/messages/chat_screen.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/utils.dart';


class People extends StatefulWidget {
  final CurrentUserData userData;
  final MessageService messageService;

  const People({Key? key, required this.userData, required this.messageService})
      : super(key: key);

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {


  String query = '';
  String sortString='all';


  ///filters user list...
  List<CurrentUserData> _filterUsers(List<CurrentUserData> currentUsers) {
    List<CurrentUserData> filteredList = [];
    filteredList = currentUsers
        .where((element) => element.userName
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    return filteredList;
  }


  ///returns the sorted list
  List<CurrentUserData> _sortedList(List<CurrentUserData> currentUsers,String sortString){
    List<CurrentUserData> sortedList=[];
    currentUsers.forEach((element) {
      String userRole=Utils.getUserRole(element.userOrganizations, widget.userData.currentOrganizationId);
      switch(sortString){
        case 'all':
          sortedList.add(element);
          break;
        case 'admin':
          if(userRole=='4') sortedList.add(element);
          break;
        case 'leader':
          if(userRole=='3') sortedList.add(element);
          break;
        case 'member':
          print(userRole);
          if(userRole=='2') sortedList.add(element);
          break;
        case 'guest':
          if(userRole=='1') sortedList.add(element);
          break;
      }
    });
    return sortedList;
  }

  ///shows the sort dialog and sets the sort string
  showSortUserDialog(){
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return SortUserDialog(sort: (OnSortSelected sort){
            setState(() {
              sortString=sort.sortString;
            });
          });
        }).then((value) => null);
  }

  ///gets all the users from provider except current user
  List<CurrentUserData> getUsersForOrganization(MyProvider provider,String orgId) {
    final userList=provider.getCurrentOrganizationUserList(orgId);
    userList.removeWhere((element) => element.uid==widget.userData.uid);
    return userList;
  }

  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<MyProvider>(context);
    final size=MediaQuery.of(context).size;
    final userList=getUsersForOrganization(provider, widget.userData.currentOrganizationId);

    final filteredList=_filterUsers(userList);
    final sortedList=_sortedList(filteredList, sortString);
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: size.width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: textInputDecoration.copyWith(
                        fillColor: Constants.CONTAINER_COLOR,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Constants.BACKGROUND_COLOR,
                        ),
                        hintText: Strings.SEARCH.tr()),
                    onChanged: (val) {
                      setState(() {
                        query = val;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 4),
                child: GestureDetector(
                    onTap: ()=>showSortUserDialog(),
                    child: Icon(Icons.filter_alt,color: Constants.CANCEL_COLOR)),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: sortedList.length,
                itemBuilder: (context, index) {
                  return PeopleTile(
                      person: sortedList[index],
                      currentUserData: widget.userData);
                }),
          ),
        ],
      ),
    );
  }
}



///tile for each person on the page
class PeopleTile extends StatelessWidget {
  final CurrentUserData currentUserData;
  final CurrentUserData person;

  const PeopleTile(
      {Key? key, required this.person, required this.currentUserData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String fullName = '${person.userName} ${person.userSurname}';
    String userRole = Utils.getUserRole(person.userOrganizations, currentUserData.currentOrganizationId);
    String userRoleFromIndex=Utils.getUserRoleFromIndex(userRole);
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          imageUrl: person.userUrl,
          placeholder: (context, url) => new CircularProgressIndicator(),
          errorWidget: (context, url, error) => new Icon(Icons.error),
        ),
      ),
      title: Text(fullName),
      subtitle: Text(userRoleFromIndex),
      trailing: Icon(Icons.navigate_next),
      isThreeLine: true,
      onTap: () {
        Navigator.push(context, SlideInRight(ChatScreen(
            senderOrgId: currentUserData.currentOrganizationId,
            currentUserData: currentUserData,
            chattedUserUid: person.uid,
            roomName: Utils.generateRoomName(currentUserData.uid,person.uid),
          userName: Utils.getUserName(person.userName, person.userSurname) ,
          url: person.userUrl,
        )));
      },
    );
  }
}







