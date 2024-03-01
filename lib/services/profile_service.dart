import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ProfileService {
  final refUsers = Configuration.isProduction?FirebaseFirestore.instance.collection('users'):FirebaseFirestore.instance.collection('users_test');
  final storage = FirebaseStorage.instance;

  Future<String> updateProfilePic(String uid, File file) async {
    var reference =
        FirebaseStorage.instance.ref().child('usersProfilePic').child('$uid');
    final UploadTask uploadTask = reference.putFile(file);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future updateUserInfo(
      String uid,
      String userName,
      String userSurname,
      String? userPhone,
      File? file,
      String oldUrl,
      BuildContext context) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }


    Utils.showToastWithoutContext('Updating please wait...'.tr());
    try {
      String newUrl = file!=null?'':oldUrl;
      if(file!=null){
        await updateProfilePic(uid, file).then((value) => newUrl=value);
      }
      refUsers.doc(uid).update({
        'userName': userName,
        'userSurname': userSurname,
        'userPhone': userPhone,
        'userUrl': newUrl
      });
      Navigator.pop(context);
      Utils.showToastWithoutContext('Profile updated'.tr());
    } catch (e) {
      Utils.showErrorToast();
    }
  }
}
