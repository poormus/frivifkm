import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/dialog/sort_users_dialog.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'approve_new_user.dart';

class ManageMembers extends StatefulWidget {
  final CurrentUserData currentUserData;
  const ManageMembers({Key? key, required this.currentUserData}) : super(key: key);

  @override
  _ManageMembersState createState() => _ManageMembersState();
}

class _ManageMembersState extends State<ManageMembers> {

  final AdminServices adminServices=AdminServices();
  late Stream<List<CurrentUserData>> getUsers;
  late Stream<List<CurrentUserData>> getUsersToBeApproved;
  String query = '';
  String sortString='all';


  @override
  void initState() {
    getUsers=adminServices.getUsersForOrganization(widget.currentUserData.currentOrganizationId);
    getUsersToBeApproved=adminServices.getUsersToBeApproved(widget.currentUserData.currentOrganizationId);
    super.initState();
  }

  //returns all the users who has admins organization id in his/her organization list as approved
  List<CurrentUserData> getUsersForAdmin(List<CurrentUserData> usersToBeApproved){
    List<CurrentUserData> userList=[];
    usersToBeApproved.forEach((userToBeApproved) {
      if(userToBeApproved.uid!=widget.currentUserData.uid){
        userList.add(userToBeApproved);
      }
    });
    return userList;
  }
  List<CurrentUserData> _filterUsers(List<CurrentUserData> currentUsers) {
    List<CurrentUserData> filteredList = [];
    filteredList = currentUsers
        .where((element) => element.userName
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    return filteredList;
  }
  List<CurrentUserData> _sortedList(List<CurrentUserData> currentUsers,String sortString){
    List<CurrentUserData> sortedList=[];
    currentUsers.forEach((element) {
      String userRole=Utils.getUserRole(element.userOrganizations, widget.currentUserData.currentOrganizationId);
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

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    final provider=Provider.of<MyProvider>(context);
    return  StreamBuilder<List<CurrentUserData>>(
      stream: getUsers,
      builder:(context,snapshot){
        if(snapshot.hasData){
          final userList=getUsersForAdmin(snapshot.data!);
          if(userList.length==0){
            return Column(
              children: [
                ApproveNewUser(currentUserData: widget.currentUserData,getUsersToBeApproved: getUsersToBeApproved),
                noDataWidget("No users yet".tr(), false),
              ],
            );
          }else{
            provider.setUserList(userList);
            provider.addCurrentUserIfAbsent(widget.currentUserData);
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
                  ApproveNewUser(currentUserData: widget.currentUserData,getUsersToBeApproved: getUsersToBeApproved),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: sortedList.length,
                        itemBuilder: (context,index){
                          return UserTileManage(person: sortedList[index],admin: widget.currentUserData,);
                        }),
                  ),
                ],
              ),
            );
          }
        }else if(snapshot.hasError){
          return noDataWidget(snapshot.error.toString(), false);
        }else{
          return noDataWidget(null,true);
        }
      },
    );
  }
}


///user Tile
class UserTileManage extends StatelessWidget {
  final CurrentUserData person;
  final CurrentUserData admin;
  const UserTileManage({Key? key, required this.person, required this.admin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRole=Utils.getUserRole(person.userOrganizations, admin.currentOrganizationId);
    final userRoleFromIndex=Utils.getUserRoleFromIndex(userRole);
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          width: 30,
          height: 30,
          imageUrl: person.userUrl,
          placeholder: (context, url) => new CircularProgressIndicator(),
          errorWidget: (context, url, error) => new Icon(Icons.error),
        ),
      ),
      title: Text(Utils.getUserName(person.userName, person.userSurname)),
      subtitle: Text(userRoleFromIndex),
      trailing: Icon(Icons.arrow_forward_ios_sharp,color: Constants.CANCEL_COLOR,),
      onTap: (){
        // if(admin.uid==person.uid){
        //   Utils.showSnackBar(context, 'This is you'.tr());
        //   return;
        // }
        // if(userRole=='4'){
        //   Utils.showSnackBar(context, 'Can not edit admin'.tr());
        //   return;
        // }
        Navigation.navigateToEditMemberScreen(context, person, admin);
      },
    );
  }
}




