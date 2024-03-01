import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/dialog/select_image_dialog.dart';
import 'package:firebase_calendar/models/api_model.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../api.dart';

class RegisterOrganizationAsAnAdmin extends StatefulWidget {
  const RegisterOrganizationAsAnAdmin({Key? key}) : super(key: key);

  @override
  State<RegisterOrganizationAsAnAdmin> createState() =>
      _RegisterOrganizationAsAnAdminState();
}

class _RegisterOrganizationAsAnAdminState
    extends State<RegisterOrganizationAsAnAdmin> {
  final api = API();
  late Future<OrgDataModel> org;
  final orgNameController = TextEditingController();
  final orgNumberController = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();
  String email = '';
  String password = '';
  String name = '';
  String surname = '';
  String organizationName = '';
  final _authService = AuthService();
  FocusNode node = FocusNode();
  bool isApproved = false;
  String organizationNumber = '';
  bool isAgeChecked = false;

  //control button multiple click
  bool isRegistering = false;

  showSelectImageSourceDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SelectImageSourceDialog(
              selectedImage: (onImageSelected onSelected) async {
            imageFile = onSelected.imageFile;
          });
        }).then((value) => null);
  }

  Future registerAsAdmin(MyProvider provider) async {
    print(organizationNumber);
    if (organizationNumber == '') {
      String newOrgNumber = Uuid().v1().toString();
      organizationNumber = newOrgNumber;
      print(organizationNumber);
    }
    if (!isAgeChecked) {
      Utils.showSnackBar(context, 'Confirm that you are older than 16'.tr());
      return;
    }
    if (Utils.validateRegisterAsAdmin(imageFile, organizationName,
        email.trim().replaceAll(" ", ""), password, name, surname, context)) {
      isRegistering = true;
      await _authService
          .registerWithEmailAndPasswordAsAdmin(
              email.trim().replaceAll(" ", ""),
              password,
              name,
              surname,
              organizationName,
              imageFile!,
              context,
              provider,
              organizationNumber,
              isApproved)
          .then((onSuccess) => Navigator.pushReplacementNamed(context, '/home'))
          .catchError((err) => Utils.showSnackBar(context, err.toString()))
          .onError((error, stackTrace) {
        isRegistering = false;
      });
      isRegistering = false;
    }
  }

  @override
  void didChangeDependencies() {
    final provider = Provider.of<MyProvider>(context);
    _authService.allOrganizationsList(provider);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffold(
        appBarName: 'Register organization'.tr(),
        body: buildBody(provider),
        shouldScroll: true);
  }

  Widget buildBody(MyProvider provider) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Stack(
            children: [
              Container(
                  width: size.width * 0.4,
                  height: size.height * 0.25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageFile != null
                              ? FileImage(imageFile!)
                              : AssetImage('assets/background_holder.png')
                                  as ImageProvider))),
              Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Constants.BUTTON_COLOR,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: showSelectImageSourceDialog,
                        icon: Icon(
                          Icons.edit,
                          color: Constants.BACKGROUND_COLOR,
                        ),
                      ))),
            ],
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                TextFieldInput(
                    textInputType: TextInputType.number,
                    controller: orgNumberController,
                    hintText: 'Organization number'.tr(),
                    onChangeValue: (val) {},
                    onFieldSubmitted: (val) {},
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
                                'If you are registered on Brønnøysund we can fetch your organization name from them.You can still register your organization without this number(your organization will not appear on search but you can still invite people via code)'
                                    .tr()
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
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextButton(
                        width: size.width * 0.4,
                        height: 35,
                        text: 'Submit number'.tr(),
                        textColor: Colors.white,
                        containerColor: Constants.BUTTON_COLOR,
                        press: () {
                          if (orgNumberController.text.toString().trim() ==
                              '') {
                            return;
                          }
                          Utils.showToastWithoutContext('Checking'.tr());
                          org = api.fetSingleOrganization(orgNumberController
                              .text
                              .trim()
                              .replaceAll(" ", ""));
                          org.then((value) {
                            setState(() {
                              organizationName = value.navn ?? 'not found';
                              orgNameController.text = organizationName;
                            });

                            organizationNumber =
                                value.organisasjonsnummer ?? "";
                            print(value.organisasjonsnummer);
                            if (organizationNumber == "") {
                              isApproved = false;
                            } else {
                              isApproved = true;
                            }
                            print(isApproved);
                            print(organizationName);
                            print(organizationNumber);
                          });
                        })
                  ],
                ),
                SizedBox(height: 10),
                TextFieldInput(
                  controller: orgNameController,
                  maxLength: 30,
                  hintText: 'Organization name'.tr(),
                  onChangeValue: (s) => organizationName = s,
                  isDone: false,
                  shouldObscureText: false,
                ),
                SizedBox(height: 10),
                Text(
                  'Admin information'.tr(),
                  style: appTextStyle,
                ),
                TextFieldInput(
                    textInputType: TextInputType.emailAddress,
                    autoCorrect: false,
                    hintText: 'E-mail'.tr(),
                    onChangeValue: (s) => email = s,
                    isDone: false,
                    shouldObscureText: false),
                TextFieldInput(
                    textInputType: TextInputType.visiblePassword,
                    hintText: 'Password'.tr(),
                    onChangeValue: (s) => password = s,
                    isDone: false,
                    shouldObscureText: true),
                TextFieldInput(
                    hintText: 'Name'.tr(),
                    onChangeValue: (s) => name = s,
                    isDone: false,
                    shouldObscureText: false),
                TextFieldInput(
                    hintText: 'Surname'.tr(),
                    onChangeValue: (s) => surname = s,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [buildRegisterButton(provider)],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRegisterButton(MyProvider provider) {
    return isRegistering
        ? CircularProgressIndicator()
        : ElevatedCustomButton(
            text: 'Register',
            color: Constants.BUTTON_COLOR,
            press: () {
              registerAsAdmin(provider);
            });
  }
}
