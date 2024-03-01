import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/profile/profile_screen.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:flutter/material.dart';

//ignore:must_be_immutable
class VerifyEmailScreen extends StatelessWidget {
  final CurrentUserData currentUserData;
  AuthService _auth = AuthService();
  VerifyEmailScreen({Key? key, required this.currentUserData})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: 'Verify email'.tr(), body: buildCenter(), shouldScroll: false,floatingActionButton: buildFloatingActionButton());
    return buildScaffold('Pending approval',context,buildCenter(),buildFloatingActionButton());
  }

  Widget buildCenter() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('Please verify your email to start using the app'.tr(),style: appTextStyle),
      Text('Log in again after verification'.tr(),style: appTextStyle),
    ],
  ));

  Widget buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Constants.BUTTON_COLOR,
      onPressed: () {
        _auth.signOut();
      },
      child: Icon(Icons.logout),
    );
  }

}



