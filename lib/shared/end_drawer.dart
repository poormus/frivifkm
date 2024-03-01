
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_with_title.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/user_companies.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialog/select_new_organization_dialog.dart';
import '../services/auth_service.dart';
import 'constants.dart';
import 'drawer_menu_tile.dart';
import 'my_provider.dart';
import 'navigation.dart';


class EndDrawer extends StatelessWidget {
  final CurrentUserData currentUserData;
  final AuthService _auth = AuthService();
  final AdminServices admin=AdminServices();

  EndDrawer({Key? key, required this.currentUserData}) : super(key: key);



  //this function is called whenever user tries to select a new organization so that it is populated
  //with already approved or not  organization as selected
  void addCurrentUserOrganizationsToList(
      BuildContext context, MyProvider provider) {
    List<String> organizations = [];
    currentUserData.userOrganizations.forEach((element) {
      organizations.add(element.organizationId);
    });
    provider.setAlreadyJoinedUserOrganizations(organizations);
  }

  showSelectNewOrganizationDialog(MyProvider provider,BuildContext context) {
    addCurrentUserOrganizationsToList(context, provider);
    final selectNewOrganization = SelectNewOrganization(
        uid: currentUserData.uid,
        currentUserData: currentUserData);
    showDialog(context: context, builder: (_) => selectNewOrganization)
        .whenComplete(() {
      provider.alreadyJoinedOrganizations.clear();
      provider.selectedOrganizations.clear();
    });
  }


  void updateUi(){

  }
  @override
  Widget build(BuildContext context) {
    final userOrgs=currentUserData.userOrganizations.where((element) => element.isApproved==true).toList();
    final provider=Provider.of<MyProvider>(context);
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Drawer(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: [
                  Text('Organizations'.tr(),style: appTextStyle.copyWith(fontSize: 22,fontWeight: FontWeight.bold),),
                  SizedBox(height: 10),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Constants.BUTTON_COLOR,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        )),
                    title: Text(
                      Strings.SELECT_NEW_ORGANIZATION.tr(),
                      style: appTextStyle,
                    ),
                    onTap: () {
                      showSelectNewOrganizationDialog(provider,context);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: userOrgs.length,
                        itemBuilder:(_,index){
                      return  ListTile(
                        selected: currentUserData.currentOrganizationId==userOrgs[index].organizationId,
                        selectedColor: Constants.CANCEL_COLOR,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            imageUrl: userOrgs[index].organizationUrl,
                            placeholder: (context, url) =>
                                Center(child: new CircularProgressIndicator()),
                            errorWidget: (context, url, error) => new Icon(Icons.error),
                          ),
                        ),
                        title: Text(userOrgs[index].organizationName),
                        trailing: buildPopup(context,userOrgs[index]),
                        onTap: (){
                          if (userOrgs[index].organizationId == currentUserData.currentOrganizationId) {
                            return;
                          }
                          _auth.updateCurOrganizationForUser(
                              currentUserData.uid, userOrgs[index].organizationId, context);
                        },
                      );
                    }),
                  ),
                  DrawerMenuTile(
                      title: Strings.SETTINGS.tr(),
                      icon: Icons.settings,
                      onTap: () {
                        Navigation.navigateToSettings(context,currentUserData);
                      })
                ],
              ),
            )),
      ),
    );
  }

  Widget buildPopup(BuildContext context,UserOrganizations organization){
    return PopupMenuButton(
        onSelected: (value) {
           switch(value.toString()){
             case 'leave':
               showLeaveDialog(context,organization);
               break;
           }
         },
        color: Constants.BACKGROUND_COLOR,
        icon: Icon(Icons.more_vert, color: Constants.CANCEL_COLOR),
        itemBuilder: (context) => [
          PopupMenuItem(height: 20,child: Text('Leave'.tr()),value: 'leave',)
        ]);
  }

  void showLeaveDialog(BuildContext context,UserOrganizations organization) {
    String userRole=organization.userRole;
    if(userRole=='4'){
      final dialog=BlurryDialogWithTitle(title: 'You are admin'.tr(), continueCallBack:()=>Navigator.pop(context),
          content: 'Admin can not leave organization'.tr());
      showDialog(context: context, builder: (_){
        return dialog;
      });
    }else{
      final dialog=BlurryDialogNew(title: 'Leave ?'.tr(), continueCallBack: (){
        admin.removeUserFromOrganizationManage(currentUserData.currentOrganizationId, currentUserData, false,false);
      });
      showDialog(context: context, builder: (_){
        return dialog;
      });
    }
  }

}
