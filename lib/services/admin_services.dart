import 'dart:io';
import 'package:easy_localization/src/public_ext.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/services/version.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class AdminServices {

  final userRef = Configuration.isProduction?FirebaseFirestore.instance.collection('users'):FirebaseFirestore.instance.collection('users_test');
  final bookingRefs = Configuration.isProduction?FirebaseFirestore.instance.collection('bookings'):FirebaseFirestore.instance.collection('bookings_test');
  final orgRef = Configuration.isProduction?FirebaseFirestore.instance.collection('organizations'):FirebaseFirestore.instance.collection('organizations_test');
  final versionCheck=VersionCheck();
  final approvalRef=FirebaseFirestore.instance.collection('approvalRef');

  //gets all the users
  List<CurrentUserData> _currentAppUserFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return CurrentUserData.fromMap(e.data());
    }).toList();

  }

  Stream<List<CurrentUserData>> getUsersToBeApproved(String adminCompanyId) {
    return userRef
        .where('adminRegistry',arrayContains: {'organizationId':adminCompanyId,'isApproved':false})
        .snapshots()
        .map(_currentAppUserFromSnapShot);
  }

  Stream<List<CurrentUserData>> getUsersForOrganization(String adminCompanyId) {
    return userRef
        .where('adminRegistry',arrayContains: {'organizationId':adminCompanyId,'isApproved':true})
        .snapshots()
        .map(_currentAppUserFromSnapShot);
  }

  //gets all the bookings within a company whose isApproved field is false
  List<MyAppointment> _getBookingToApprove(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) => MyAppointment.fromMap(e.data())).toList();
  }

  Stream<List<MyAppointment>> getBookingsToApprove(String organizationId) {
    return bookingRefs
        .where('organizationId', isEqualTo: organizationId)
        .where('isActive', isEqualTo: true)
        .where('isConfirmed',isEqualTo: false)
        .snapshots()
        .map(_getBookingToApprove);
  }

  //approve booking with booking id
  Future approveBooking(String bookingId) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showToastWithoutContext(Strings.CHECK_INTERNET.tr());
      return;
    }
    try {
      await bookingRefs.doc(bookingId).update({'isConfirmed': true});
    }  catch (e) {
      print('approve booking'+e.toString());
      Utils.showErrorToast();
    }
  }

  Future deactivateBooking(String bookingId,BuildContext context) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showToastWithoutContext(Strings.CHECK_INTERNET.tr());
      return;
    }
    try {
      await bookingRefs.doc(bookingId).update({'isActive': false});
    }  catch (e) {
      print(e);
      Utils.showErrorToast();
    }
  }

  Future deleteBooking(String bookingId,BuildContext context) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showToastWithoutContext( Strings.CHECK_INTERNET.tr());
      return;
    }
    try {
      await bookingRefs.doc(bookingId).delete();
    }  catch (e) {
     Utils.showErrorToast();
    }
  }

  //updates user approve related fields
  Future updateApprovedUserCurrentCompanyIdAndArray(
      String organizationIdToApprove,
      CurrentUserData userToBeApproved,
      String userRole) async {

    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showToastWithoutContext( Strings.CHECK_INTERNET.tr());
      return;
    }

    await versionCheck.getOrganizationFromCode(organizationIdToApprove).then((value) async {
      if(userRole=='4'){
        updateAdminCountAndUserRole(value,organizationIdToApprove,userToBeApproved.uid);
        return;
      }
      if(value.currentUserCount>=value.targetUserCount){
        Utils.showToastWithoutContext('Please update your package to approve more users'.tr());
        return;
      }else{
        int currentUserCount=value.currentUserCount+1;
        await  orgRef.doc(value.organizationId).update({
          'currentUserCount':currentUserCount
        });
        try {
          DocumentReference docRef = userRef.doc(userToBeApproved.uid);
          DocumentSnapshot docSnapshot = await docRef.get();
          Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

          List<Map<String, dynamic>> userOrganizations =
          (docData["userOrganizations"] as List<dynamic>)
              .map((organization) => Map<String, dynamic>.from(organization))
              .toList();

          for (int index = 0; index < userOrganizations.length; index++) {
            Map<String, dynamic> organization = userOrganizations[index];
            if (organization['organizationId'] == organizationIdToApprove) {
              organization['isApproved'] = true;
              organization['userRole'] = userRole;
              break;
            }
          }

          List<Map<String, dynamic>> registry =
          (docData["adminRegistry"] as List<dynamic>)
              .map((registry) => Map<String, dynamic>.from(registry))
              .toList();

          for (int index = 0; index < registry.length; index++) {
            Map<String, dynamic> reg = registry[index];
            if (reg['organizationId'] == organizationIdToApprove) {
              reg['isApproved'] = true;
              break;
            }
          }

          await docRef.update({
            'userOrganizations': userOrganizations,
            'currentOrganizationId': organizationIdToApprove,
            'adminRegistry':registry
          });

        }  catch (e) {
          Utils.showErrorToast();
        }
      }
    });


  }

  // removes the organization from userOrganizations list on approve tab.
  Future removeUserFromOrganization(
      String organizationIdToApprove, CurrentUserData userToBeApproved,bool isBlocked) async {

    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showToastWithoutContext( Strings.CHECK_INTERNET.tr());
      return;
    }

    if(isBlocked){
      await versionCheck.getOrganizationFromCode(organizationIdToApprove).then((value) {
        final blockedUsers=value.blockedUsers;
        int currentUserCount=value.currentUserCount-1;

        if(currentUserCount<=0){
          currentUserCount=0;
        }

        if(!blockedUsers.contains(userToBeApproved.uid)){
          blockedUsers.add(userToBeApproved.uid);
        }

        orgRef.doc(value.organizationId).update({
          'blockedUsers':blockedUsers,
          'currentUserCount':currentUserCount
        });
      });
    }
    try {
      DocumentReference docRef = userRef.doc(userToBeApproved.uid);

      DocumentSnapshot docSnapshot = await docRef.get();
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> userOrganizations =
          (docData["userOrganizations"] as List<dynamic>)
              .map((organization) => Map<String, dynamic>.from(organization))
              .toList();

      for (int index = 0; index < userOrganizations.length; index++) {
        Map<String, dynamic> organization = userOrganizations[index];
        if (organization['organizationId'] == organizationIdToApprove) {
          userOrganizations.removeAt(index);
          break;
        }
      }

      List<Map<String, dynamic>> registry =
      (docData["adminRegistry"] as List<dynamic>)
          .map((registry) => Map<String, dynamic>.from(registry))
          .toList();

      for (int index = 0; index < registry.length; index++) {
        Map<String, dynamic> reg = registry[index];
        if (reg['organizationId'] == organizationIdToApprove) {
          registry.removeAt(index);
          break;
        }
      }

      await docRef.update({'userOrganizations': userOrganizations,'adminRegistry':registry});
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  // removes the organization from userOrganizations list on manage tab.
  //look into this part
  Future removeUserFromOrganizationManage(
      String organizationIdToApprove, CurrentUserData userToBeApproved,bool isUserBlocked,isAdminRemoved) async {

    //if user is blocked add it to blocked list and reduce the current user count
    if(isUserBlocked && !isAdminRemoved){
     await versionCheck.getOrganizationFromCode(organizationIdToApprove).then((value) {
          final blockedUsers=value.blockedUsers;
          int currentUserCount=value.currentUserCount-1;

          if(currentUserCount<=0){
            currentUserCount=0;
          }

          if(!blockedUsers.contains(userToBeApproved.uid)){
            blockedUsers.add(userToBeApproved.uid);
          }

          orgRef.doc(value.organizationId).update({
            'blockedUsers':blockedUsers,
            'currentUserCount':currentUserCount
          });
     });
    }//otherwise just reduce current user count
    else{
      await versionCheck.getOrganizationFromCode(organizationIdToApprove).then((value) {
        int currentUserCount=value.currentUserCount-1;

        if(currentUserCount<=0){
          currentUserCount=0;
        }
        orgRef.doc(value.organizationId).update({
          'currentUserCount':currentUserCount
        });
      });
    }

    //if admin is removed reduce admin count but not user count
    if(isAdminRemoved){
      await versionCheck.getOrganizationFromCode(organizationIdToApprove).then((value) {

        final admins=value.admins;

        if(admins.contains(userToBeApproved.uid)){
          admins.remove(userToBeApproved.uid);
        }

        orgRef.doc(value.organizationId).update({
          'admins':admins
        });
      });
    }
    //if admin is blocked as well add it to blocked user list and remove from admin list
    else if(isAdminRemoved &&isUserBlocked){
      await versionCheck.getOrganizationFromCode(organizationIdToApprove).then((value) {
        final blockedUsers=value.blockedUsers;
        final admins=value.admins;

        if(admins.contains(userToBeApproved.uid)){
          admins.remove(userToBeApproved.uid);
        }
        if(!blockedUsers.contains(userToBeApproved.uid)){
          blockedUsers.add(userToBeApproved.uid);
        }
        orgRef.doc(value.organizationId).update({
          'blockedUsers':blockedUsers,
          'admins':admins
        });
      });
    }


    //then continue to update user document
    DocumentReference docRef = userRef.doc(userToBeApproved.uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

    List<Map<String, dynamic>> userOrganizations =
        (docData["userOrganizations"] as List<dynamic>)
            .map((organization) => Map<String, dynamic>.from(organization))
            .toList();

    for (int index = 0; index < userOrganizations.length; index++) {
      //Map<String, dynamic> organization = userOrganizations[index];
      if (userOrganizations[index]['organizationId'] ==
          organizationIdToApprove) {
        // print(userOrganizations[index]);
        // print(index);
        userOrganizations.removeAt(index);
        // print(userOrganizations[index]);
        // print(index);
        break;
      }
    }

    List<Map<String, dynamic>> registry =
    (docData["adminRegistry"] as List<dynamic>)
        .map((registry) => Map<String, dynamic>.from(registry))
        .toList();

    for (int index = 0; index < registry.length; index++) {
      Map<String, dynamic> reg = registry[index];
      if (reg['organizationId'] == organizationIdToApprove) {
        registry.removeAt(index);
        break;
      }
    }

    if (userOrganizations.length >= 1) {
      for (int index = 0; index < userOrganizations.length; index++) {
        if (userOrganizations[index]['isApproved'] == true) {
          String currentOrganizationId =
              userOrganizations[index]['organizationId'];
          print(currentOrganizationId);
          await docRef.update({
            'userOrganizations': userOrganizations,
            'currentOrganizationId': currentOrganizationId,
            'adminRegistry':registry
          });
          break;
        } else {
          print('is approved not found');
          await docRef.update({
            'userOrganizations': userOrganizations,
            'currentOrganizationId': '',
            'adminRegistry':registry
          });
          break;
        }
      }
    } else if (userOrganizations.length == 0) {
      await docRef.update({
        'userOrganizations': userOrganizations,
        'currentOrganizationId': '',
        'adminRegistry':registry
      });
    }
  }

  //gets a single organization to update
  Organization _getOrganization(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return Organization.fromMap(e.data());
    }).toList()[0];
  }

  Stream<Organization> getOrganization(String orgId) {
    return orgRef
        .where('organizationId', isEqualTo: orgId)
        .snapshots()
        .map(_getOrganization);
  }

  ///updates organization picture as well as any user who has given organization on the list.
  Future updateOrgPic(String orgId, File file,MyProvider provider) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showToastWithoutContext( Strings.CHECK_INTERNET.tr());
      return;
    }
    try {
      var reference = FirebaseStorage.instance.ref().child('organizationPics').child('$orgId');
      final UploadTask uploadTask = reference.putFile(file);
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = await downloadUrl.ref.getDownloadURL();
      await orgRef.doc(orgId).update({'organizationUrl': url});
      final userList=provider.getCurrentOrganizationUserList(orgId);
      userList.forEach((element) async {
        DocumentReference docRef = userRef.doc(element.uid);
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> userOrganizations =
        (docData["userOrganizations"] as List<dynamic>)
            .map((organization) => Map<String, dynamic>.from(organization))
            .toList();
        for (int index = 0; index < userOrganizations.length; index++) {
          Map<String, dynamic> organization = userOrganizations[index];
          if (organization['organizationId'] == orgId) {
            organization['organizationUrl']=url;
            break;
          }
        }
        await docRef.update({'userOrganizations':userOrganizations});
      });
    }  catch (e) {
      Utils.showErrorToast();
    }
  }



  ///update organization name as well as any user who has given organization on the list.
  /// also add a name check later so that no two company would have the same name...
  Future updateOrgName(String orgId, String orgName,MyProvider provider) async {

    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showToastWithoutContext( Strings.CHECK_INTERNET.tr());
      return;
    }
    try {
      await orgRef.doc(orgId).update({'organizationName': orgName});
      final userList=provider.getCurrentOrganizationUserList(orgId);
      userList.forEach((element) async {
        DocumentReference docRef = userRef.doc(element.uid);
            DocumentSnapshot docSnapshot = await docRef.get();
            Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
            List<Map<String, dynamic>> userOrganizations =
            (docData["userOrganizations"] as List<dynamic>)
                .map((organization) => Map<String, dynamic>.from(organization))
                .toList();
            for (int index = 0; index < userOrganizations.length; index++) {
              Map<String, dynamic> organization = userOrganizations[index];
              if (organization['organizationId'] == orgId) {
                organization['organizationName']=orgName;
                break;
              }
            }
            await docRef.update({'userOrganizations':userOrganizations});
          });
    }  catch (e) {
      Utils.showErrorToast();
    }
    }


    //updates user role
  Future updateUserRole(String orgId, String role, String uid) async {
    if(role=='4'){
      await versionCheck.getOrganizationFromCode(orgId).then((organization) async{
        final adminCount=organization.admins.length;
        final currentSubLevel=organization.subLevel;
        final adminList=organization.admins;
        int currentUserCount=organization.currentUserCount;
        if(currentSubLevel=='freemium'){
          Utils.showToastWithoutContext('Please update your package to add more admins'.tr());
          Utils.showToastWithoutContext('Current package: ${organization.subLevel}');
          return;
        }else if(currentSubLevel=='premium' && adminCount>=2){
          Utils.showToastWithoutContext('please update your package to add more admins'.tr());
          Utils.showToastWithoutContext('Current package: ${organization.subLevel}');
          return;
        }else if(currentSubLevel=='premium+' && adminCount>=5){
          Utils.showToastWithoutContext('Please update your package to add more admins'.tr());
          Utils.showToastWithoutContext('Current package: ${organization.subLevel}');
          return;
        }else{
          if(!adminList.contains(uid)){
            adminList.add(uid);
            currentUserCount=currentUserCount<=0?currentUserCount:currentUserCount-1;
          }else if(adminList.contains(uid)){
            Utils.showToastWithoutContext('This user is already an admin'.tr());
            return;
          }

          orgRef.doc(organization.organizationId).update({
            'admins':adminList,
            'currentUserCount':currentUserCount
          });
          DocumentReference docRef = userRef.doc(uid);
          DocumentSnapshot docSnapshot = await docRef.get();
          Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

          List<Map<String, dynamic>> userOrganizations =
          (docData["userOrganizations"] as List<dynamic>)
              .map((organization) => Map<String, dynamic>.from(organization))
              .toList();

          for (int index = 0; index < userOrganizations.length; index++) {
            Map<String, dynamic> organization = userOrganizations[index];
            if (organization['organizationId'] == orgId) {
              organization['userRole']=role;
              break;
            }
          }

          await docRef.update({'userOrganizations':userOrganizations});
        }
      });
    }else{
      DocumentReference docRef = userRef.doc(uid);
      DocumentSnapshot docSnapshot = await docRef.get();
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> userOrganizations =
      (docData["userOrganizations"] as List<dynamic>)
          .map((organization) => Map<String, dynamic>.from(organization))
          .toList();

      for (int index = 0; index < userOrganizations.length; index++) {
        Map<String, dynamic> organization = userOrganizations[index];
        if (organization['organizationId'] == orgId) {
          organization['userRole']=role;
          break;
        }
      }

      await docRef.update({'userOrganizations':userOrganizations});
    }


  }


  Future updateAdminCountAndUserRole(Organization organization,String organizationIdToApprove,String uid) async {
     final adminCount=organization.admins.length;
     final currentSubLevel=organization.subLevel;
     final adminList=organization.admins;
     if(currentSubLevel=='freemium'){
       Utils.showToastWithoutContext('Please update your package to add more admins'.tr());
       Utils.showToastWithoutContext('Current package: ${organization.subLevel}');
       return;
     }else if(currentSubLevel=='premium' && adminCount>=2){
       Utils.showToastWithoutContext('please update your package to add more admins'.tr());
       Utils.showToastWithoutContext('Current package: ${organization.subLevel}');
       return;
     }else if(currentSubLevel=='premium+' && adminCount>=5){
       Utils.showToastWithoutContext('Please update your package to add more admins'.tr());
       Utils.showToastWithoutContext('Current package: ${organization.subLevel}');
       return;
     }else{
       try {
         ///update organization admin list
         adminList.add(uid);
         orgRef.doc(organization.organizationId).update({
           'admins':adminList
         });
         ///update user document
         DocumentReference docRef = userRef.doc(uid);
         DocumentSnapshot docSnapshot = await docRef.get();
         Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

         List<Map<String, dynamic>> userOrganizations =
         (docData["userOrganizations"] as List<dynamic>)
             .map((organization) => Map<String, dynamic>.from(organization))
             .toList();

         for (int index = 0; index < userOrganizations.length; index++) {
           Map<String, dynamic> organization = userOrganizations[index];
           if (organization['organizationId'] == organizationIdToApprove) {
             organization['isApproved'] = true;
             organization['userRole'] = '4';
             break;
           }
         }

         List<Map<String, dynamic>> registry =
         (docData["adminRegistry"] as List<dynamic>)
             .map((registry) => Map<String, dynamic>.from(registry))
             .toList();

         for (int index = 0; index < registry.length; index++) {
           Map<String, dynamic> reg = registry[index];
           if (reg['organizationId'] == organizationIdToApprove) {
             reg['isApproved'] = true;
             break;
           }
         }

         await docRef.update({
           'userOrganizations': userOrganizations,
           'currentOrganizationId': organizationIdToApprove,
           'adminRegistry':registry
         });

       }  catch (e) {
         Utils.showErrorToast();
       }
     }
  }

 Future updateOrgInfo(String orgId,String orgAboutController, String orgContactPersonController,
     String orgEPostController, String orgMobilController, String orgAddressController,
     String orgWebsiteController) async{
    await orgRef.doc(orgId).update({
      'about':orgAboutController,
      'contactPerson':orgContactPersonController,
      'ePost':orgEPostController,
      'mobil':orgMobilController,
      'address':orgAddressController,
      'website':orgWebsiteController
    });
 }

  Future<void> sendApprovalRequest(Organization organization) async {

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await approvalRef.get();
    bool isFound=false;
    for(var i=0;i<querySnapshot.size;i++){
      if(querySnapshot.docs[i].data()['organizationId']==organization.organizationId){
        isFound=true;
        break;
      }
    }
    if(isFound){
      Utils.showToastWithoutContext('Your approval request is being processed'.tr());
      return;
    }
    final approvalId=Uuid().v1().toString();
    approvalRef.doc(approvalId).set({
      'approvalId':approvalId,
      'organizationId':organization.organizationId,
      'organizationNumber':organization.organizationNumber
    });
  }

}
