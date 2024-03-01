import 'package:badges/badges.dart' as Badge;
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/super_admin/super_admin_screen.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/drawer_menu_tile.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideDrawer extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final String subLevel;
  final int surveyCount;
  final int pollCount;

  final CountService countService;
  const SideDrawer({
    Key? key,
    required this.currentUserData,
    required this.userRole,
    required this.subLevel,
    required this.surveyCount,
    required this.pollCount,
    required this.countService,
  }) : super(key: key);

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  late String orgName;
  late String orgUrl;

  @override
  void initState() {
    orgName = Utils.getOrgNameAndImage(
        widget.currentUserData.currentOrganizationId,
        widget.currentUserData.userOrganizations)[0];
    orgUrl = Utils.getOrgNameAndImage(
        widget.currentUserData.currentOrganizationId,
        widget.currentUserData.userOrganizations)[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
        child: Drawer(
            child: Column(
          children: [
            Expanded(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(orgUrl)),
                    title: Text(orgName,
                        overflow: TextOverflow.ellipsis, style: appTextStyle),
                    trailing:
                        widget.subLevel == 'freemium' || widget.subLevel == ''
                            ? null
                            : FaIcon(
                                FontAwesomeIcons.crown,
                                color: Constants.CANCEL_COLOR,
                              ),
                  ),
                  Divider(
                    height: 4,
                    color: Colors.black,
                  ),
                  DrawerMenuTiles(
                    subLevel: widget.subLevel,
                    currentUserData: widget.currentUserData,
                    userRole: widget.userRole,
                    pollCount: widget.pollCount,
                    surveyCount: widget.surveyCount,
                    countService: widget.countService,
                  ),
                  if (widget.userRole == '4') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Divider(
                        height: 3,
                        color: Colors.black54,
                      ),
                    ),
                    DrawerMenuTile(
                        title: Strings.ADMIN_PANEL.tr(),
                        icon: Icons.admin_panel_settings,
                        onTap: () {
                          Navigation.navigateToAdmin(
                              context, widget.currentUserData, widget.subLevel);
                        }),
                    widget.currentUserData.isAdmin != null
                        ? DrawerMenuTile(
                            title: 'Super admin',
                            icon: Icons.admin_panel_settings_outlined,
                            onTap: () {
                              Navigator.of(context).push(SlideInRight(
                                  SuperAdminScreen(
                                      userData: widget.currentUserData)));
                            })
                        : Container(),
                  ]
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}

// drawer menu items
class DrawerMenuTiles extends StatelessWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final String subLevel;
  final int surveyCount;
  final int pollCount;
  final CountService countService;

  DrawerMenuTiles(
      {Key? key,
      required this.currentUserData,
      required this.userRole,
      required this.subLevel,
      required this.surveyCount,
      required this.pollCount,
      required this.countService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () => selectedItem(context, 2, currentUserData),
          leading: CircleAvatar(
              key: Key('profile'),
              radius: 15,
              backgroundImage: NetworkImage(currentUserData.userUrl)),
          title: Text(Strings.PROFILE),
        ),
        DrawerMenuTile(
            title: Strings.ROOMS.tr(),
            icon: Icons.meeting_room,
            trailing: subLevel == 'freemium' || subLevel == ''
                ? Icon(Icons.lock, color: Constants.CANCEL_COLOR)
                : null,
            onTap: () {
              subLevel == 'freemium' || subLevel == ''
                  ? Utils.showToastWithoutContext('Premium only'.tr())
                  : selectedItem(context, 0, currentUserData);
            }),
        DrawerMenuTile(
            title: Strings.FAQ.tr(),
            icon: Icons.question_answer_outlined,
            trailing: subLevel == 'freemium' || subLevel == ''
                ? Icon(Icons.lock, color: Constants.CANCEL_COLOR)
                : null,
            onTap: () {
              subLevel == 'freemium' || subLevel == ''
                  ? Utils.showToastWithoutContext('Premium only'.tr())
                  : selectedItem(context, 6, currentUserData);
            }),
        DrawerMenuTile(
            title: Strings.WORK_TIME.tr(),
            icon: Icons.work_outline,
            trailing: subLevel == 'freemium' || subLevel == ''
                ? Icon(Icons.lock, color: Constants.CANCEL_COLOR)
                : null,
            onTap: () {
              subLevel == 'freemium' || subLevel == ''
                  ? Utils.showToastWithoutContext('Premium only'.tr())
                  : selectedItem(context, 5, currentUserData);
            }),
        DrawerMenuTile(
            title: Strings.RESOURCES.tr(),
            icon: Icons.source_outlined,
            trailing: subLevel == 'freemium' || subLevel == ''
                ? Icon(Icons.lock, color: Constants.CANCEL_COLOR)
                : null,
            onTap: () {
              subLevel == 'freemium' || subLevel == ''
                  ? Utils.showToastWithoutContext('Premium only'.tr())
                  : selectedItem(context, 7, currentUserData);
            }),
        DrawerMenuTile(
            title: 'Polls'.tr(),
            icon: Icons.poll,
            trailing: subLevel == 'freemium' || subLevel == ''
                ? Icon(Icons.lock, color: Constants.CANCEL_COLOR)
                : pollCount == 0
                    ? null
                    : Badge.Badge(
                        badgeContent: Text(
                          pollCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
            onTap: () {
              subLevel == 'freemium' || subLevel == ''
                  ? Utils.showToastWithoutContext('Premium only'.tr())
                  : selectedItem(context, 8, currentUserData);
            }),
        DrawerMenuTile(
            title: 'Surveys'.tr(),
            icon: FontAwesomeIcons.database,
            trailing: subLevel == 'freemium' || subLevel == ''
                ? Icon(Icons.lock, color: Constants.CANCEL_COLOR)
                : surveyCount == 0
                    ? null
                    : Badge.Badge(
                        badgeContent: Text(
                          surveyCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
            onTap: () {
              subLevel == 'freemium' || subLevel == ''
                  ? Utils.showToastWithoutContext('Premium only'.tr())
                  : selectedItem(context, 9, currentUserData);
            }),
        DrawerMenuTile(
            title: Strings.SCAN_QR_CODE.tr(),
            icon: FontAwesomeIcons.qrcode,
            onTap: () {
              selectedItem(context, 10, currentUserData);
            }),
        if (userRole == '3' || userRole == '4') ...[
          DrawerMenuTile(
              title: Strings.GROUPS.tr(),
              icon: Icons.group,
              onTap: () {
                Navigation.navigateToCreateGroupScreen(
                    context,
                    currentUserData.currentOrganizationId,
                    userRole,
                    currentUserData.uid,
                    currentUserData);
              }),
        ]
      ],
    );
  }

  void selectedItem(
      BuildContext context, int index, CurrentUserData currentUserData) {
    //Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigation.navigateToRoomAndBookingHistoryScreen(
            context, currentUserData, userRole);
        break;
      case 1:
        Navigation.navigateToCreateGroupScreen(
            context,
            currentUserData.currentOrganizationId,
            userRole,
            currentUserData.uid,
            currentUserData);
        break;
      case 2:
        Navigation.navigateToProfile(context, currentUserData, userRole);
        break;
      case 3:
        //removed
        break;
      case 4:
        //Navigation.navigateToAdmin(context, currentUserData);
        break;
      case 5:
        Navigation.navigateToAddWorkTimeScreen(context, currentUserData);
        break;
      case 6:
        Navigation.navigateToFaq(context, currentUserData);
        break;
      case 7:
        Navigation.navigateToResources(context, currentUserData, userRole);
        break;
      case 8:
        if (pollCount != 0) {
          print('no poll skip');
          countService.resetCountForPoll(currentUserData.uid);
        }
        Navigation.navigateToPolls(context, currentUserData, userRole);
        break;
      case 9:
        if (surveyCount != 0) {
          countService.resetCountForSurvey(currentUserData.uid);
        }
        Navigation.navigateToSurveys(context, currentUserData, userRole);
        break;
      case 10:
        Navigation.navigateToQr(context, currentUserData, userRole);
        break;
    }
  }
}
