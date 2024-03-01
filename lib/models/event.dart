import 'package:firebase_calendar/models/external_user.dart';
import 'package:firebase_calendar/shared/utils.dart';

class Event{
  final String eventId;
  final String organizationId;
  final String createdByUid;
  final String eventName;
  final DateTime eventDate;
  final DateTime eventStartTime;
  final DateTime eventEndTime;
  final String eventUrl;
  final String eventAddress;
  final String eventInformation;
  final List<String> toWho;
  final List<String> attendingUids;
  final List<String> declinedUids;
  final int commentCount;
  final bool isPublic;
  final List<ExternalUser> externalUsers;
  final String organizationName;
  final String category;
  final String city;
  final Coordinates? coordinates;

  Map<String, dynamic> toMap() {
    return {
      'eventId': this.eventId,
      'organizationId': this.organizationId,
      'createdByUid': this.createdByUid,
      'eventName': this.eventName,
      'eventDate': this.eventDate,
      'eventStartTime': this.eventStartTime,
      'eventEndTime': this.eventEndTime,
      'eventUrl': this.eventUrl,
      'eventAddress': this.eventAddress,
      'eventInformation': this.eventInformation,
      'toWho':this.toWho,
      'attendingUids': this.attendingUids,
      'declinedUids': this.declinedUids,
      'commentCount':this.commentCount,
      'isPublic':this.isPublic,
      'externalUsers': this.externalUsers.map((e) => e.toMap()).toList(),
      'organizationName':this.organizationName,
      'category':this.category,
      'city':this.city,
      'coordinates':this.coordinates?.toMap()
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    final List<ExternalUser> externalUsers=[];

    List externalUserMap=map['externalUsers'];
    externalUserMap.forEach((element) {
      ExternalUser externalUser=ExternalUser.fromMap(element as Map<String, dynamic>);
      externalUsers.add(externalUser);
    });
    return Event(
      eventId: map['eventId'] as String,
      organizationId: map['organizationId'] as String,
      createdByUid: map['createdByUid'] as String,
      eventName: map['eventName'] as String,
      eventDate: Utils.toDateTime(map['eventDate']),
      eventStartTime:  Utils.toDateTime(map['eventStartTime']),
      eventEndTime:  Utils.toDateTime(map['eventEndTime']),
      eventUrl: map['eventUrl'] as String,
      eventAddress: map['eventAddress'] as String,
      eventInformation: map['eventInformation'] as String,
      toWho: List.castFrom(map['toWho']),
      attendingUids: List.castFrom(map['attendingUids']),
      declinedUids: List.castFrom(map['declinedUids']),
      commentCount: map['commentCount'],
      isPublic: map['isPublic'],
      externalUsers: externalUsers,
      organizationName: map['organizationName'],
      category: map['category'],
      city: map['city'],
      coordinates: map['coordinates']==null?Coordinates(lat: 0.0, long: 0.0)
          :Coordinates.fromMap(map['coordinates'])
    );
  }

  const Event({
    required this.eventId,
    required this.organizationId,
    required this.createdByUid,
    required this.eventName,
    required this.eventDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventUrl,
    required this.eventAddress,
    required this.eventInformation,
    required this.toWho,
    required this.attendingUids,
    required this.declinedUids,
    required this.commentCount,
    required this.isPublic,
    required this.externalUsers,
    required this.organizationName,
    required this.category,
    required this.city,
    this.coordinates
  });
}

class Coordinates{
  final double lat;
  final double long;

  const Coordinates({
    required this.lat,
    required this.long,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': this.lat,
      'long': this.long,
    };
  }

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      lat: map['lat'] as double,
      long: map['long'] as double,
    );
  }
}