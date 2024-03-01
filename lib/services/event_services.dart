import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/models/event_chat.dart';
import 'package:firebase_calendar/models/external_user.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class EventServices {
  final eventRef = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('events')
      : FirebaseFirestore.instance.collection('events_test');
  final groupRef = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('groups')
      : FirebaseFirestore.instance.collection('groups_test');
  final eventChats = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('eventChats')
      : FirebaseFirestore.instance.collection('eventChats_test');


  late Stream<List<Event>> publicEvents;

  Future createEvent(
      String organizationId,
      String createdByUid,
      String eventName,
      DateTime eventDate,
      DateTime eventStartTime,
      DateTime eventEndTime,
      File eventImage,
      String eventAddress,
      String eventInformation,
      List<String> toWho,
      bool isPublic,
      BuildContext context,
      String orgName,
      String category,
      String city,
      Coordinates? coordinates
      ) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    Utils.showToast(context, 'creating event please wait...'.tr());
    try {
      String eventId = Uuid().v4().toString();
      String eventUrl = '';
      await uploadEventPhoto(eventImage, eventId).then((url) => eventUrl = url);

      Event event = Event(
          eventId: eventId,
          organizationId: organizationId,
          createdByUid: createdByUid,
          eventName: eventName,
          eventDate: eventDate,
          eventStartTime: eventStartTime,
          eventEndTime: eventEndTime,
          eventUrl: eventUrl,
          eventAddress: eventAddress,
          eventInformation: eventInformation,
          toWho: toWho,
          attendingUids: [],
          declinedUids: [],
          commentCount: 0,
          isPublic: isPublic,
          externalUsers: [],
          city: city,
          category: category,
          organizationName: orgName,
          coordinates: coordinates
      );

      eventRef.doc(eventId).set(event.toMap());
      Navigator.pop(context);
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future updateEvent(
    String eventId,
    String eventName,
    DateTime eventDate,
    DateTime eventStartTime,
    DateTime eventEndTime,
    File? file,
    String oldEventUrl,
    String eventAddress,
    String eventInformation,
    List<String> toWho,
      bool isPublic,
    BuildContext context,String city,String category,Coordinates? coordinates
  ) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    Utils.showToast(context, 'Updating please wait...'.tr());
    try {
      String newEventUrl = file != null ? '' : oldEventUrl;
      if (file != null) {
        await uploadEventPhoto(file, eventId)
            .then((value) => newEventUrl = value);
      }
      eventRef.doc(eventId).update({
        'eventDate': eventDate,
        'eventStartTime': eventStartTime,
        'eventEndTime': eventEndTime,
        'eventUrl': newEventUrl,
        'eventName': eventName,
        'toWho': toWho,
        'eventInformation': eventInformation,
        'eventAddress': eventAddress,
        'isPublic':isPublic,
        'city':city,
        'category':category,
        'coordinates':coordinates?.toMap()
      });
      Navigator.pop(context);
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future<String> uploadEventPhoto(File file, String eventId) async {
    var reference =
        FirebaseStorage.instance.ref().child('eventPics').child('$eventId');
    final UploadTask uploadTask = reference.putFile(file);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future getGroupsForEvent(String organizationId, MyProvider provider) async {
    return groupRef
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map((event) => event.docs.map((e) => Group.fromMap(e.data())).toList())
        .forEach((element) {
      provider.setGroupList(element);
    });
  }

  Stream<List<Event>> getEventsForOrganization(String organizationId) {
    return eventRef
        .where('organizationId', isEqualTo: organizationId)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((event){
          print(event.docs);
          return event.docs.map((e) => Event.fromMap(e.data())).toList();
    });
  }

  Stream<List<Event>> getAllEvents(String city,MyProvider provider) {
    final stream= eventRef
        .where('isPublic', isEqualTo: true)
        .where('city',isEqualTo: city)
         .where('eventDate' ,isGreaterThanOrEqualTo: new DateTime.now())
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((event) => event.docs.map((e) => Event.fromMap(e.data())).toList());
    publicEvents=stream;
    return stream;
  }

  Future updateAttendingUidList(Event event, String uid) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {

      List<String> declinedUidList = event.declinedUids;
      List<String> attendingUidList = event.attendingUids;

      if(attendingUidList.contains(uid)){
        attendingUidList.remove(uid);
        await eventRef.doc(event.eventId).update(
            {'declinedUids': declinedUidList, 'attendingUids': attendingUidList});
        return;
      }
      if (!attendingUidList.contains(uid)) {
        attendingUidList.add(uid);
      }
      if (declinedUidList.contains(uid)) {
        declinedUidList.remove(uid);
      }
      await eventRef.doc(event.eventId).update(
          {'declinedUids': declinedUidList, 'attendingUids': attendingUidList});
      Utils.showToastWithoutContext('Attending'.tr());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future updateDeclinedUidList(Event event , String uid) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {

      List<String> declinedUidList = event.declinedUids;
      List<String> attendingUidList = event.attendingUids;

      if(declinedUidList.contains(uid)){
        declinedUidList.remove(uid);
        await eventRef.doc(event.eventId).update(
            {'declinedUids': declinedUidList, 'attendingUids': attendingUidList});
        return;
      }
      if (attendingUidList.contains(uid)) {
        attendingUidList.remove(uid);
      }
      if (!declinedUidList.contains(uid)) {
        declinedUidList.add(uid);
      }
      await eventRef.doc(event.eventId).update(
          {'declinedUids': declinedUidList, 'attendingUids': attendingUidList});
      Utils.showToastWithoutContext('Declined'.tr());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future deleteEvent(String eventId, BuildContext context) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    Utils.showToast(context, 'Deleting please wait...'.tr());
    try {
      await FirebaseStorage.instance
          .ref()
          .child('eventPics')
          .child('$eventId')
          .delete();
      await eventRef.doc(eventId).delete();
      Utils.showToast(context, 'Deleted'.tr());
      Navigator.pop(context);
    } catch (err) {
      Utils.showErrorToast();
    }
  }

  Future createEventChat(String eventId, String uid, String message) async {
    try {
      final messageId = Uuid().v1().toString();
      final createdAt = DateTime.now();
      final eventChat = EventChat(
          messageId: messageId,
          eventId: eventId,
          uid: uid,
          message: message,
          createdAt: createdAt);

      DocumentReference docRef = eventRef.doc(eventId);
      DocumentSnapshot docSnapshot = await docRef.get();
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
      int totalComment=docData['commentCount'];
      int newTotalComment=totalComment+1;
      docRef.update({
        'commentCount':newTotalComment
      });

      final eventChatRef = Configuration.isProduction
          ? FirebaseFirestore.instance
              .collection('eventChats/$eventId/messages')
          : FirebaseFirestore.instance
              .collection('eventChats_test/$eventId/messages');
      eventChatRef.doc(messageId).set(eventChat.toMap());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  List<EventChat> _eventChatFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return EventChat.fromMap(doc.data());
    }).toList();
  }

  ///streams event chat
  Stream<List<EventChat>> getEventChats(String eventId) {
    return Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('eventChats/$eventId/messages')
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map(_eventChatFromSnapShot)
        : FirebaseFirestore.instance
            .collection('eventChats_test/$eventId/messages')
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map(_eventChatFromSnapShot);
  }


  Future updateExternalUserList(String eventId,String guestId,String name,String surname,String email) async{
    final externalUser=ExternalUser(guestId: guestId, name: name, surname: surname, email: email);
    DocumentReference docRef = eventRef.doc(eventId);
    DocumentSnapshot docSnapshot = await docRef.get();
    Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> externalUsers =
    (docData["externalUsers"] as List<dynamic>)
        .map((organization) => Map<String, dynamic>.from(organization))
        .toList();
    externalUsers.add(externalUser.toMap());

    docRef.update({'externalUsers':externalUsers});
  }

  Future<void> removeAttendStatus(Event event,String guestId) async {
    final externalUsers=event.externalUsers;
    externalUsers.removeWhere((element) => element.guestId==guestId);
    eventRef.doc(event.eventId).update({'externalUsers':externalUsers});
  }



}
