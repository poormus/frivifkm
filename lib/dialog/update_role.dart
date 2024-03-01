import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/remove_user_or_block.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

class UpdateRole extends StatefulWidget {
  final String title;
  final CurrentUserData userData;
  final CurrentUserData admin;

  const UpdateRole(
      {Key? key,
      required this.title,
      required this.userData,
      required this.admin})
      : super(key: key);

  @override
  _UpdateRoleState createState() => _UpdateRoleState();
}

class _UpdateRoleState extends State<UpdateRole> {
  final List<String> userRoles = ['guest'.tr(), 'member'.tr(), 'leader'.tr(),'admin'.tr()];
  late String userRole;
  bool isItemSelected = false;

  final adminService = AdminServices();

  Future updateRole() async {
    if(!isItemSelected){
      Utils.showToast(context, 'Select a role'.tr());
    }else{
      await adminService.updateUserRole(
          widget.admin.currentOrganizationId, userRole, widget.userData.uid);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  Future removeUser() async {
    showDialog(context: context, builder: (context){
      return RemoveOrBlockUser(adminOrgId: widget.admin.currentOrganizationId,userData: widget.userData,isFromApprove: false);
    });

    // Navigator.pop(context);
    // Navigator.pop(context);
    // await adminService.removeUserFromOrganizationManage(
    //     widget.admin.currentOrganizationId, widget.userData);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Constants.BACKGROUND_COLOR,
      child:Container(
        height: 170,
          child: Column(
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                    imageUrl: widget.userData.userUrl,
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                ),
                title: Text(widget.userData.userName),
              ),
              DropdownButtonFormField(
                  hint: Text('User role'.tr()),
                  decoration: dropDownDialogDecoration,
                  items: userRoles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (val) {
                      userRole = (userRoles.indexOf(val.toString())+1).toString();
                      isItemSelected = true;
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedCustomButton(text: 'Remove user'.tr(), press: removeUser, color: Constants.CANCEL_COLOR),
                  ElevatedCustomButton(text: 'Update user'.tr(), press: updateRole, color: Constants.BUTTON_COLOR)
                ],
              )
            ],
          )
      ),

    );
  }
}
