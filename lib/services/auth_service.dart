import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/helper/email_helper.dart';
import 'package:firebase_calendar/models/admin_registry.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/user_companies.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final userRef = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('users')
      : FirebaseFirestore.instance.collection('users_test');
  final organizationRef = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('organizations')
      : FirebaseFirestore.instance.collection('organizations_test');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CurrentUser? _userFromFireBaseUser(User? user) {
    return user != null ? CurrentUser(uid: user.uid) : null;
  }

  Stream<CurrentUser?> get user {
    return _auth.authStateChanges().map(_userFromFireBaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        if (!user.emailVerified) {
          user.sendEmailVerification();
        }
      }
      OneSignal.login(user!.uid);

      return _userFromFireBaseUser(user);
    } catch (e) {
      String str = e.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      return Future.error(str);
    }
  }

  Future registerWithEmailAndPassword(
      String email,
      String password,
      String userName,
      String userSurname,
      List<Organization> userOrganizations) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      //send a verification mail...
      user?.sendEmailVerification();
      final List<UserOrganizations> org = [];
      final List<AdminRegistry> registry = [];
      userOrganizations.forEach((element) {
        UserOrganizations organization = UserOrganizations(
            organizationId: element.organizationId,
            organizationName: element.organizationName,
            organizationUrl: element.organizationUrl,
            isApproved: false,
            userRole: 'pending');
        org.add(organization);
        AdminRegistry adminRegistry = AdminRegistry(
            organizationId: element.organizationId, isApproved: false);
        registry.add(adminRegistry);
      });

      OneSignal.login(user!.uid);
      userRef.doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'userName': userName,
        'userSurname': userSurname,
        'userOrganizations': org.map((e) => e.toMap()).toList(),
        'currentOrganizationId': '',
        'userUrl': Constants.IMAGE_HOLDER,
        'userPhone': '',
        'groupIds': [],
        'adminRegistry': registry.map((e) => e.toMap()).toList(),
        'totalPoint': 0
      });

      return _userFromFireBaseUser(user);
    } catch (e) {
      String str = e.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      return Future.error(str);
    }
  }

  Future registerWithEmailAndPasswordAsAdmin(
    String email,
    String password,
    String userName,
    String userSurname,
    String organizationName,
    File file,
    BuildContext context,
    MyProvider provider,
    String organizationNumber,
    bool isApproved,
  ) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }

    final list = provider.organizationsForValidation;
    bool isExist = false;

    for (var i = 0; i < list.length; i++) {
      if (list[i].organizationNumber == organizationNumber) {
        isExist = true;
        break;
      }
    }

    if (isExist) {
      Utils.showToast(
          context, 'An organization with that name/number already exits'.tr());
      return;
    }

    Utils.showToastWithoutContext('Registering please wait...'.tr());
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      //send a verification mail...
      user?.sendEmailVerification();

      List<Organization> organizations = [];
      String organizationId = Uuid().v4().toString();
      var organizationUrl = '';
      await uploadOrganizationPicture(organizationId, file)
          .then((value) => organizationUrl = value);
      List<String> admins = ['${user!.uid}'];
      Organization newOrg = Organization(
          organizationId: organizationId,
          organizationName: organizationName,
          organizationUrl: organizationUrl,
          admins: admins,
          organizationNumber: organizationNumber,
          isApproved: false,
          currentUserCount: 0,
          targetUserCount: 5,
          subLevel: 'freemium',
          blockedUsers: [],
          website: '',
          mobil: '',
          ePost: '',
          contactPerson: '',
          about: '',
          address: '');
      await organizationRef.doc(organizationId).set(newOrg.toMap());
      //EMailHelper.sendRegistrationNotification();
      organizations.add(newOrg);
      final List<UserOrganizations> org = [];
      organizations.forEach((element) {
        UserOrganizations organization = UserOrganizations(
          organizationId: element.organizationId,
          organizationName: element.organizationName,
          organizationUrl: element.organizationUrl,
          isApproved: true,
          userRole: '4',
        );
        org.add(organization);
      });
      OneSignal.login(user.uid);
      await userRef.doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'userName': userName,
        'userSurname': userSurname,
        'userOrganizations': org.map((e) => e.toMap()).toList(),
        'currentOrganizationId': organizationId,
        'userUrl': Constants.IMAGE_HOLDER,
        'userPhone': '',
        'groupIds': [],
        'adminRegistry': [
          {'organizationId': organizationId, 'isApproved': true}
        ],
        'totalPoint': 0
      });
      Utils.showToast(context, 'Registered'.tr());
      Navigator.pop(context);
      return _userFromFireBaseUser(user);
    } catch (e) {
      String str = e.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      return Future.error(str);
    }
  }

  Future<String> uploadOrganizationPicture(
      String organizationId, File file) async {
    var reference = FirebaseStorage.instance
        .ref()
        .child('organizationPics')
        .child('$organizationId');
    final UploadTask uploadTask = reference.putFile(file);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  //signs user out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  //gets current user
  CurrentUserData _currentAppUserFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return CurrentUserData.fromMap(e.data());
    }).toList()[0];
  }

  Stream<CurrentUserData> getCurrentUser(String idUser) {
    return userRef
        .where('uid', isEqualTo: idUser)
        .snapshots()
        .map(_currentAppUserFromSnapShot);
  }

  //gets all available organizations for register screen
  List<Organization> _getAllOrganizations(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return Organization.fromMap(e.data());
    }).toList();
  }

  Stream<List<Organization>> allOrganizations() {
    return organizationRef
        .where('isApproved', isEqualTo: true)
        .orderBy('organizationName')
        .snapshots()
        .map(_getAllOrganizations);
  }

  Stream<List<Organization>> allOrganizationsForSuperAdmin() {
    return organizationRef.snapshots().map(_getAllOrganizations);
  }

  //add all the organization to list for validation of a newly created organization
  //so that no two organizations will have the same name...
  Future allOrganizationsList(MyProvider provider) async {
    final organizations = await organizationRef.get();
    final list =
        organizations.docs.map((e) => Organization.fromMap(e.data())).toList();
    provider.setOrganizationForValidation(list);
  }

  ///updates user organization id  when select organization is selected on drawer
  Future updateCurOrganizationForUser(
      String uid, String organizationIdToUpdate, BuildContext context) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      await userRef.doc(uid).update({
        'currentOrganizationId': organizationIdToUpdate,
      });
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e.toString());
      Utils.showErrorToast();
    }
  }

  Future updateUserOrganizationList(
      String uid, List<Organization> listOfOrganizations) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      DocumentReference docRef = userRef.doc(uid);
      DocumentSnapshot docSnapshot = await docRef.get();
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> userOrganizations =
          (docData["userOrganizations"] as List<dynamic>)
              .map((organization) => Map<String, dynamic>.from(organization))
              .toList();

      List<Map<String, dynamic>> registry =
          (docData["adminRegistry"] as List<dynamic>)
              .map((registry) => Map<String, dynamic>.from(registry))
              .toList();

      listOfOrganizations.forEach((element) {
        AdminRegistry adminRegistry = AdminRegistry(
            organizationId: element.organizationId, isApproved: false);

        UserOrganizations organizations = UserOrganizations(
          organizationId: element.organizationId,
          organizationName: element.organizationName,
          organizationUrl: element.organizationUrl,
          isApproved: false,
          userRole: '',
        );
        registry.add(adminRegistry.toMap());
        userOrganizations.add(organizations.toMap());
      });
      await docRef.update(
          {'userOrganizations': userOrganizations, 'adminRegistry': registry});
      Utils.showToastWithoutContext('Request has been sent'.tr());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future passwordReset(String email, BuildContext context) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Utils.showToast(
          context,
          'If you are a registered user an e mail will be sent  to you with instructions'
              .tr());
      Navigator.pop(context);
    } catch (err) {
      String str = err.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      print(str);
      Utils.showSnackBar(context, str);
    }
  }

  Future updateUserOrgListForCode(String uid, UserOrganizations userOrg) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      DocumentReference docRef = userRef.doc(uid);
      DocumentSnapshot docSnapshot = await docRef.get();
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> userOrganizations =
          (docData["userOrganizations"] as List<dynamic>)
              .map((organization) => Map<String, dynamic>.from(organization))
              .toList();

      List<Map<String, dynamic>> registry =
          (docData["adminRegistry"] as List<dynamic>)
              .map((registry) => Map<String, dynamic>.from(registry))
              .toList();

      final newRegistry = AdminRegistry(
          organizationId: userOrg.organizationId, isApproved: false);
      registry.add(newRegistry.toMap());

      userOrganizations.add(userOrg.toMap());

      docRef.update(
          {'userOrganizations': userOrganizations, 'adminRegistry': registry});
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  //streams current users current organization...
  Organization _getOrganization(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return Organization.fromMap(e.data());
    }).toList()[0];
  }

  Stream<Organization> getOrganization(String orgId) {
    return organizationRef
        .where('organizationId', isEqualTo: orgId)
        .snapshots()
        .map(_getOrganization);
  }

  ///delete account
  Future deleteAccount(String uid) async {
    if (_auth.currentUser != null) {
      _auth.currentUser!.delete();
      userRef.doc(uid).delete();
    }
  }

  updateOrganizationApproval(bool appprove, String orgId) async {
    await organizationRef.doc(orgId).update({'isApproved': appprove});
  }

  updateOrganizationSubLevel(String subLevel, String orgId) async {
    await organizationRef.doc(orgId).update({'subLevel': subLevel});
  }
}
