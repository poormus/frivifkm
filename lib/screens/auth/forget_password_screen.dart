import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/extensions/extensions.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ForgotPasswordScreen extends StatelessWidget {
  String email = '';
  final emailController = TextEditingController();
  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: '', body: buildBody(context), shouldScroll: false);
  }

  Future resetPassword(BuildContext context) async {
    if (!emailController.text.trim().replaceAll(" ", "").isValidEmail()) {
      Utils.showSnackBar(context,Strings.EMAIL_VALIDATION_ERROR.tr());
      return;
    }
    final auth = AuthService();
    auth.passwordReset(emailController.text.trim().replaceAll(" ", ""),context);
  }


  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(
          height: size.height * 0.1,
        ),
        Text('Forgot password'.tr(), style: TextStyle(fontSize: 30)),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Text(
            'Please enter your e-mail'.tr(),
            style: textStyle,
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: TextFieldInput(
            controller: emailController,
              textInputType: TextInputType.emailAddress,
              autoCorrect: false,
              shouldObscureText: false,
              isDone: true,
              hintText: 'Email'.tr(),
              onChangeValue: (s) {
                email = s;
              }),
        ),
        SizedBox(height: 16),
        CustomTextButton(
            width: size.width * 0.8,
            height: 35,
            text: "Reset password".tr(),
            textColor: Colors.white,
            containerColor: Constants.BUTTON_COLOR,
            press: () {
              resetPassword(context);
            })
      ],
    );
  }
}
