import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/select_new_organization_dialog.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

//ignore:must_be_immutable
class RemovedFromAllOrganizations extends StatelessWidget {
  final CurrentUserData currentUserData;
  AuthService _auth = AuthService();

  RemovedFromAllOrganizations({Key? key, required this.currentUserData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarName: 'Removed'.tr(),
      body: buildCenter(),
      shouldScroll: false,
      floatingActionButton: buildFloatingActionButton(),
      actions: buildActions(context),
    );
    return buildScaffold('Pending approval', context, buildCenter(),
        buildFloatingActionButton());
  }

  Widget buildCenter() => Center(
      child: Text('You have been removed from all organizations'.tr(),
          style: appTextStyle));

  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SelectNewOrganization(
                      uid: currentUserData.uid,
                      currentUserData: currentUserData);
                });
          },
          icon: Icon(Icons.location_city,color: Constants.CANCEL_COLOR))
    ];
  }

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
