class AdminRegistry{
  final String organizationId;
  final bool isApproved;

  const AdminRegistry({
    required this.organizationId,
    required this.isApproved,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationId': this.organizationId,
      'isApproved': this.isApproved,
    };
  }

  factory AdminRegistry.fromMap(Map<String, dynamic> map) {
    return AdminRegistry(
      organizationId: map['organizationId'] as String,
      isApproved: map['isApproved'] as bool,
    );
  }
}