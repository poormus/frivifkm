import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
//import "package:googleapis_auth/auth_io.dart";
import 'package:shared_preferences/shared_preferences.dart';

class Storage {

  // Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  //
  // void write(String key, Map<String, dynamic> map) {
  //   String encodedMap = json.encode(map);
  //   prefs.then((value) {
  //     value.setString(key, encodedMap);
  //   });
  // }
  //
  // void saveAccessToken(String token) {
  //   prefs.then((value) {
  //     value.setString('accessTokenData', token);
  //   });
  // }
  //
  // void saveString(String key,String value){
  //   prefs.then((pref) => pref.setString(key, value));
  // }
  // void saveListString(String key,List<String> value){
  //   prefs.then((pref) => pref.setStringList(key, value));
  // }
  //
  // AccessCredentials getCredentials(String key) {
  //   String encodedMap = '';
  //   prefs.then((value) {
  //     encodedMap = value.getString(key) ?? '';
  //   });
  //   Map<String, dynamic> map = json.decode(encodedMap);
  //   final credentials= AccessCredentials(
  //       AccessToken("Bearer", map["accessTokenData"] as String,
  //           DateTime.parse(map["accessTokenExpiry"])),
  //       map["refreshToken"],
  //       List.castFrom(map["scopes"]),
  //       idToken: map["idToken"] as String);
  //
  //   return credentials;
  // }
  //
  // Future<AccessCredentials> getCreds() async {
  //   String accessTokenData='';
  //   String accessTokenExpiry='';
  //   String refreshToken='';
  //   List<String> scopes=[];
  //   String idToken='';
  //    await prefs.then((pref)  {
  //     accessTokenData=pref.getString('accessTokenData')??'';
  //     accessTokenExpiry=pref.getString('accessTokenExpiry')??'';
  //     refreshToken=pref.getString('refreshToken')??'';
  //     scopes=pref.getStringList('scopes')??[];
  //     idToken=pref.getString('idToken')??'';
  //     // print(accessTokenData);
  //     // print(accessTokenExpiry);
  //     // print(refreshToken);
  //     // print(scopes);
  //     // print(idToken);
  //     // print(DateTime.parse(accessTokenExpiry));
  //   });
  //
  //   DateTime date=DateTime.parse(accessTokenExpiry).toUtc();
  //   return AccessCredentials(AccessToken("Bearer",accessTokenData,date),
  //       refreshToken, scopes,idToken: idToken);
  // }
}
