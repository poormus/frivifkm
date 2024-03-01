import 'package:firebase_calendar/models/admin_registry.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/user_companies.dart';

// final String Users='users';
//
// class UserFields{
//   static final String uid='id';
//   static final String email='email';
//   static  final String userName='userName';
//   static final String userSurname='userSurname';
//   static final String userOrganizations='userOrganizations';
//   static final String currentOrganizationId='currentOrganizationId';
//   static final String userPhone='userPhone';
//   static final String userUrl='userUrl';
//   static final String groupIds='groupIds';
//   static final String adminRegistry='adminRegistry';
//   static final String  totalPoint='totalPoint';
//
//   static final List<String> values = [
//     uid,
//     email,
//     userSurname,
//     userSurname,
//     userOrganizations,
//     currentOrganizationId,
//     userPhone,
//     userUrl,
//     groupIds,
//     adminRegistry,
//     totalPoint
//   ];
// }

class CurrentUserData {
  final String uid;
  final String email;
  final String userName;
  final String userSurname;
  final List<UserOrganizations> userOrganizations;
  final String currentOrganizationId;
  final String userPhone;
  final String userUrl;
  final List<String> groupIds;
  final List<AdminRegistry> adminRegistry;
  final int totalPoint;
  final bool? isAdmin;
  const CurrentUserData(
      {required this.uid,
      required this.email,
      required this.userName,
      required this.userSurname,
      required this.userOrganizations,
      required this.currentOrganizationId,
      required this.userPhone,
      required this.userUrl,
      required this.groupIds,
      required this.adminRegistry,
      required this.totalPoint,
      this.isAdmin});

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'email': this.email,
      'userName': this.userName,
      'userSurname': this.userSurname,
      'userOrganizations':
          this.userOrganizations.map((e) => e.toMap()).toList(),
      'currentOrganizationId': this.currentOrganizationId,
      'userPhone': this.userPhone,
      'userUrl': this.userUrl,
      'groupIds': this.groupIds,
      'adminRegistry': this.adminRegistry.map((e) => e.toMap()).toList(),
      'totalPoint': this.totalPoint
    };
  }

  factory CurrentUserData.fromMap(Map<String, dynamic> map) {
    final List<UserOrganizations> org = [];
    final List<AdminRegistry> registry = [];
    List adminRegistryMap = map['adminRegistry'];
    adminRegistryMap.forEach((element) {
      AdminRegistry adminRegistry =
          AdminRegistry.fromMap(element as Map<String, dynamic>);
      registry.add(adminRegistry);
    });
    List organizationsMap = map['userOrganizations'];
    organizationsMap.forEach((element) {
      UserOrganizations organization =
          UserOrganizations.fromMap(element as Map<String, dynamic>);
      org.add(organization);
    });
    return CurrentUserData(
        uid: map['uid'] as String,
        email: map['email'] as String,
        userName: map['userName'] as String,
        userSurname: map['userSurname'] as String,
        userOrganizations: org,
        currentOrganizationId: map['currentOrganizationId'],
        userPhone: map['userPhone'],
        userUrl: map['userUrl'] as String,
        groupIds: List.castFrom(map['groupIds']),
        adminRegistry: registry,
        totalPoint: map['totalPoint'],
        isAdmin: map['isAdmin'] == null ? null : map['isAdmin']);
  }
}
