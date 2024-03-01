

class Room{
  final String companyId;
  final String roomId;
  final String roomCapacity;
  final String roomSize;
  final String roomName;
  final String roomUrl;
  final List<String> amenities;
  final String createdBy;
  const Room({
    required this.companyId,
    required this.roomId,
    required this.roomCapacity,
    required this.roomSize,
    required this.roomName,
    required this.roomUrl,
    required this.amenities,
    required this.createdBy
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': this.companyId,
      'roomId': this.roomId,
      'roomCapacity': this.roomCapacity,
      'roomSize': this.roomSize,
      'roomName': this.roomName,
      'roomUrl': this.roomUrl,
      'amenities': this.amenities,
      'createdBy':this.createdBy
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      companyId: map['companyId'] as String,
      roomId: map['roomId'] as String,
      roomCapacity: map['roomCapacity'] as String,
      roomSize: map['roomSize'] as String,
      roomName: map['roomName'] as String,
      roomUrl: map['roomUrl'] as String,
      amenities: List.castFrom(map['amenities']),
      createdBy: map['createdBy']==null?'':map['createdBy']
    );
  }
}