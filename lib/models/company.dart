class Organization {
  final String organizationId;
  final String organizationName;
  final String organizationUrl;
  final List<String> admins;
  final String organizationNumber;
  final bool isApproved;
  final int currentUserCount;
  final int targetUserCount;
  final String subLevel;
  final List<String> blockedUsers;
  final String about;
  final String contactPerson;
  final String ePost;
  final String mobil;
  final String address;
  final String website;

  const Organization(
      {required this.organizationId,
      required this.organizationName,
      required this.organizationUrl,
      required this.admins,
      required this.organizationNumber,
      required this.isApproved,
      required this.currentUserCount,
      required this.targetUserCount,
      required this.subLevel,
      required this.blockedUsers,
      required this.about,
      required this.contactPerson,
      required this.ePost,
      required this.mobil,
      required this.address,
      required this.website});

  Map<String, dynamic> toMap() {
    return {
      'organizationId': this.organizationId,
      'organizationName': this.organizationName,
      'organizationUrl': this.organizationUrl,
      'admins': this.admins,
      'organizationNumber': this.organizationNumber,
      'isApproved': this.isApproved,
      'currentUserCount': this.currentUserCount,
      'targetUserCount': this.targetUserCount,
      'subLevel': this.subLevel,
      'blockedUsers': this.blockedUsers,
      'about': this.about,
      'contactPerson': this.contactPerson,
      'ePost': this.ePost,
      'mobil': this.mobil,
      'address': this.address,
      'website': this.website
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
        organizationId: map['organizationId'] as String,
        organizationName: map['organizationName'] as String,
        organizationUrl: map['organizationUrl'] as String,
        admins: List.castFrom(map['admins']),
        organizationNumber: map['organizationNumber'],
        isApproved: map['isApproved'],
        currentUserCount: map['currentUserCount'],
        targetUserCount: map['targetUserCount'],
        subLevel: map['subLevel'],
        blockedUsers: List.castFrom(map['blockedUsers']),
        about: map['about'] == null ? '' : map['about'],
        address: map['address'] == null ? '' : map['address'],
        contactPerson: map['contactPerson'] ?? '',
        ePost: map['ePost'] ?? '',
        mobil: map['mobil'] ?? '',
        website: map['website'] ?? '');
  }
}
