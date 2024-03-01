import 'package:firebase_calendar/models/admin_registry.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/user_companies.dart';

final String Users='users';

class UserFields{
  static final String uid='uid';
  static final String email='email';
  static  final String userName='userName';
  static final String userSurname='userSurname';
  static final String currentOrganizationId='currentOrganizationId';
  static final String userPhone='userPhone';
  static final String userUrl='userUrl';
  static final String  totalPoint='totalPoint';

  static final List<String> values = [
    uid,
    email,
    userSurname,
    userSurname,
    currentOrganizationId,
    userPhone,
    userUrl,
    totalPoint
  ];
}

class CurrentUserDataDb{
  final String uid;
  final String email;
  final String userName;
  final String userSurname;
  final String currentOrganizationId;
  final String userPhone;
  final String userUrl;
  final int totalPoint;

  const CurrentUserDataDb(  {
    required this.uid,
    required this.email,
    required this.userName,
    required this.userSurname,
    required this.currentOrganizationId,
    required this.userPhone,
    required this.userUrl,
    required this.totalPoint
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'email': this.email,
      'userName': this.userName,
      'userSurname': this.userSurname,
      'currentOrganizationId':this.currentOrganizationId,
      'userPhone':this.userPhone,
      'userUrl': this.userUrl,
      'totalPoint':this.totalPoint
    };
  }

  factory CurrentUserDataDb.fromMap(Map<String, dynamic> map) {
    return CurrentUserDataDb(
      uid: map['uid'] as String,
      email: map['email'] as String,
      userName: map['userName'] as String,
      userSurname: map['userSurname'] as String,
      currentOrganizationId: map['currentOrganizationId'],
      userPhone: map['userPhone'],
      userUrl: map['userUrl'] as String,
      totalPoint: map['totalPoint']
    );
  }
}