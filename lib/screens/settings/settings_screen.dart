import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_with_title.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../components/sized_box.dart';
import '../../services/auth_service.dart';
import '../../shared/strings.dart';
import '../../shared/utils.dart';

class Settings extends StatefulWidget {
  final CurrentUserData currentUserData;

  Settings({Key? key, required this.currentUserData}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthService _auth = AuthService();

  late Future<bool> isAddToCalendar;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool check = false;
  @override
  void initState() {
    super.initState();
  }

  void updateUi() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarName: 'Settings'.tr(),
        body: buildBody(context),
        shouldScroll: false);
  }

  Widget buildBody(BuildContext context) {
    isAddToCalendar = _prefs.then((value) {
      return value.getBool('enableCalendar') ?? false;
    });
    return FutureBuilder<bool>(
        future: isAddToCalendar,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            check = snapshot.data!;
            return Column(
              children: [
                SettingsTile(
                    iconData: Icons.language,
                    settingName: Strings.LANGUAGE.tr(),
                    onTap: () {
                      Navigation.navigateToLanguageScreen(context, updateUi);
                    }),
                SettingsTile(
                  iconData: Icons.calendar_month,
                  settingName: 'Calendar'.tr(),
                  onTap: () {},
                  trailing: Checkbox(
                    activeColor: Constants.CANCEL_COLOR,
                    onChanged: (bool? value) async {
                      requestCalendarPermission(value);
                    },
                    value: check,
                  ),
                ),
                SettingsTile(
                    iconData: Icons.feedback,
                    settingName: 'Feedback/Support'.tr(),
                    onTap: () {
                      handleEmail();
                    }),
                SettingsTile(
                    iconData: FontAwesomeIcons.book,
                    settingName: 'Privacy policy'.tr(),
                    onTap: () async {
                      if (await canLaunch(
                          'https://friviapp.com/privacy-policy-app/')) {
                        await launch(
                            'https://friviapp.com/privacy-policy-app/');
                      } else {
                        throw 'Could not launch';
                      }
                    }),
                SettingsTile(
                    iconData: FontAwesomeIcons.check,
                    settingName: 'Terms of use'.tr(),
                    onTap: () async {
                      if (await canLaunch(
                          'https://friviapp.com/terms-of-use')) {
                        await launch('https://friviapp.com/terms-of-use');
                      } else {
                        throw 'Could not launch';
                      }
                    }),
                SettingsTile(
                    iconData: FontAwesomeIcons.flag,
                    settingName: 'Select country'.tr(),
                    onTap: () {
                      showCountrySelector(context);
                    }),
                SettingsTile(
                    iconData: Icons.gamepad,
                    settingName: Strings.HOW_TO.tr(),
                    onTap: () {
                      Navigation.navigateToHowToScreen(context);
                    }),
                SettingsTile(
                    iconData: Icons.logout,
                    settingName: Strings.LOGOUT.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      _auth.signOut();
                    }),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    deleteAccount(context);
                  },
                  child: Container(
                    height: 30,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black12),
                    child: Center(
                        child: Text(
                      'Delete account'.tr(),
                      style: appTextStyle.copyWith(),
                    )),
                  ),
                ),
                SizedBoxWidget()
              ],
            );
          } else
            return CircularProgressIndicator();
        });
  }

  Future handleEmail() async {
    try {
      final Uri _emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'frivi@daxap.com',
          queryParameters: {'subject': 'Feedback/Suggestion'});
      launch(_emailLaunchUri.toString());
    } catch (e) {
      Utils.showToastWithoutContext('An error occurred'.tr());
    }
  }

  deleteAccount(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return BlurryDialogWithTitle(
              title: 'Are you sure?'.tr(),
              content: 'You can not recover your account'.tr(),
              continueCallBack: () {
                Navigator.pop(context);
                Navigator.pop(context);
                _auth.deleteAccount(widget.currentUserData.uid);
                _auth.signOut();
              });
        });
  }

  showCountrySelector(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        //print('Select country: ${country.countryCode.toLowerCase()}');
        Utils.saveStringValue('country', country.countryCode.toLowerCase());
      },
    );
  }

  void requestCalendarPermission(bool? value) async {
    print(value);
    var status = await Permission.calendar.status;
    print(status);
    if (status.isGranted) {
      await _prefs.then((pref) {
        return pref.setBool('enableCalendar', value!);
      });
      setState(() {
        check = value!;
      });
    } else if (!status.isGranted) {
      print("here");
      Permission.calendar.request().then((val) => print(val));
    }
  }
}

class SettingsTile extends StatelessWidget {
  final IconData iconData;
  final String settingName;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsTile(
      {Key? key,
      required this.iconData,
      required this.settingName,
      required this.onTap,
      this.trailing})
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
      trailing: trailing,
    );
  }
}
