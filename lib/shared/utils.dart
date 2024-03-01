import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/dialog/policies_dialog.dart';
import 'package:firebase_calendar/extensions/extensions.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_companies.dart';

class Utils {
  static DateTime toDateTime(Timestamp value) {
    return value.toDate();
  }

  static String getMonthName(int number, BuildContext context) {
    List<String> months = [];
    if (context.locale.languageCode == 'en') {
      months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
    } else if (context.locale.languageCode == 'no') {
      months = [
        'Januar',
        'Februar',
        'Mars',
        'April',
        'Mai',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'Desember'
      ];
    }

    return months[number].substring(0, 3);
  }

  static String getWeekName(int number, BuildContext context) {
    List<String> week = [];
    if (context.locale.languageCode == 'en') {
      week = ["Mon", "Tue", "Wed", 'Thu', "Fri", "Sat", "Sun"];
    } else if (context.locale.languageCode == 'no') {
      week = ["Man", "Tir", "Ons", 'Tor', "Fre", "Lør", "Søn"];
    }
    return week[number].substring(0, 3);
  }

  static dynamic fromDateTimeToJson(DateTime? date) {
    if (date == null) return null;
    return date.toUtc();
  }

  static String toTime(DateTime date) {
    final time = DateFormat.Hm().format(date);
    return "$time";
  }

  static String toDate(DateTime date) {
    final time = DateFormat.yMMMEd().format(date);
    return "$time";
  }

  static String toDateTranslated(DateTime date, BuildContext context) {
    final time = DateFormat.yMMMEd(context.locale.languageCode).format(date);
    return "$time";
  }

  static  showSnackBar(BuildContext context, String message) {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
                color: Constants.BACKGROUND_COLOR
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width*0.7,
                  height: 50,
                  child: Text(message,style: TextStyle(color: Colors.black),maxLines: 3)),
              Image.asset('assets/frivi_logo.png',height: 30,width: 30,)
            ],
          )),
      dismissDirection: DismissDirection.down,
      behavior: SnackBarBehavior.floating,
       backgroundColor: Colors.transparent,
       elevation: 0,
    ));
  }

  static String generateRoomName(String user1, String user2) {
    return 'chat_' +
        (user1.hashCode < user2.hashCode
            ? user1 + '_' + user2
            : user2 + '_' + user1);
  }

  static String getUserName(String name, String surName) =>
      '${name} ${surName}';

  static showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static showToastWithoutContext(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static showErrorToast() {
    Fluttertoast.showToast(
      msg: 'An error occurred'.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static showInternetErrorToast() {
    Fluttertoast.showToast(
      msg: 'Check internet connection'.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static Future<bool> getBooleanValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> saveBooleanValue(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<bool> saveStringValue(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(key, value);
  }

  static String getUserRole(
      List<UserOrganizations> organizations, String curOrgId) {
    String userRole = '1';
    for (int index = 0; index < organizations.length; index++) {
      if (organizations[index].organizationId == curOrgId) {
        userRole = organizations[index].userRole;
        break;
      }
    }
    return userRole;
  }

  static String getUserRoleFromIndex(String index) {
    String userRole = '';
    switch (index) {
      case '1':
        userRole = 'guest';
        break;
      case '2':
        userRole = 'member';
        break;
      case '3':
        userRole = 'leader';
        break;
      case '4':
        userRole = 'admin';
        break;
    }
    return userRole.tr();
  }

  static bool validateRegister(String mail, String password, String name,
      String surname, BuildContext context) {
    if (mail.trim().isEmpty || !mail.trim().isValidEmail()) {
      showSnackBar(context, 'Email is empty/invalid'.tr());
      return false;
    } else if (password.isEmpty || password.length < 6) {
      showSnackBar(
          context, 'Password must not be empty and longer than six'.tr());
      return false;
    } else if (name.trim().isEmpty) {
      showSnackBar(context, 'Name can not be empty'.tr());
      return false;
    } else if (surname.trim().isEmpty) {
      showSnackBar(context, 'Surname can not be empty'.tr());
      return false;
    } else
      return true;
  }

  static bool validateAddRoom(File? imageFile, String roomName,
      String roomCapacity, String roomSize, BuildContext context) {
    if (imageFile == null) {
      showSnackBar(context, 'Select an image'.tr());
      return false;
    } else if (roomName.trim().isEmpty) {
      showSnackBar(context, 'Room name is required'.tr());
      return false;
    } else if (roomCapacity.trim().isEmpty) {
      showSnackBar(context, 'Room capacity is required'.tr());
      return false;
    } else if (roomSize.trim().isEmpty) {
      showSnackBar(context, 'Room info is required'.tr());
      return false;
    } else
      return true;
  }

  static bool validateAddRoomForUpdate(String roomName, String roomCapacity,
      String roomSize, BuildContext context) {
    if (roomName.trim().isEmpty) {
      showSnackBar(context, 'Room name is required'.tr());
      return false;
    } else if (roomCapacity.trim().isEmpty) {
      showSnackBar(context, 'Room capacity is required'.tr());
      return false;
    } else if (roomSize.trim().isEmpty) {
      showSnackBar(context, 'Room info is required'.tr());
      return false;
    } else
      return true;
  }

  static bool validateAddEvent(
      File? imageFile,
      String eventName,
      String eventAddress,
      String eventInfo,
      List<String> toWho,
      DateTime startTime,
      DateTime endTime,
      DateTime eventDate,
      BuildContext context) {
    if (imageFile == null) {
      showSnackBar(context, 'Select an image'.tr());
      return false;
    } else if (eventName.trim().isEmpty) {
      showSnackBar(context, 'Event name is required'.tr());
      return false;
    } else if (eventAddress.trim().isEmpty) {
      showSnackBar(context, 'Address is required'.tr());
      return false;
    } else if (eventInfo.trim().isEmpty) {
      showSnackBar(context, 'Event info is required'.tr());
      return false;
    } else if (toWho.length == 0) {
      showSnackBar(context, 'Select at least one group'.tr());
      return false;
    }else if(eventDate.difference(DateTime.now()).inDays<0){
      showSnackBar(context, 'Can not create event in the past'.tr());
      return false;
    }
    else if (endTime.isBefore(startTime)) {
      showSnackBar(context, 'End time can not be earlier than start time'.tr());
      return false;
    }else if(eventDate.isAfter(DateTime.now())){
      return true;
    }
    else if (endTime.difference(startTime).inMinutes<15) {
      showSnackBar(context, 'Can not create events shorter than 15 min'.tr());
      return false;
    }
    else
      return true;
  }

  static bool validateEventForUpdate(
      String eventName,
      String eventAddress,
      String eventInfo,
      List<String> toWho,
      DateTime startTime,
      DateTime endTime,
      DateTime eventDate,
      BuildContext context) {
    if (eventName.trim().isEmpty) {
      showSnackBar(context, 'Event name is required'.tr());
      return false;
    } else if (eventAddress.trim().isEmpty) {
      showSnackBar(context, 'Address is required'.tr());
      return false;
    } else if (eventInfo.trim().isEmpty) {
      showSnackBar(context, 'Event info is required'.tr());
      return false;
    } else if (toWho.length == 0) {
      showSnackBar(context, 'Select at least one group'.tr());
      return false;
    } else if(eventDate.difference(DateTime.now()).inDays<0){
      showSnackBar(context, 'Can not create event in the past'.tr());
      return false;
    }else if (endTime.isBefore(startTime)) {
      showSnackBar(context, 'End time can not be shorter than start time'.tr());
      return false;
    } else if(eventDate.isAfter(DateTime.now())){
      return true;
    } else if (endTime.difference(startTime).inMinutes<15) {
      showSnackBar(context, 'Can not create events earlier than 15 min'.tr());
      return false;
    }
    else
      return true;
  }

  static bool validateRegisterAsAdmin(
      File? imageFile,
      String organizationName,
      String mail,
      String password,
      String name,
      String surname,
      BuildContext context) {
    if (imageFile == null) {
      showSnackBar(context, 'Select an image'.tr());
      return false;
    } else if (organizationName.trim().isEmpty) {
      showSnackBar(context, 'Organization name can not be empty'.tr());
      return false;
    } else if (mail.trim().isEmpty || !mail.trim().isValidEmail()) {
      showSnackBar(context, 'Email is empty/invalid'.tr());
      return false;
    } else if (password.isEmpty || password.length < 6) {
      showSnackBar(
          context, 'Password must not be empty and longer than six'.tr());
      return false;
    } else if (name.trim().isEmpty) {
      showSnackBar(context, 'Name can not be empty'.tr());
      return false;
    } else if (surname.trim().isEmpty) {
      showSnackBar(context, 'Surname can not be empty'.tr());
      return false;
    } else
      return true;
  }

  static List<String> getOrgNameAndImage(
      String curOrgId, List<UserOrganizations> userOrganizations) {
    final list = <String>[];
    for (var index = 0; index < userOrganizations.length; index++) {
      if (userOrganizations[index].organizationId == curOrgId) {
        list.add(userOrganizations[index].organizationName);
        list.add(userOrganizations[index].organizationUrl);
        break;
      }
    }
    return list;
  }

  static String getTimeAgo(DateTime date, BuildContext context) {
    return timeago.format(date,
        allowFromNow: false, locale: context.locale.languageCode);
  }

  static requestPermissionDialog(
      BuildContext context, String title, String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(text),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancel'.tr()),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Settings'.tr()),
                  onPressed: () => openAppSettings(),
                ),
              ],
            ));
  }

  static requestPermissionDialogForStorage(
      BuildContext context, String title, String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            CupertinoDialogAction(
              child: Text('Deny'.tr()),

              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: Text('Allow'.tr()),
              onPressed: () => openAppSettings(),
            ),
          ],
        ));
  }

  static bool validateWorkTime(
      BuildContext context, String groupId, int workHour) {
    if (groupId == '') {
      showToast(context, 'Select a group'.tr());
      return false;
    } else if (workHour == 0) {
      showToast(context, 'Select hour'.tr());
      return false;
    } else
      return true;
  }

  static fileFromImageUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(documentDirectory.path + 'imageTest.png');
    file.writeAsBytesSync(response.bodyBytes);
  }

  static Future<List<int>> readFile() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(documentDirectory.path + 'imageTest.png');
    List<int> bytes = await file.readAsBytes();
    return bytes;
  }

  static Future<String> fileFromImageUrlForFaceBook(String url,String name) async {
    final String facebookName=Uuid().v1().toString();
    final directory = (await getApplicationDocumentsDirectory()).path;
    final http.Response response = await http.get(Uri.parse(url));;
    final imagePath = await File('$directory/$facebookName.jpg').create();
    await imagePath.writeAsBytes(response.bodyBytes);
    return imagePath.path;
  }


  static Future<List<int>> downloadFileForGroupMessage(
      String url, String fileName) async {
    final http.Response response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(documentDirectory.path + '${fileName}');
    file.writeAsBytesSync(response.bodyBytes);
    List<int> bytes = await file.readAsBytes();
    return bytes;
  }

  static bool validateSignIn(
      String mail, String password, BuildContext context) {
    if (mail.trim().isEmpty || !mail.trim().isValidEmail()) {
      showSnackBar(context, 'Email is empty/invalid'.tr());
      return false;
    } else if (password.isEmpty || password.length < 6) {
      showSnackBar(
          context, 'Password must not be empty and longer than six'.tr());
      return false;
    } else
      return true;
  }

  static void showPoliciesDialog(BuildContext context){
    showDialog(context: context, builder: (context){
      return ShowPolicies();
    });
  }
}
