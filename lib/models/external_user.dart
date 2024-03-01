class ExternalUser{
  final String guestId;
  final String name;
  final String surname;
  final String email;

  const ExternalUser({
    required this.guestId,
    required this.name,
    required this.surname,
    required this.email,
  });


  Map<String, dynamic> toMap() {
    return {
      'guestId': this.guestId,
      'name': this.name,
      'surname': this.surname,
      'email': this.email,
    };
  }

  factory ExternalUser.fromMap(Map<String, dynamic> map) {
    return ExternalUser(
      guestId: map['guestId'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      email: map['email'] as String,
    );
  }
}