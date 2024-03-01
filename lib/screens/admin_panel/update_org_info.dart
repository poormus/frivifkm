import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/primary_button.dart';
import '../../services/admin_services.dart';
import '../../shared/constants.dart';
import '../../shared/my_provider.dart';
import '../../shared/utils.dart';

class UpdateOrgInfo extends StatelessWidget {
  final Organization organization;

  UpdateOrgInfo({Key? key, required this.organization}) : super(key: key);

  late String orgNameController;
  late String orgAboutController;
  late String orgContactPersonController;
  late String orgEPostController;
  late String orgMobilController;
  late String orgAddressController;
  late String orgWebsiteController;
  final adminService = AdminServices();

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarName: organization.organizationName,
        body: buildBody(context),
        shouldScroll: true);
  }

  Widget buildBody(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    orgNameController = organization.organizationName;
    orgAboutController = organization.about;
    orgContactPersonController = organization.contactPerson;
    orgEPostController = organization.ePost;
    orgMobilController = organization.mobil;
    orgAddressController = organization.address;
    orgWebsiteController = organization.website;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFieldInput(
                initialValue: organization.organizationName,
                hintText: 'Organization Name'.tr(),
                onChangeValue: (s) {
                  orgNameController = s;
                },
                isDone: false,
                shouldObscureText: false),
            SizedBox(height: 10),
            _buildTextFieldAbout(),
            SizedBox(height: 10),
            TextFieldInput(
                initialValue: organization.contactPerson,
                hintText: 'Contact'.tr(),
                onChangeValue: (s) {
                  orgContactPersonController = s;
                },
                isDone: false,
                shouldObscureText: false),
            SizedBox(height: 10),
            TextFieldInput(
                initialValue: organization.ePost,
                hintText: 'E-post'.tr(),
                onChangeValue: (s) {
                  orgEPostController = s;
                },
                isDone: false,
                shouldObscureText: false),
            SizedBox(height: 10),
            TextFieldInput(
                initialValue: organization.mobil,
                hintText: 'Mobil'.tr(),
                onChangeValue: (s) {
                  orgMobilController = s;
                },
                isDone: false,
                shouldObscureText: false),
            SizedBox(height: 10),
            TextFieldInput(
                initialValue: organization.address,
                hintText: 'Address'.tr(),
                onChangeValue: (s) {
                  orgAddressController = s;
                },
                isDone: false,
                shouldObscureText: false),
            SizedBox(height: 10),
            TextFieldInput(
                initialValue: organization.website,
                hintText: 'Website'.tr(),
                onChangeValue: (s) {
                  orgWebsiteController = s;
                },
                isDone: true,
                shouldObscureText: false),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryButton(
                    text: 'Update'.tr(),
                    press: () {
                      updateOrgInfo(provider,context);
                    },
                    color: Constants.BUTTON_COLOR)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldAbout() {
    return TextFormField(
       minLines: 1,
        maxLines: 5,
        initialValue: orgAboutController,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: 'About'.tr(),
        ),
        onChanged: (val) => orgAboutController = val);
  }

  void updateOrgInfo(MyProvider provider,BuildContext context)async{
    if(orgNameController.trim().isEmpty){
      Utils.showToastWithoutContext('Name can not be empty'.tr());
      return;
    }
    if(orgNameController!=organization.organizationName){
      updateOrgName(provider);
    }
    Navigator.pop(context);
    await adminService.updateOrgInfo(
         organization.organizationId,
         orgAboutController,
         orgContactPersonController,
         orgEPostController,
         orgMobilController,
         orgAddressController,
         orgWebsiteController
    );
  }
  void updateOrgName(MyProvider provider) async {
    await adminService.updateOrgName(
        organization.organizationId, orgNameController.trim(), provider);
  }
}
