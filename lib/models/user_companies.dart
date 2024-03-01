class UserOrganizations {
  final String organizationId;
  final String organizationName;
  final String organizationUrl;
  final bool isApproved;
  final String userRole;


  const UserOrganizations({
    required this.organizationId,
    required this.organizationName,
    required this.organizationUrl,
    required this.isApproved,
    required this.userRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationId': this.organizationId,
      'organizationName': this.organizationName,
      'organizationUrl': this.organizationUrl,
      'isApproved': this.isApproved,
      'userRole': this.userRole,
    };
  }

  factory UserOrganizations.fromMap(Map<String, dynamic> map) {
    return UserOrganizations(
        organizationId: map['organizationId'] as String,
        organizationName: map['organizationName'] as String,
        organizationUrl: map['organizationUrl'] as String,
        isApproved: map['isApproved'] as bool,
        userRole: map['userRole'] as String,

    );
  }
}
