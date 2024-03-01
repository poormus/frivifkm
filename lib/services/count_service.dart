import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/models/badge_count.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../config/key_config.dart';

class CountService {
  final String organizationId;

  CountService({
    required this.organizationId,
  });

  late CollectionReference<Map<String, dynamic>> countRef;

  init() {
    countRef = Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('counts/${organizationId}/count')
        : FirebaseFirestore.instance
            .collection('counts_test/${organizationId}/count');
  }

  Stream<BadgeCount> getBadgeCount(String uid) {
    return countRef
        .doc(uid)
        .snapshots()
        .map((event) => BadgeCount.fromMap(event.data()!));
  }

  void resetCountForAnnouncement(String uid) {
    countRef.doc(uid).update({'announcementCount': 0});
  }

  void resetCountForMessages(String uid) {
    countRef.doc(uid).update({
      'messageCount': 0,
      'groupChatCount': 0,
    });
  }

  void resetCountForPoll(String uid) {
    countRef.doc(uid).update({'pollCount': 0});
  }

  void resetCountForSurvey(String uid) {
    countRef.doc(uid).update({'surveyCount': 0});
  }

  updateAnnouncementCountOnCreateAnnouncement(
      MyProvider provider, List<String> toWho) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        annCount = badgeCount
                .where((element) => element.uid == user.uid)
                .first
                .announcementCount +
            1;
      }
      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'announcementCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 1,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'announcementCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 1,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      }
    });
  }

  updateAnnouncementCountOnUpdateAnnouncement(
      MyProvider provider, List<String> toWho, List<String> seenBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        if (seenBy.contains(user.uid)) {
          annCount = badgeCount
                  .where((element) => element.uid == user.uid)
                  .first
                  .announcementCount +
              1;
        } else {
          annCount = badgeCount
              .where((element) => element.uid == user.uid)
              .first
              .announcementCount;
        }
      }

      if (annCount <= 0) {
        annCount = 0;
      }
      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'announcementCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 1,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'announcementCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 1,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      }
    });
  }

  updateAnnouncementCountOnSeenByUser(String uid, ItemType type) async {
    return;
    switch (type) {
      case ItemType.ANNOUNCEMENT:
        final countDoc = await countRef.doc(uid).get();
        int annCount =
            BadgeCount.fromMap(countDoc.data()!).announcementCount - 1;
        if (annCount <= 0) {
          annCount = 0;
        }
        countRef.doc(uid).update({'announcementCount': annCount});
        break;
      case ItemType.POLL:
        final countDoc = await countRef.doc(uid).get();
        int annCount = BadgeCount.fromMap(countDoc.data()!).pollCount - 1;
        if (annCount <= 0) {
          annCount = 0;
        }
        countRef.doc(uid).update({'pollCount': annCount});
        break;
      case ItemType.SURVEY:
        final countDoc = await countRef.doc(uid).get();
        int annCount = BadgeCount.fromMap(countDoc.data()!).surveyCount - 1;
        if (annCount <= 0) {
          annCount = 0;
        }
        countRef.doc(uid).update({'surveyCount': annCount});
        break;

      case ItemType.TASK:
        // TODO: Handle this case.
        break;
    }
  }

  updateAnnouncementCountOnDeleteAnnouncement(
      MyProvider provider, List<String> toWho, List<String> seenBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        if (seenBy.contains(user.uid)) {
          annCount = badgeCount
              .where((element) => element.uid == user.uid)
              .first
              .announcementCount;
        } else {
          annCount = badgeCount
                  .where((element) => element.uid == user.uid)
                  .first
                  .announcementCount -
              1;
        }
      }

      if (annCount <= 0) {
        annCount = 0;
      }

      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'announcementCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'announcementCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      }
    });
  }

  updateMessageCountOnReceived(String uid, int messageCount) async {
    final countDoc = await countRef.doc(uid).get();

    int newMessageCount = 0;
    if (countDoc.exists) {
      final count = BadgeCount.fromMap(countDoc.data()!).messageCount;
      newMessageCount = messageCount + count;
    }

    if (countDoc.exists) {
      countRef.doc(uid).update({'messageCount': newMessageCount});
    } else {
      countRef.doc(uid).set({
        'uid': uid,
        'announcementCount': 0,
        'messageCount': messageCount,
        'groupChatCount': 0,
        'surveyCount': 0,
        'pollCount': 0
      });
    }
  }

  updateMessageCountOnRead(String uid, int messageCount) async {
    return;
    final countDoc = await countRef.doc(uid).get();
    final oldCount = BadgeCount.fromMap(countDoc.data()!).messageCount;
    int newCount = oldCount - messageCount;
    if (newCount <= 0) {
      newCount = 0;
    }
    countRef.doc(uid).update({'messageCount': newCount});
  }

  updateMessageCountOnDelete(String uid, int messageCount) async {
    return;
    final countDoc = await countRef.doc(uid).get();
    final oldCount = BadgeCount.fromMap(countDoc.data()!).messageCount;
    int newCount = oldCount - messageCount;
    if (newCount <= 0) {
      newCount = 0;
    }
    countRef.doc(uid).update({'messageCount': newCount});
  }

  updateGroupMessageCountOnReceived(String uid, int messageCount) async {
    final countDoc = await countRef.doc(uid).get();
    int newMessageCount = 0;
    if (countDoc.exists) {
      final count = BadgeCount.fromMap(countDoc.data()!).groupChatCount;
      newMessageCount = messageCount + count;
      print('count $count');
      print('exist ${newMessageCount}');
    }
    print('new message count $newMessageCount');

    if (countDoc.exists) {
      countRef.doc(uid).update({'groupChatCount': newMessageCount});
    } else {
      countRef.doc(uid).set({
        'uid': uid,
        'announcementCount': 0,
        'messageCount': 0,
        'groupChatCount': messageCount,
        'surveyCount': 0,
        'pollCount': 0
      });
    }
  }

  updateGroupMessageCountOnRead(String uid, int messageCount) async {
    return;
    final countDoc = await countRef.doc(uid).get();
    final oldCount = BadgeCount.fromMap(countDoc.data()!).groupChatCount;
    int newCount = oldCount - messageCount;
    if (newCount <= 0) {
      newCount = 0;
    }
    print('new count on group message read ${newCount}');
    countRef.doc(uid).update({'groupChatCount': newCount});
  }

  updateGroupMessageCountOnDelete(String uid, int messageCount) async {
    return;
    final countDoc = await countRef.doc(uid).get();
    final oldCount = BadgeCount.fromMap(countDoc.data()!).groupChatCount;
    int newCount = oldCount - messageCount;
    if (newCount <= 0) {
      newCount = 0;
    }
    print('new count on group message read ${newCount}');
    countRef.doc(uid).update({'groupChatCount': newCount});
  }

  //poll counts.....

  updatePollCountOnCreatePoll(MyProvider provider, List<String> toWho) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        annCount = badgeCount
                .where((element) => element.uid == user.uid)
                .first
                .pollCount +
            1;
      }
      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 1
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 1
          });
        }
      }
    });
  }

  updatePollCountOnUpdatePoll(
      MyProvider provider, List<String> toWho, List<String> seenBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        if (seenBy.contains(user.uid)) {
          annCount = badgeCount
                  .where((element) => element.uid == user.uid)
                  .first
                  .pollCount +
              1;
        } else {
          annCount = badgeCount
              .where((element) => element.uid == user.uid)
              .first
              .pollCount;
        }
      }

      if (annCount <= 0) {
        annCount = 0;
      }
      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 1
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 1
          });
        }
      }
    });
  }

  updatePollCountOnDeletePoll(
      MyProvider provider, List<String> toWho, List<String> seenBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        if (seenBy.contains(user.uid)) {
          annCount = badgeCount
              .where((element) => element.uid == user.uid)
              .first
              .pollCount;
        } else {
          annCount = badgeCount
                  .where((element) => element.uid == user.uid)
                  .first
                  .pollCount -
              1;
        }
      }

      if (annCount <= 0) {
        annCount = 0;
      }

      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      }
    });
  }

  //survey counts...

  updateSurveyCountOnCreateSurvey(
      MyProvider provider, List<String> toWho) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        annCount = badgeCount
                .where((element) => element.uid == user.uid)
                .first
                .surveyCount +
            1;
      }
      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'surveyCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 1,
            'pollCount': 0
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'surveyCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 1,
            'pollCount': 0
          });
        }
      }
    });
  }

  updateSurveyCountOnUpdateSurvey(
      MyProvider provider, List<String> toWho, List<String> seenBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        if (seenBy.contains(user.uid)) {
          annCount = badgeCount
                  .where((element) => element.uid == user.uid)
                  .first
                  .pollCount +
              1;
        } else {
          annCount = badgeCount
              .where((element) => element.uid == user.uid)
              .first
              .pollCount;
        }
      }

      if (annCount <= 0) {
        annCount = 0;
      }
      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 1
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'pollCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 1
          });
        }
      }
    });
  }

  updateSurveyCountOnDeleteSurvey(
      MyProvider provider, List<String> toWho, List<String> seenBy) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final countDocs = await countRef.get();
    final badgeCount =
        countDocs.docs.map((e) => BadgeCount.fromMap(e.data())).toList();
    final userList = provider.allUsersOfOrganization;
    userList.forEach((user) {
      bool isExist = false;
      int annCount = 0;
      final userBadgeCount =
          badgeCount.where((element) => element.uid == user.uid);
      if (userBadgeCount.isNotEmpty) {
        isExist = true;
        if (seenBy.contains(user.uid)) {
          annCount = badgeCount
              .where((element) => element.uid == user.uid)
              .first
              .surveyCount;
        } else {
          annCount = badgeCount
                  .where((element) => element.uid == user.uid)
                  .first
                  .surveyCount -
              1;
        }
      }

      if (annCount <= 0) {
        annCount = 0;
      }

      final userRole =
          Utils.getUserRole(user.userOrganizations, organizationId);
      if (userRole == '3' || userRole == '4') {
        if (isExist) {
          countRef.doc(user.uid).update({'surveyCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      } else if (toWho.contains(userRole) ||
          user.groupIds.toSet().intersection(toWho.toSet()).length != 0) {
        if (isExist) {
          countRef.doc(user.uid).update({'surveyCount': annCount});
        } else {
          countRef.doc(user.uid).set({
            'uid': user.uid,
            'announcementCount': 0,
            'messageCount': 0,
            'groupChatCount': 0,
            'surveyCount': 0,
            'pollCount': 0
          });
        }
      }
    });
  }
}

enum ItemType { ANNOUNCEMENT, POLL, SURVEY, TASK }
