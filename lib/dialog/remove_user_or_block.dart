import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';


class RemoveOrBlockUser extends StatelessWidget {

  final String adminOrgId;
  final CurrentUserData userData;
  final bool isFromApprove;
  final adminService = AdminServices();
  RemoveOrBlockUser({Key? key, required this.adminOrgId,required this.userData, required this.isFromApprove}) : super(key: key);


  Future removeUser(bool isBlocked,BuildContext context)async{
    final userRole=Utils.getUserRole(userData.userOrganizations, adminOrgId);
    bool isAdminRemoved=userRole=='4';
    if(isFromApprove){
      await adminService.removeUserFromOrganization(adminOrgId, userData,isBlocked);
      Navigator.pop(context);
    }else{
      await adminService.removeUserFromOrganizationManage(adminOrgId,userData,isBlocked,isAdminRemoved);
      int count=0;
      while(count<3){
        count++;
        Navigator.pop(context);
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      backgroundColor: Constants.BACKGROUND_COLOR,
      child: Container(
          height: 190,
          child: Stack(
            children: [
              Align(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Remove'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          removeUser(false,context);
                        }),
                    SizedBox(height: 25),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Remove & Block'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          removeUser(true,context);
                        })
                  ],
                ),
              ),
              Align(
                // These values are based on trial & error method
                alignment: Alignment(1.1, -1.1),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Constants.CANCEL_COLOR,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          )

      ),
    );
  }
}
