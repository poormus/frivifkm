import 'dart:ui';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/cutom_circular.dart';
import 'package:firebase_calendar/db/db_current_user_data.dart';
import 'package:firebase_calendar/db/user_organizations_db.dart';
import 'package:firebase_calendar/models/badge_count.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Constants {
  static const CURRENT_USER_HOLDER = CurrentUserData(
      uid: '',
      email: '',
      userName: 'removed',
      userSurname: 'user',
      userOrganizations: [],
      currentOrganizationId: '',
      userPhone: '',
      userUrl: Constants.IMAGE_HOLDER,
      groupIds: [],
      adminRegistry: [],
      totalPoint: 0);

  static Event EVENT_HOLDER = Event(
      eventId: '',
      organizationId: '',
      createdByUid: '',
      eventName: '',
      eventDate: DateTime.now(),
      eventStartTime: DateTime.now(),
      eventEndTime: DateTime.now(),
      eventUrl: '',
      eventAddress: '',
      eventInformation: '',
      toWho: [],
      attendingUids: [],
      declinedUids: [],
      commentCount: 0,
      isPublic: true,
      externalUsers: [],
      organizationName: '',
      category: '',
      city: '');

  static const BADGE_COUNT_HOLDER = BadgeCount(
      uid: '',
      announcementCount: 0,
      messageCount: 0,
      groupChatCount: 0,
      surveyCount: 0,
      pollCount: 0);

  static const DbUserHolder = CurrentUserDataDb(
      uid: '',
      email: 'email',
      userName: 'userName',
      userSurname: 'userSurname',
      currentOrganizationId: 'currentOrganizationId',
      userPhone: 'userPhone',
      userUrl: 'userUrl',
      totalPoint: 0);
  static const DbOrgHolder = UserOrganizationsDb(
      uid: '',
      organizationId: '',
      organizationName: 'organizationName',
      organizationUrl: 'organizationUrl',
      isApproved: false,
      userRole: 'userRole');

  static const TAB_HEIGHT = 42.0;
  static const IMAGE_HOLDER =
      "https://firebasestorage.googleapis.com/v0/b/fir-calendar-97111.appspot.com/o/frivi_profile_pic_holder.png?alt=media&token=e26ffff0-72e8-415a-9263-1770861cb979";

  static const ORG_HOLDER = Organization(
      organizationId: '1',
      organizationName: 'organizationName',
      organizationUrl:
          "https://firebasestorage.googleapis.com/v0/b/fir-calendar-97111.appspot.com/o/frivi_profile_pic_holder.png?alt=media&token=e26ffff0-72e8-415a-9263-1770861cb979",
      admins: [],
      organizationNumber: '123',
      isApproved: false,
      currentUserCount: 0,
      targetUserCount: 12,
      subLevel: 'subLevel',
      blockedUsers: [],
      about: 'about',
      contactPerson: 'contactPerson',
      ePost: 'ePost',
      mobil: 'mobil',
      address: 'address',
      website: 'website');
  static const List<Color> colorCollection = [
    Color(0xFF0F8644),
    Color(0xFF8B1FA9),
    Color(0xFFD20100),
    Color(0xFFFC571D),
    Color(0xFF85461E),
    Color(0xFF36B37B),
    Color(0xFF3D4FB5),
    Color(0xFFE47C73),
    Color(0xFF636363)
  ];
  static const List<String> colorNames = [
    'Green',
    'Purple',
    'Red',
    'Orange',
    'Caramel',
    'Light Green',
    'Blue',
    'Peach',
    'Gray'
  ];
  static const BACKGROUND_COLOR = Color(0xffeae8fe);
  static const BUTTON_COLOR = Color(0xff9013FE);
  static const CANCEL_COLOR = Color(0xffFF6376);
  static const CARD_COLOR = Color(0xffefeeef);
  static const CONTAINER_COLOR = Color(0xfff9f9fc);
}

const textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2.0)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink, width: 2.0)));

const dropDownDecoration = InputDecoration(
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Constants.CARD_COLOR)),
    fillColor: Constants.CARD_COLOR,
    filled: true);

const dropDownDialogDecoration = InputDecoration(
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Constants.BACKGROUND_COLOR)),
    fillColor: Constants.BACKGROUND_COLOR,
    filled: true);

const textStyle =
    TextStyle(color: Colors.black54, overflow: TextOverflow.ellipsis);

const appTextStyle = TextStyle();

buttonPreview(double _height, double _width) {
  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    minimumSize: Size(_width, _height),
    backgroundColor: Colors.grey,
    padding: EdgeInsets.all(0),
  );
  return TextButton(
    style: flatButtonStyle,
    onPressed: () {},
    child: Text(
      "some text",
      style: TextStyle(color: Colors.white),
    ),
  );
}

Widget noDataWidget(String? info, bool isProgress) {
  if (!isProgress) {
    return Container(
        height: 190,
        child: Center(child: Text(info ?? 'No data available'.tr())));
  } else {
    return Container(height: 190, child: Center(child: ProgressWithIcon()));
  }
}

Widget lottieAnimNoData(String lottieAsset, String text) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Lottie.asset(lottieAsset, height: 100), Text(text)],
    ),
  );
}

// scaffold without scrollable body
Widget buildScaffold(String appBarName, BuildContext context, Widget body,
    Widget? floatingActionButton) {
  final size = MediaQuery.of(context).size;
  return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: Constants.BACKGROUND_COLOR,
    appBar: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Constants.BACKGROUND_COLOR,
            centerTitle: true,
            title: Text(
              appBarName,
              style: TextStyle(color: Colors.black),
            ),
            elevation: 0,
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
      child: body,
    ),
    floatingActionButton: floatingActionButton,
  );
}

Widget buildScaffoldForChannels(String appBarName, BuildContext context,
    Widget body, Widget? floatingActionButton) {
  final size = MediaQuery.of(context).size;
  return Scaffold(
    backgroundColor: Constants.BACKGROUND_COLOR,
    appBar: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            // leading: IconButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     icon: Icon(
            //       Icons.arrow_back_rounded,
            //       color: Colors.black,
            //     )),
            backgroundColor: Constants.BACKGROUND_COLOR,
            centerTitle: true,
            title: Text(
              appBarName,
              style: TextStyle(color: Colors.black),
            ),
            elevation: 0,
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
      child: body,
    ),
    floatingActionButton: floatingActionButton,
  );
}

// scaffold wit scrollable body
Widget buildScaffoldScrollable(String appBarName, BuildContext context,
    Widget body, Widget? floatingActionButton) {
  final size = MediaQuery.of(context).size;
  return Scaffold(
    backgroundColor: Constants.BACKGROUND_COLOR,
    appBar: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            // leading: IconButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     icon: Icon(
            //       Icons.arrow_back_rounded,
            //       color: Colors.black,
            //     )),
            backgroundColor: Constants.BACKGROUND_COLOR,
            centerTitle: true,
            title: Text(
              appBarName,
              style: TextStyle(color: Colors.black),
            ),
            elevation: 0,
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
      child: body,
    ),
    floatingActionButton: floatingActionButton,
  );
}

Widget buildCustomScaffold(BuildContext context, Widget appBar, Widget body,
    GlobalKey<ScaffoldState> key, Widget drawer) {
  final size = MediaQuery.of(context).size;
  return Scaffold(
    drawer: drawer,
    key: key,
    resizeToAvoidBottomInset: false,
    backgroundColor: Constants.BACKGROUND_COLOR,
    appBar: PreferredSize(
        child:
            Padding(padding: const EdgeInsets.only(top: 50.0), child: appBar),
        preferredSize: Size.fromHeight(80)),
    body: SingleChildScrollView(
      child: Container(
        height: size.height - 80,
        width: size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: body,
      ),
    ),
  );
}
