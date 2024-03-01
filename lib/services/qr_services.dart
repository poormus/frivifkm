import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/qr_scan.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class QrServices {


   CollectionReference<Map<String, dynamic>> qrRef= Configuration.isProduction
      ? FirebaseFirestore.instance.collection('qrData')
      : FirebaseFirestore.instance.collection('qrData_test');



  Future addQrEntry(String organizationId, String uid, String userName) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      String id = Uuid().v4().toString();
      DateTime createdAt = DateTime.now();
      qrRef.doc(id).set({
        'id': id,
        'organizationId': organizationId,
        'uid': uid,
        'createdAt': createdAt,
        'userName': userName,
        'logType': 'pending'
      });
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Stream<List<QrScan>> getQrListForUser(String organizationId, String uid) {
    return qrRef
        .where('organizationId', isEqualTo: organizationId)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => QrScan.fromMap(e.data())).toList());
  }

  Stream<List<QrScan>> getQrLogForAdmin(String organizationId) {
    return qrRef
        .where('organizationId', isEqualTo: organizationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => QrScan.fromMap(e.data())).toList());
  }

  Future updateLogType(String qrId, String logType) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      qrRef.doc(qrId).update({'logType': logType});
    } catch (e) {
      Utils.showErrorToast();
    }
  }


}
