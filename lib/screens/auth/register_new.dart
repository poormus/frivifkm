import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/components/sized_box.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/screens/auth/register_as_admin_screen.dart';
import 'package:firebase_calendar/screens/auth/register_by_link.dart';
import 'package:firebase_calendar/screens/auth/select_guest_pref.dart';
import 'package:firebase_calendar/screens/auth/sign_up.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../anim/slide_in_right.dart';
import '../../services/auth_service.dart';
import '../../shared/constants.dart';
import 'global_events.dart';

class RegisterNew extends StatefulWidget {
  const RegisterNew({Key? key}) : super(key: key);

  @override
  _RegisterNewState createState() => _RegisterNewState();
}

class _RegisterNewState extends State<RegisterNew> {
  int currentSelectedIndex = -1;
  bool isSelected = false;
  final prefs = SharedPreferences.getInstance();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Constants.BACKGROUND_COLOR,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(bottom: 30.0),
          width: MediaQuery.of(context).size.width,
          height: 60,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width * 0.5,
                height: 30,
                onPressed:
                    isSelected ? () => navigate(currentSelectedIndex) : null,
                color: Constants.BUTTON_COLOR,
                child: Text('Continue'.tr()),
                textColor: Colors.white,
                disabledColor: Colors.grey,
              ),
            ],
          ),
        ),
        appBar: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppBar(
                iconTheme: IconThemeData(color: Colors.black),
                backgroundColor: Constants.BACKGROUND_COLOR,
                centerTitle: true,
                elevation: 0,
                title: Container(
                    width: 50,
                    height: 50,
                    child: Image.asset('assets/frivi_logo.png')),
              ),
            ),
            preferredSize: Size.fromHeight(80)),
        body: Container(
          height: size.height - 80,
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: buildBody(size),
        ),
      ),
    );
  }

  buildBody(Size size) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select user type'.tr() + '\n' + 'For registration'.tr(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Text('or continue to'.tr()),
                SizedBox(width: 5),
                InkWell(
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: Text('log in page'.tr(),
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue)),
                ),
              ],
            ),
            SizedBox(height: 10),
            SelectType(
                selectedIndex: currentSelectedIndex,
                onTap: () => setIndex(2),
                assetName: 'assets/user.png',
                userType: 'User'.tr(),
                description:
                    'You are a guest,volunteer or member of an organization, or you just want to join one'
                        .tr(),
                index: 2),
            SizedBox(height: 10),
            SelectType(
                selectedIndex: currentSelectedIndex,
                onTap: () => setIndex(3),
                assetName: 'assets/code.png',
                userType: 'Admin'.tr(),
                description:
                    'You are an admin and want to register your organization'
                        .tr(),
                index: 3),
            SizedBox(height: 10),
            SelectType(
                selectedIndex: currentSelectedIndex,
                onTap: () => setIndex(4),
                assetName: 'assets/admin.png',
                userType: 'Code'.tr(),
                description:
                    'You have an invitation code from an organization'.tr(),
                index: 4),
          ],
        ),
      ),
    );
  }

  setIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
      isSelected = true;
    });
  }

  navigate(int index) {
    switch (index) {
      case 1:
        navigateToGlobalEvents();
        break;

      case 2:
        navigateToRegister();
        break;

      case 3:
        navigateToRegisterAsAdmin();
        break;
      case 4:
        navigateToRegisterByCode();
        break;
    }
  }

  Future<void> navigateToGlobalEvents() async {
    /*  SharedPreferences prefs = await SharedPreferences.getInstance();
    final guestId = prefs.getString('guestId') ?? '';
    final hasUserSelectedPrefs = prefs.getBool('hasUserSelectedPrefs') ?? false;
    final selectedCity = prefs.getString('guestSelectedCity');
    final selectedPrefs = prefs.getStringList('guestSelectedPreferences') ?? [];
    final lat = prefs.getDouble('lat') ?? 0.0;
    final lng = prefs.getDouble('lng') ?? 0.0;
    // final country = prefs.getString('country');
    // country == null
    //     ? showCountryPicker(
    //   context: context,
    //   showPhoneCode:
    //   true, // optional. Shows phone code before the country name.
    //   onSelect: (Country country) {
    //     //print('Select country: ${country.countryCode.toLowerCase()}');
    //     Utils.saveStringValue(
    //         'country', country.countryCode.toLowerCase());
    //   },
    // )
    //:
    if (hasUserSelectedPrefs) {
      final coordinates = Coordinates(lat: lat, long: lng);
      Navigator.push(
          context,
          SlideInRight(GlobalEvents(
              selectedPrefs: selectedPrefs,
              coordinates: coordinates,
              guestId: guestId,
              area: selectedCity,
              country: 'no')));
    } else {
      Navigator.push(
          context,
          SlideInRight(SelectUserPrefs(
            preferences: prefs,
            shouldNavigateToEvents: true,
          )));
    } */
  }

  void navigateToRegister() {
    Navigator.push(context, SlideInRight(SignUpApp(authService: authService)));
  }

  void navigateToRegisterAsAdmin() {
    Navigator.push(context, SlideInRight(RegisterOrganizationAsAnAdmin()));
  }

  void navigateToRegisterByCode() {
    Navigator.push(
        context, SlideInRight(RegisterByLink(authService: authService)));
  }
}

class SelectType extends StatelessWidget {
  final String assetName;
  final String userType;
  final String description;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  const SelectType(
      {Key? key,
      required this.assetName,
      required this.userType,
      required this.description,
      required this.index,
      required this.onTap,
      required this.selectedIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: selectedIndex == index
                ? Constants.BUTTON_COLOR
                : Constants.CONTAINER_COLOR),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Image.asset(assetName),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userType,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.black)),
                Container(
                    width: size.width * 0.5,
                    child: Text(
                      description,
                      style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.black),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
