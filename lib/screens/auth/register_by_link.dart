import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/services/version.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

class RegisterByLink extends StatefulWidget {

  final AuthService authService;
  bool? isFromLink;
  String? orgIdFromLink;
  RegisterByLink({Key? key, required this.authService,this.isFromLink,this.orgIdFromLink}) : super(key: key);

  @override
  State<RegisterByLink> createState() => _RegisterByLinkState();
}

class _RegisterByLinkState extends State<RegisterByLink> {
  String emailSignUp = '';

  String passwordSignUp = '';

  String nameSignUp = '';

  String surnameSignUp = '';

  String error = '';

  String organizationId = '';

  bool isLoading = false;

  bool isCalled = false;

  final versionCheck = VersionCheck();
  final orgUrlController = TextEditingController();
  final orgNameController = TextEditingController();
  final codeController = TextEditingController();

  bool isAgeChecked = false;

  updateUi(bool loading){
    setState(() {
      isLoading=loading;
    });
  }

  @override
  void initState() {
    if(widget.isFromLink!=null && widget.isFromLink==true){
      codeController.text=widget.orgIdFromLink!;
      handleOrgCode();
    }
    super.initState();
  }

  Future register() async {
    if (organizationId == '') {
      Utils.showSnackBar(context, 'Organization not found'.tr());
      return;
    } else if (!isAgeChecked) {
      Utils.showSnackBar(context, 'Confirm that you are older than 16'.tr());
      return;
    }

    List<Organization> userOrganizations = [];
    final organization = Organization(
        organizationId: organizationId,
        organizationName: orgNameController.text,
        organizationUrl: orgUrlController.text,
        admins: [],
        organizationNumber: '',
        isApproved: false,
        currentUserCount: 0,
        targetUserCount: 0,
        subLevel: '',
        blockedUsers: [],
        website: '',
        mobil: '',
        ePost: '',
        contactPerson: '',
        about: '',
        address: '');
    userOrganizations.add(organization);
    if (Utils.validateRegister(emailSignUp.trim().replaceAll(" ", ""),
        passwordSignUp, nameSignUp, surnameSignUp, context)) {
      updateUi(true);
      await widget.authService
          .registerWithEmailAndPassword(emailSignUp.trim().replaceAll(" ", ""),
              passwordSignUp, nameSignUp, surnameSignUp, userOrganizations)
          .then((onSuccess) {
        updateUi(false);
        Navigator.pushReplacementNamed(context, '/home');
      }).catchError((err) {
        updateUi(false);
        error = err.toString();
        Utils.showSnackBar(context, error);
      }).onError((error, stackTrace) {
        updateUi(false);
      });
    }
  }
  void handleOrgCode(){
    if (codeController.text.toString().trim() == '') {
      return;
    }
    Utils.showToastWithoutContext('Checking'.tr());
    final organization = versionCheck.getOrganizationFromCode(
        codeController.text.trim().replaceAll(" ", ""));
    organization
        .then((value) => setState(() {
      organizationId = value.organizationId;
      orgUrlController.text = value.organizationUrl;
      orgNameController.text = value.organizationName;
      isCalled = true;
    }))
        .onError((error, stackTrace) =>
        Utils.showToastWithoutContext(
            'Organization not found'.tr()));
  }

  @override
  void dispose() {
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Register via code'.tr(),
        body: buildBody(context, size),
        shouldScroll: true);
    // return buildBody(context, size);
  }

  Widget buildBody(BuildContext context, Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            TextFieldInput(
                controller: codeController,
                hintText: Strings.CODE.tr(),
                onFieldSubmitted: (val) {},
                onChangeValue: (s) {},
                isDone: true,
                shouldObscureText: false),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    final dialog = BlurryDialog(
                        title: 'Info'.tr(),
                        content:
                            'Paste the code you received from an organization to join to that specific organization(if the code is valid you can see the organization info below the text field)'
                                .tr(),
                        continueCallBack: () {
                          Navigator.pop(context);
                        });
                    showDialog(
                        context: context,
                        builder: (_) {
                          return dialog;
                        });
                  },
                  child: Text(Strings.WHAT_IS_THIS.tr(),
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextButton(
                    width: size.width * 0.4,
                    height: 35,
                    text: 'Submit code'.tr(),
                    textColor: Colors.white,
                    containerColor: Constants.BUTTON_COLOR,
                    press: () =>handleOrgCode()
                    )
              ],
            ),
            SizedBox(height: 6),
            isCalled?
              getOrganizationFromCode(
                      orgUrlController.text, orgNameController.text, size) :
                  Container(),
            SizedBox(height: 6),
            TextFieldInput(
                textInputType: TextInputType.emailAddress,
                autoCorrect: false,
                hintText: Strings.EMAIL.tr(),
                onChangeValue: (s) => emailSignUp = s,
                isDone: false,
                shouldObscureText: false),
            SizedBox(height: 6),
            TextFieldInput(
                textInputType: TextInputType.visiblePassword,
                hintText: Strings.PASSWORD.tr(),
                onChangeValue: (s) => passwordSignUp = s,
                isDone: false,
                shouldObscureText: true),
            SizedBox(height: 6),
            TextFieldInput(
                hintText: Strings.USER_NAME.tr(),
                onChangeValue: (s) => nameSignUp = s,
                isDone: false,
                shouldObscureText: false),
            SizedBox(height: 6),
            TextFieldInput(
                hintText: Strings.USER_SURNAME.tr(),
                onChangeValue: (s) => surnameSignUp = s,
                isDone: true,
                shouldObscureText: false),
            SizedBox(height: 5),
            ListTile(
                leading: Checkbox(
                  activeColor: Constants.CANCEL_COLOR,
                  value: isAgeChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isAgeChecked = value!;
                    });
                  },
                ),
                title: Text('I accept that I am older than 16'.tr()),
                subtitle: GestureDetector(
                  onTap: () {
                    Utils.showPoliciesDialog(context);
                  },
                  child: Text(
                      'I agree to the Terms and Conditions and Privacy Policy.'
                          .tr(),
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blueAccent)),
                )),
            SizedBox(height: 5),
            CustomTextButton(
                width: size.width * 0.9,
                height: 35,
                text: 'Register'.tr(),
                textColor: Colors.white,
                containerColor: Constants.BUTTON_COLOR,
                press: isLoading ? () {} : () => register()),
            SizedBox(height: 10),
            Container(
                width: size.width * 0.5,
                child: isLoading ? LinearProgressIndicator() : null)
          ],
        ),
      ),
    );
  }

  Widget getOrganizationFromCode(String? orgUrl, String orgName, Size size) {
    if (orgUrl != null) {
      return Column(
        children: [
          Container(
            height: 100,
            width: size.width * 0.8,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.scaleDown, image: NetworkImage(orgUrl))),
          ),
          SizedBox(height: 10),
          Text(orgName)
        ],
      );
    } else return Container();
  }
}
