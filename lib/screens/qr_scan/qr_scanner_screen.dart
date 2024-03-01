import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold_main_screen_item.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/qr_scan.dart';
import 'package:firebase_calendar/screens/qr_scan/qr_view.dart';
import 'package:firebase_calendar/screens/qr_scan/user_qr_logs.dart';
import 'package:firebase_calendar/screens/qr_scan/user_qr_logs_single.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'organization_qr_logs.dart';

class QrScannerScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;

  QrScannerScreen({Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  String currentTab = 'userLogs';
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: Strings.SCAN_QR_CODE.tr(),shouldScroll: false,body: mainBody());
  }

  Widget mainBody(){
    return widget.userRole!='4'?
    UserLogsSingle(currentUserData: widget.currentUserData,userRole: widget.userRole):
    Column(
      children: [
        Container(
          height: Constants.TAB_HEIGHT,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentTab = 'userLogs';
                      });
                    },
                    child: Text(
                      'User Logs'.tr(),
                      style: TextStyle(
                          color: currentTab == 'userLogs'
                              ? Constants.BUTTON_COLOR
                              : Colors.grey),
                    )),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentTab = 'organizationLogs';
                      });
                    },
                    child: Text('Organization Logs'.tr(),
                        style: TextStyle(
                            color: currentTab == 'organizationLogs'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey))),
              ),

            ],
          ),
        ),
        Divider(
          height: 3,
          color: Colors.grey,
        ),
        if(currentTab=='userLogs')...[
          UserLogs(currentUserData: widget.currentUserData,userRole: widget.userRole,)
        ]else...[
          OrganizationLogs(currentUserData: widget.currentUserData)
        ]
      ],
    );
  }

}
