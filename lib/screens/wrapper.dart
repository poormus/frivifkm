import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/db/user_database.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/helper/notification_helper.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/main/main_screen_with_bottom_nav.dart';
import 'package:firebase_calendar/screens/pending_approval_screen.dart';
import 'package:firebase_calendar/screens/removed_from_all_organizations.dart';
import 'package:firebase_calendar/screens/verify_email_screen.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/services/version.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/loading.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/utils.dart';
import 'auth/authenticate.dart';
import 'auth/forget_password_screen.dart';
import 'messages/group_chat_screen.dart';

class Wrapper extends StatefulWidget {
  Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  AuthService authService = AuthService();
  GroupServices groupServices = GroupServices();

  final versionCheck = VersionCheck();

  Future<void> initPlatformState() async {
    OneSignal.initialize(Configuration.oneSignalAppId);

    if (Platform.isIOS) {
      // allow one signal notification
    }
  }

  showUpdateAppDialog(String appStoreUrl, String playStoreUrl) {
    final dialog = WillPopScope(
      onWillPop: () async => false,
      child: BlurryDialog(
          title: 'New update'.tr(),
          content:
              'A new update is available. Please update your app to continue.'
                  .tr(),
          cancelCallBack: () {
            Navigator.pop(context);
          },
          continueCallBack: () {
            if (Platform.isIOS) {
              Navigator.pop(context);
              prompt(appStoreUrl);
            } else if (Platform.isAndroid) {
              Navigator.pop(context);
              prompt(playStoreUrl);
            }
          }),
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  void prompt(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> checkVersionOnStart() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNUmber = packageInfo.buildNumber;
    String versionToCheck = '$version+$buildNUmber';
    await versionCheck.getVersion().then((value) {
      // print(versionToCheck);
      // print(value[0]);
      if (Platform.isAndroid) {
        if (value[0] != versionToCheck) {
          showUpdateAppDialog(value[2], value[3]);
        }
      } else if (Platform.isIOS) {
        if (value[1] != versionToCheck) {
          showUpdateAppDialog(value[2], value[3]);
        }
      }
    });
  }

  @override
  void initState() {
    initPlatformState();
    SchedulerBinding.instance
        .addPostFrameCallback((_) => checkVersionOnStart());
    super.initState();
  }

  //bunlari async yaptim bakalim hata olacakmi...
  getUsers(MyProvider provider, String currentOrganizationId) async {
    await groupServices.getUsersForOrganization(
        provider, currentOrganizationId);
  }

  getGroups(MyProvider provider, String currentOrganizationId) async {
    await groupServices.getGroupsForVoluntaryWork(
        currentOrganizationId, provider);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser?>(context);
    final provider = Provider.of<MyProvider>(context);
    if (user == null) {
      return Scaffold(body: Authenticate());
    } else {
      //clear list on dispose
      //String uid=FirebaseAuth.instance.currentUser!.uid;
      User currentUser = FirebaseAuth.instance.currentUser!;
      return Scaffold(
        body: StreamBuilder<CurrentUserData>(
            stream: authService.getCurrentUser(currentUser.uid),
            builder: (context, snapshots) {
              if (snapshots.hasData) {
                final currentUserdata = snapshots.data!;

                ///these functions get groups and users for the current organizations
                getUsers(provider, currentUserdata.currentOrganizationId);
                getGroups(provider, currentUserdata.currentOrganizationId);

                ///these functions get groups and users for the current organizations
                final userRole = Utils.getUserRole(
                    currentUserdata.userOrganizations,
                    currentUserdata.currentOrganizationId);
                if (Configuration.isProduction) {
                  if (!currentUser.emailVerified) {
                    return VerifyEmailScreen(currentUserData: currentUserdata);
                  }
                }
                return currentUserdata.currentOrganizationId != ''
                    ? StreamBuilder<Organization>(
                        stream: authService.getOrganization(
                            currentUserdata.currentOrganizationId),
                        builder: (context, orgSnap) {
                          String subLevel = '';
                          if (orgSnap.hasData) {
                            subLevel = orgSnap.data!.subLevel;
                          }
                          return MainScreenWithBottomNav(
                              currentUserData: currentUserdata,
                              userRole: userRole,
                              subLevel: subLevel);
                        })
                    : currentUserdata.userOrganizations.length == 0
                        ? RemovedFromAllOrganizations(
                            currentUserData: currentUserdata)
                        : PendingApproval(currentUserData: currentUserdata);
              } else if (snapshots.hasError) {
                //organizasyon olustururken hata veriyor bunun uzerinde calisma gerekli
                //authService.signOut();
                Utils.showToastWithoutContext("User not found or server error");
                return noDataWidget(snapshots.error.toString(), false);
              } else
                return Loading();
            }),
      );
    }
  }
}
