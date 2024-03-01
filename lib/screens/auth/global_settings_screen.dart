import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/screens/auth/select_guest_pref.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../anim/slide_in_right.dart';
import '../../shared/strings.dart';

class GlobalSettings extends StatefulWidget {
  GlobalSettings({
    Key? key,
  }) : super(key: key);

  @override
  State<GlobalSettings> createState() => _GlobalSettingsState();
}

class _GlobalSettingsState extends State<GlobalSettings> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarName: 'Settings'.tr(),
        body: buildBody(context),
        shouldScroll: false);
  }

  void updateUI() {
    setState(() {});
  }

  Widget buildBody(BuildContext context) {
    return ListView(
      children: [
        SettingsTile(
            iconData: Icons.language,
            settingName: Strings.LANGUAGE.tr(),
            onTap: () {
              Navigation.navigateToLanguageScreen(context, updateUI);
            }),
        SettingsTile(
            iconData: Icons.category,
            settingName: 'Preferences',
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              /* Navigator.push(
              context,
              SlideInRight(SelectUserPrefs(preferences: prefs,))); */
            }),
        SettingsTile(
            iconData: Icons.feedback,
            settingName: 'Feedback/Support'.tr(),
            onTap: () {
              handleEmail();
            }),
        SettingsTile(
            iconData: Icons.gamepad,
            settingName: Strings.HOW_TO.tr(),
            onTap: () {
              Navigation.navigateToHowToScreen(context);
            }),
        SettingsTile(
            iconData: FontAwesomeIcons.book,
            settingName: 'Privacy policy'.tr(),
            onTap: () async {
              if (await canLaunch('https://friviapp.com/privacy-policy-app/')) {
                await launch('https://friviapp.com/privacy-policy-app/');
              } else {
                throw 'Could not launch';
              }
            }),
        SettingsTile(
            iconData: FontAwesomeIcons.check,
            settingName: 'Terms of use'.tr(),
            onTap: () async {
              if (await canLaunch('https://friviapp.com/terms-of-use')) {
                await launch('https://friviapp.com/terms-of-use');
              } else {
                throw 'Could not launch';
              }
            }),
      ],
    );
  }

  Future handleEmail() async {
    try {
      final Uri _emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'frivi@daxap.no',
          queryParameters: {'subject': 'I would like to'});
      launch(_emailLaunchUri.toString());
    } catch (e) {
      Utils.showToastWithoutContext('An error occurred'.tr());
    }
  }
}

class SettingsTile extends StatelessWidget {
  final IconData iconData;
  final String settingName;
  final VoidCallback onTap;

  const SettingsTile(
      {Key? key,
      required this.iconData,
      required this.settingName,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        iconData,
        color: Constants.CANCEL_COLOR,
      ),
      title: Text(settingName, style: appTextStyle),
      onTap: onTap,
    );
  }
}
