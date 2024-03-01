import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/long_button.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/sized_box.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/extensions/extensions.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/screens/auth/register_by_link.dart';
import 'package:firebase_calendar/screens/auth/sign_in.dart';
import 'package:firebase_calendar/screens/auth/sign_up.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/services/version.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';

import 'package:flutter/material.dart';

import '../../shared/utils.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final AuthService _auth = AuthService();
  String isTapped = 'signIn';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: "Frivi", body: body(size, context), shouldScroll: true);
  }

  Widget body(Size size, BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(child: SignInApp(authService: _auth))),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/register'),
              child: Text('New to frivi? - Create account'.tr()),
            )
          ],
        ),
        SizedBoxWidget()
        // if (isTapped == 'signIn') ...[
        //   SignInApp(authService: _auth),
        // ] else if(isTapped=='signUp') ...[
        //   SignUpApp(authService: _auth)
        // ]else...[
        //   RegisterByLink(authService: _auth,)
        // ],
      ],
    );
  }

  Widget buildContainer(Size size) {
    return Container(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.25,
              height: 50,
              decoration: BoxDecoration(
                  color:
                      isTapped == 'signIn' ? Constants.BACKGROUND_COLOR : null,
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(5)),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isTapped = 'signIn';
                  });
                },
                child: Text(
                  Strings.SIGN_IN.tr(),
                  style: TextStyle(color: Constants.BUTTON_COLOR),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: size.width * 0.25,
              height: 50,
              decoration: BoxDecoration(
                  color:
                      isTapped == 'signUp' ? Constants.BACKGROUND_COLOR : null,
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(5)),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isTapped = 'signUp';
                  });
                },
                child: Text(
                  Strings.SIGN_UP.tr(),
                  style: TextStyle(color: Constants.BUTTON_COLOR),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: size.width * 0.25,
              height: 50,
              decoration: BoxDecoration(
                  color: isTapped == 'link' ? Constants.BACKGROUND_COLOR : null,
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(5)),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isTapped = 'link';
                  });
                },
                child: Text(
                  Strings.CODE.tr(),
                  style: TextStyle(color: Constants.BUTTON_COLOR),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
