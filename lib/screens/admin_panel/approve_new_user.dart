import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/remove_user_or_block.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:flutter/material.dart';

import '../../shared/constants.dart';
import '../../shared/utils.dart';

//ignore:must_be_immutable
class ApproveNewUser extends StatelessWidget {
  final CurrentUserData currentUserData;
   final Stream<List<CurrentUserData>> getUsersToBeApproved;
  ApproveNewUser({Key? key, required this.currentUserData, required this.getUsersToBeApproved}) : super(key: key);

  AdminServices adminServices = AdminServices();

  //returns all the users who has admins organization id in his/her organization list to be approved
  List<CurrentUserData> getUsersForAdmin(
      List<CurrentUserData> usersToBeApproved) {
    List<CurrentUserData> userList = [];
    usersToBeApproved.forEach((userToBeApproved) {
      userToBeApproved.userOrganizations.forEach((organization) {
        if (organization.organizationId ==
            currentUserData.currentOrganizationId &&
            organization.isApproved == false) {
          if (userToBeApproved.uid != currentUserData.uid) {
            userList.add(userToBeApproved);
          }
        }
      });
    });
    return userList;
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return StreamBuilder<List<CurrentUserData>>(
      stream: getUsersToBeApproved,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userList = snapshot.data!;
          if (userList.length == 0) {
            return Container();
          } else {
            return Container(
              height: size.height*0.3,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    return UserApproveCardTile(
                        userTobeApproved: userList[index],
                        adminOrganizationId:
                        currentUserData.currentOrganizationId);
                  }),
            );
          }
        } else if (snapshot.hasError) {
          return noDataWidget(snapshot.error.toString(), false);
        } else {
          return noDataWidget(null, true);
        }
      },
    );
  }
}

//card tile for user approval
class UserApproveCardTile extends StatefulWidget {
  final CurrentUserData userTobeApproved;
  final String adminOrganizationId;

  const UserApproveCardTile(
      {Key? key,
      required this.userTobeApproved,
      required this.adminOrganizationId})
      : super(key: key);

  @override
  _UserApproveCardTileState createState() => _UserApproveCardTileState();
}

class _UserApproveCardTileState extends State<UserApproveCardTile> {
  final _adminServices = AdminServices();
  final List<String> userRoles = ['guest'.tr(), 'member'.tr(), 'leader'.tr(),'admin'.tr()];
  late String userRole;
  bool isItemSelected = false;

  showApproveDialog() {
    BlurryDialogNew alert = BlurryDialogNew(
        title: "Approve this user?".tr(),
        continueCallBack: approveUser);
    if (!isItemSelected) {
      Utils.showToast(context, 'Select a role'.tr());
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showRemoveDialog() {
    final dialog=RemoveOrBlockUser(
      isFromApprove: true,
      userData: widget.userTobeApproved,
      adminOrgId: widget.adminOrganizationId,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  Future approveUser() async {
    Navigator.of(context).pop();
    await _adminServices.updateApprovedUserCurrentCompanyIdAndArray(
        widget.adminOrganizationId, widget.userTobeApproved, userRole);
    setState(() {
      isItemSelected=false;
    });
  }



  @override
  Widget build(BuildContext context) {
    String userName = widget.userTobeApproved.userName;
    String userSurname = widget.userTobeApproved.userSurname;

    return Card(
      color: Constants.CARD_COLOR,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  imageUrl: widget.userTobeApproved.userUrl,
                  placeholder: (context, url) =>
                      new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
              title: Text(
                '$userName  $userSurname',
                style: TextStyle(color: Colors.black, fontSize: 20),
              )),
          SizedBox(height: 10),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: DropdownButtonFormField(
                hint: Text('User role'.tr()),
                decoration: dropDownDecoration,
                items: userRoles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    userRole = (userRoles.indexOf(val.toString())+1).toString();
                    isItemSelected = true;
                  });
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedCustomButton(
                    text: 'Remove user'.tr(),
                    press: showRemoveDialog,
                    color: Constants.CANCEL_COLOR),
                ElevatedCustomButton(
                    text: 'Approve user'.tr(),
                    press: showApproveDialog,
                    color: Constants.BUTTON_COLOR),
              ],
            ),
          )
        ],
      ),
    );
  }
}
