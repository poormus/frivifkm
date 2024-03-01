import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/announcement.dart';
import 'package:firebase_calendar/shared/my_provider.dart';

class AnnouncementServicePaginated {
  final refAnnouncements = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('announcements')
      : FirebaseFirestore.instance.collection('announcements_test');
  final groupRef = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('groups')
      : FirebaseFirestore.instance.collection('groups_test');

  StreamController<List<DocumentSnapshot<Map<String, dynamic>>>>
      streamController =
      StreamController<List<DocumentSnapshot<Map<String, dynamic>>>>();

  List<DocumentSnapshot<Map<String, dynamic>>> _announcements = [];
  MyProvider provider = MyProvider();

  bool _isRequesting = false;
  bool _isFinish = false;

  void requestNextPage(String organizationId) async {
    streamController.stream.map((event) => null);
    if (!_isRequesting) {
      QuerySnapshot querySnapshot;
      _isRequesting = true;
      if (_announcements.isEmpty) {
        querySnapshot = await refAnnouncements
            .where('organizationId', isEqualTo: organizationId)
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();
      } else {
        querySnapshot = await refAnnouncements
            .where('organizationId', isEqualTo: organizationId)
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_announcements[_announcements.length - 1])
            .limit(5)
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
        }
      }
      _isRequesting = false;
    }
  }

  void onChangeData(List<DocumentChange> documentChanges) {
    var isChange = false;
    documentChanges.forEach((productChange) {
      if (productChange.type == DocumentChangeType.removed) {
        _announcements.removeWhere((product) {
          return productChange.doc.id == product.id;
        });
        isChange = true;
      } else if (productChange.type == DocumentChangeType.added) {
        if (productChange.newIndex == productChange.oldIndex) {
          _announcements.add(productChange.doc as DocumentSnapshot<Map<String, dynamic>>);
        }
        isChange = true;
      } else {
        if (productChange.type == DocumentChangeType.modified) {
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

  //gets all the announcements for organization
  Stream<List<Announcement>> getOrganizationAnnouncements(String orgId) {
    return refAnnouncements
        .where('organizationId', isEqualTo: orgId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((organizations) {
      return organizations.docs.map((organization) {
        return Announcement.fromMap(organization.data());
      }).toList();
    });
  }


  void dispose(){
    streamController.close();
  }

}
