import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/components/primary_button.dart';
import 'package:firebase_calendar/dialog/update_role.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';


class EditMemberScreen extends StatelessWidget {
  final CurrentUserData userToManage;
  final CurrentUserData admin;
  const EditMemberScreen({Key? key, required this.userToManage, required this.admin}) : super(key: key);


  showUpdateRoleDialog(BuildContext context) {
    UpdateRole alert =
    UpdateRole(title: 'Update user role'.tr(),userData: userToManage,admin: admin);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(appBarName: 'User profile'.tr(), body: buildBody(size,context), shouldScroll: false);
    return buildScaffold('User profile'.tr(), context, buildBody(size,context), null);

  }
  Widget buildBody(Size size,BuildContext context){
    final email = userToManage.email;
    final userPhone = userToManage.userPhone;
    final userName = '${userToManage.userName} ${userToManage.userSurname}';
    final userRole=Utils.getUserRole(userToManage.userOrganizations, admin.currentOrganizationId);
    final userRoleFromIndex=Utils.getUserRoleFromIndex(userRole);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: size.width * 0.3,
                  height: size.height * 0.2,
                  imageUrl: userToManage.userUrl,
                  placeholder: (context, url) =>
                  new LinearProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  new Icon(Icons.error),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width*0.6,
                  child: Text(userName.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: appTextStyle.copyWith(fontSize: 22, color: Colors.black)),
                ),
                Text(
                  userRoleFromIndex,
                  style: appTextStyle.copyWith(color: Colors.black54),
                )
              ],
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text("Email:".tr(), style: textStyle),
              SizedBox(height: 8),
              Text("$email",style: appTextStyle,),
              SizedBox(height: 8),
              Divider(color: Colors.black12, thickness: 1, height: 4),
              SizedBox(height: 8),
              Text('Phone:'.tr(), style: textStyle),
              SizedBox(height: 8),
              Text( userPhone != ''
                  ? "$userPhone"
                  : 'Not given'.tr(),style: appTextStyle,),
              SizedBox(height: 8),
              Divider(color: Colors.black12, thickness: 1, height: 4),
            ],
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PrimaryButton(text: "Recent Activity".tr(), press: (){
                   Navigation.navigateToRecentUserActivity(context,userToManage,admin.currentOrganizationId);
              }, color: Constants.BUTTON_COLOR,),
              PrimaryButton(text: "Edit User".tr(), press: (){
                showUpdateRoleDialog(context);
              }, color: Constants.BUTTON_COLOR,)
            ],
          ),
        )

      ],
    );
  }
}
