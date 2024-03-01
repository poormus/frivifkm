import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/user_companies.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/services/version.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

class UseCodeToAddOrganization extends StatefulWidget {
  final CurrentUserData currentUserData;
  String? linkOrgId;
  UseCodeToAddOrganization({Key? key, required this.currentUserData,this.linkOrgId})
      : super(key: key);

  @override
  State<UseCodeToAddOrganization> createState() =>
      _UseCodeToAddOrganizationState();
}

class _UseCodeToAddOrganizationState extends State<UseCodeToAddOrganization> {

  late String organizationId;

  bool isCalled = false;

  final versionCheck = VersionCheck();

  final auth=AuthService();

  final orgUrlController = TextEditingController();

  final orgNameController = TextEditingController();

  final codeController = TextEditingController();

  @override
  void initState() {
    if(widget.linkOrgId!=null){
      organizationId=widget.linkOrgId!;
      codeController.text=organizationId;
      handleOrgPress();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Use code'.tr(), body: buildBody(context, size), shouldScroll: false);
  }

  Widget buildBody(BuildContext context, Size size) {
    return Column(
      children: [
        SizedBox(height: 20),
        Container(
          width: size.width * 0.9,
          child: TextFieldInput(
              controller: codeController,
              hintText: Strings.CODE.tr(),
              onFieldSubmitted: (val) {},
              onChangeValue: (s) {},
              isDone: true,
              shouldObscureText: false),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextButton(
                width: size.width * 0.4,
                height: 35,
                text: 'Submit code'.tr(),
                textColor: Colors.white,
                containerColor: Constants.BUTTON_COLOR,
                press: () =>handleOrgPress()
            )
          ],
        ),
        SizedBox(height: 20),
        if (isCalled) ...[
          getOrganizationFromCode(
                  orgUrlController.text, orgNameController.text, size) ??
              Container(),
        ],
        SizedBox(height: 6),
      ],
    );
  }

  Widget? getOrganizationFromCode(String? orgUrl, String orgName, Size size) {
    if (orgUrl != null) {
      return Column(
        children: [
          Container(
            height: 200,
            width: size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.green,
                shape: BoxShape.circle,

                image: DecorationImage(fit: BoxFit.cover,image: NetworkImage(orgUrl))),
          ),
          SizedBox(height: 10),
          Text(orgName),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomTextButton(
                  width: 60,
                  height: 35,
                  text: 'Ok'.tr(),
                  textColor: Colors.white,
                  containerColor: Constants.BUTTON_COLOR,
                  press: () {
                    final userOrgs = widget.currentUserData.userOrganizations;
                    for (var i = 0; i < userOrgs.length; i++) {
                      if (userOrgs[i].organizationId == organizationId) {
                        Utils.showToastWithoutContext('Already joined/Waiting approval'.tr());
                        return;
                      }
                    }
                    updateUserOrganizationList();
                  }),
              SizedBox(width: 30)
            ],
          ),
        ],
      );
    }
  }


  Future updateUserOrganizationList() async{
     final userOrg=UserOrganizations(organizationId: organizationId, organizationName: orgNameController.text.trim(), organizationUrl: orgUrlController.text.trim(), isApproved: false, userRole: '');
     await auth.updateUserOrgListForCode(widget.currentUserData.uid,userOrg);
     Navigator.pop(context);
  }

  handleOrgPress() {
    if(codeController.text.toString().trim()==''){
      return;
    }
    Utils.showToastWithoutContext('Checking'.tr());
    final organization = versionCheck.getOrganizationFromCode(
        codeController.text.trim().replaceAll(" ", ""));
    organization.then((value) {
      if(value.blockedUsers.contains(widget.currentUserData.uid)){
        Utils.showToastWithoutContext(
            'You have been blocked by this organization'.tr());
        return;
      }
      setState(() {
        organizationId = value.organizationId;
        orgUrlController.text = value.organizationUrl;
        orgNameController.text = value.organizationName;
        isCalled = true;
      });
    }).onError((error, stackTrace) =>
        Utils.showToastWithoutContext(
            'Organization not found'.tr()));
  }

}
