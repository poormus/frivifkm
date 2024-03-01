import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/models/room.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class FireBaseServices {

  final appointmentRef = Configuration.isProduction?FirebaseFirestore.instance.collection('bookings')
      :FirebaseFirestore.instance.collection('bookings_test');
  final roomRef = Configuration.isProduction?FirebaseFirestore.instance.collection('rooms')
      :FirebaseFirestore.instance.collection('rooms_test');

  Future addBooking(
      DateTime startTime,
      DateTime endTime,
      String subject,
      Color color,
      String roomId,
      String organizationId,
      String userId,
      String? note,
      String roomName,
      String userName
      ) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      String appointmentId = Uuid().v1().toString();
      appointmentRef.doc(appointmentId).set({
        'roomId': roomId,
        'appointmentId': appointmentId,
        'organizationId': organizationId,
        'roomName': roomName,
        'userId': userId,
        'isConfirmed': false,
        'note': note,
        'startTime': startTime,
        'endTime': endTime,
        'subject': subject,
        'color': color.value.toString(),
        'isActive':true,
        'userName':userName
      });
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  Future updateBooking(
      DateTime startTime,
      DateTime endTime,
      String subject,
      Color color,
      String appointmentId,
      String? note,
      ) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      appointmentRef.doc(appointmentId).update({
        'isConfirmed': false,
        'note': note,
        'startTime': startTime,
        'endTime': endTime,
        'subject': subject,
        'color': color.value.toString(),
        'isActive':true,
      });
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  ///adds a room according to company id
  Future addRoom(String companyId, String roomCapacity, String roomName,
      String roomSize, File file, List<String> amenities,BuildContext context,String createdBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    Utils.showToastWithoutContext('Adding room...'.tr());
    try {
      final roomId = Uuid().v1().toString();
      var reference = FirebaseStorage.instance.ref().child('roomPics').child('$roomId');
      final UploadTask uploadTask = reference.putFile(file);
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String roomUrl = await downloadUrl.ref.getDownloadURL();
      final room = Room(
          roomName: roomName,
          companyId: companyId,
          roomId: roomId,
          roomCapacity: roomCapacity,
          roomSize: roomSize,
          roomUrl: roomUrl,
          amenities: amenities,
           createdBy: createdBy
      );
      await roomRef.doc(roomId).set(room.toMap());
      Navigator.pop(context);
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  ///updates a room according to company id
  Future updateRoom(
      String companyId,
      String roomId,
      String roomCapacity,
      String roomName,
      String roomSize,
      File? file,
      String oldUrl,
      List<String> amenities,BuildContext context,String createdBy) async {


    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    Utils.showToastWithoutContext('Updating room...'.tr());
    try {
      String newRoomUrl = file!=null?'':oldUrl;
      if (file != null) {
       await updateRoomUrl(file, roomId).then((value) => newRoomUrl=value);
      }
      final room = Room(
          roomName: roomName,
          companyId: companyId,
          roomId: roomId,
          roomCapacity: roomCapacity,
          roomSize: roomSize,
          roomUrl: newRoomUrl,
          amenities: amenities,
          createdBy: createdBy
      );
      await roomRef.doc(roomId).update(room.toMap());
      Navigator.pop(context);
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  Future<String> updateRoomUrl(File file, String roomId) async {
    var reference = FirebaseStorage.instance.ref().child('roomPics').child('$roomId');
    final UploadTask uploadTask = reference.putFile(file);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  //streams all room appointments based on roomId
  List<MyAppointment> _appointmentFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return MyAppointment(
          roomId: e.data()['roomId'],
          appointmentId: e.data()['appointmentId'],
          organizationId: e.data()['organizationId'],
          roomName: e.data()['roomName'],
          userId: e.data()['userId'],
          isConfirmed: e.data()['isConfirmed'],
          note: e.data()['note'],
          startTime: Utils.toDateTime(e.data()['startTime']),
          endTime: Utils.toDateTime(e.data()['endTime']),
          subject: e.data()['subject'],
          color: Color(int.parse(e.data()['color'])).withOpacity(1),
          isActive: e.data()['isActive'],
          userName: e.data()['userName']
      );

    }).toList();
  }

  Stream<List<MyAppointment>> appointments(String roomId) {
    return appointmentRef
        .where('roomId', isEqualTo: roomId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((_appointmentFromSnapShot));
  }



  // streams appointments of the current user
  List<MyAppointment> _appointmentFromSnapShotUser(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return MyAppointment(
          roomId: e.data()['roomId'],
          appointmentId: e.data()['appointmentId'],
          organizationId: e.data()['organizationId'],
          roomName: e.data()['roomName'],
          userId: e.data()['userId'],
          isConfirmed: e.data()['isConfirmed'],
          note: e.data()['note'],
          startTime: Utils.toDateTime(e.data()['startTime']),
          endTime: Utils.toDateTime(e.data()['endTime']),
          subject: e.data()['subject'],
          color: Color(int.parse(e.data()['color'])).withOpacity(1),
          isActive: e.data()['isActive'],
          userName: e.data()['userName']
      );
    }).toList();
  }

  Stream<List<MyAppointment>> userAppointments(
      String organizationId, String uid) {
    return appointmentRef
        .where('organizationId', isEqualTo: organizationId)
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((_appointmentFromSnapShotUser));
  }

  //streams all the rooms for a organization
  List<Room> _roomsFromSnapShot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return Room.fromMap(e.data());
    }).toList();
  }

  Stream<List<Room>> getAllRooms(String companyId) {
    return roomRef
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map(_roomsFromSnapShot);
  }

  ///deletes a room based on room id
  Future deleteRoom(String roomId,BuildContext context) async {

    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      await FirebaseStorage.instance.ref().child('roomPics').child('$roomId').delete();
      await roomRef.doc(roomId).delete();
      Navigator.of(context).pop();
    }  catch (e) {
      Utils.showErrorToast();
    }
  }
}
