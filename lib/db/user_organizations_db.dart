


final String Organizations='organizations';

class UserOrgFields{
  static final String userId='userId';
  static final String organizationId='organizationId';
  static  final String organizationName='organizationName';
  static final String organizationUrl='organizationUrl';
  static final String isApproved='isApproved';
  static final String userRole='userRole';


  static final List<String> values = [
    userId,
    organizationId,
    organizationName,
    organizationUrl,
    isApproved,
    userRole
  ];
}

class UserOrganizationsDb {
  final String uid;
  final String organizationId;
  final String organizationName;
  final String organizationUrl;
  final bool isApproved;
  final String userRole;


  const UserOrganizationsDb({
    required this.uid,
    required this.organizationId,
    required this.organizationName,
    required this.organizationUrl,
    required this.isApproved,
    required this.userRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid':this.uid,
      'organizationId': this.organizationId,
      'organizationName': this.organizationName,
      'organizationUrl': this.organizationUrl,
      'isApproved': this.isApproved,
      'userRole': this.userRole,
    };
  }

  factory UserOrganizationsDb.fromMap(Map<String, dynamic> map) {
    return UserOrganizationsDb(
        uid: map['uid'],
        organizationId: map['organizationId'] as String,
        organizationName: map['organizationName'] as String,
        organizationUrl: map['organizationUrl'] as String,
        isApproved: map['isApproved'] as bool,
        userRole: map['userRole'] as String,
    );
  }
}
