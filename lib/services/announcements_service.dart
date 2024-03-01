import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/announcement.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class AnnouncementService {


   CollectionReference<Map<String, dynamic>> refAnnouncements=Configuration.isProduction
       ? FirebaseFirestore.instance.collection('announcements')
       : FirebaseFirestore.instance.collection('announcements_test');

   StreamController<List<DocumentSnapshot<Map<String, dynamic>>>>
   streamController =
   StreamController<List<DocumentSnapshot<Map<String, dynamic>>>>();

   List<DocumentSnapshot<Map<String, dynamic>>> _announcements = [];


   bool _isRequesting = false;
   bool _isFinish = false;
   bool isFirstRequest=true;
   int firstRequestIndex=0;

  ///creates an announcement with the given organization id
  Future createAnnouncement(
      String announcement,
      String announcementTitle,
      String organizationId,
      String createdBy,
      int priority,
      BuildContext context,
      List<String> toWho,
      String creatorUid
      ) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      String announcementId = Uuid().v1().toString();
      DateTime createdAt = DateTime.now();
      refAnnouncements.doc(announcementId).set({
        'announcementId': announcementId,
        'announcementTitle': announcementTitle,
        'announcement': announcement,
        'createdAt': createdAt,
        'updatedAt': createdAt,
        'organizationId': organizationId,
        'createdBy': createdBy,
        'priority': priority,
        'toWho': toWho,
        'seenBy': [],
        'documentUrl':'',
        'creatorUid':creatorUid
      });
      Navigator.pop(context);
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  ///gets all the announcements for organization
  Stream<List<Announcement>> getOrganizationAnnouncements(String orgId) {
    final stream=refAnnouncements
        .where('organizationId', isEqualTo: orgId)
        .orderBy('createdAt', descending: true)

        .snapshots()
        .map((organizations) {
      return organizations.docs.map((organization) {
        return Announcement.fromMap(organization.data());
      }).toList();
    });
    return stream;
  }
 
  
   void requestNextPage(String organizationId) async {
    print('anc length is ${_announcements.length}');
     streamController.stream.map((event) => null);
     if (!_isRequesting && ! _isFinish) {
       QuerySnapshot querySnapshot;
       _isRequesting = true;
       if (_announcements.isEmpty) {
         querySnapshot = await refAnnouncements
             .where('organizationId', isEqualTo: organizationId)
             .orderBy('createdAt', descending: true)
             .limit(4)
             .get();
       } else {
         querySnapshot = await refAnnouncements
             .where('organizationId', isEqualTo: organizationId)
             .orderBy('createdAt', descending: true)
             .startAfterDocument(_announcements[_announcements.length - 1])
             .limit(4)
             .get();
       }

       if (querySnapshot != null) {
         int oldSize = _announcements.length;
         querySnapshot.docs.forEach((element) {
           _announcements.add(element as DocumentSnapshot<Map<String, dynamic>>);
         });

         int newSize = _announcements.length;
         if (oldSize != newSize) {
           streamController.add(_announcements);
         }else {
           _isFinish = true;
         }
       }
       _isRequesting = false;


     }

   }
   void onChangeData(List<DocumentChange> documentChanges) {
    print('listening');
     var isChange = false;
     documentChanges.forEach((productChange) {
       if (productChange.type == DocumentChangeType.removed) {
         //print('listening to removed changes');
         _announcements.removeWhere((product) {
           return productChange.doc.id == product.id;
         });
         isChange = true;
       } else if (productChange.type == DocumentChangeType.added) {
         print(productChange.doc.id);
         print(firstRequestIndex);
         if (productChange.newIndex <_announcements.length) {
           print(firstRequestIndex);
           print('new index ${productChange.newIndex}');
           print('length  ${_announcements.length}');
           print(productChange.doc.id);
           _announcements.add(productChange.doc as DocumentSnapshot<Map<String, dynamic>>);
         }
         if(firstRequestIndex==1 && _announcements.length==0){
           print('listens to first create');
           _announcements.add(productChange.doc as DocumentSnapshot<Map<String, dynamic>>);
         }
         isChange = true;
       } else {
         if (productChange.type == DocumentChangeType.modified) {
           //print('listening to modified changes');
           int indexWhere = _announcements.indexWhere((product) {
             return productChange.doc.id == product.id;
           });
           if (indexWhere >= 0) {
             _announcements[indexWhere] =
             productChange.doc as DocumentSnapshot<Map<String, dynamic>>;
           }
           isChange = true;
         }
       }
     });

     if (isChange) {
       streamController.add(_announcements);
     }
   }

   void listenToChanges(String orgId) {
     refAnnouncements
         .where('organizationId', isEqualTo: orgId)
         .orderBy('createdAt', descending: true)
         .snapshots().listen((event) {onChangeData(event.docChanges);});

   }




  ///updates an announcement
  Future updateAnnouncement(
      String announcementId,
      String announcement,
      String announcementTitle,
      int priority,
      BuildContext context,
      List<String> toWho) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }

    try {
      refAnnouncements.doc(announcementId).update({
        'announcement': announcement,
        'announcementTitle': announcementTitle,
        'priority': priority,
        'toWho': toWho,
        'seenBy': []
      });
      Navigator.pop(context);
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  //deletes an announcement
  Future deleteAnnouncement(String announcementId) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      refAnnouncements.doc(announcementId).delete();
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  /// updates an announcements seenBy field by adding current user to seenBy list.
  Future updateSeenByForUser(Announcement announcement, String uid) async {
    try {

      final seenByList=announcement.seenBy;
      if (!seenByList.contains(uid)) {
        seenByList.add(uid);
      }
      refAnnouncements.doc(announcement.announcementId).update({'seenBy': seenByList});
    } catch (e) {
      Utils.showErrorToast();
    }
  }
}
