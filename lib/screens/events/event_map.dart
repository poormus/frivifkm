/* import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/helper/marker.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:core';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../shared/constants.dart';
import '../../shared/navigation.dart';
import '../../shared/utils.dart';

class EventMap extends StatefulWidget {
  final List<Event> events;
  final Coordinates coordinate;
  final String guestId;

  const EventMap(
      {Key? key,
      required this.events,
      required this.coordinate,
      required this.guestId})
      : super(key: key);

  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  Completer<GoogleMapController> _controller = Completer();

  double _pinPillPosition = -300;
  String selectedEventId = '';
  late CameraPosition city;
  late MyProvider provider;
  late BitmapDescriptor customIcon;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Set<Marker> _markers = <Marker>{};

  Map<String, GlobalKey> keyMap = {};

  void generateGlobalKeyMap() {
    widget.events.forEach((element) {
      keyMap.putIfAbsent(element.eventId, () => new GlobalKey());
    });
  }

  Event getEventFromId() {
    return widget.events.firstWhere(
        (element) => element.eventId == selectedEventId,
        orElse: () => Constants.EVENT_HOLDER);
  }

  Widget getMapBody(size) {
    return Stack(
      children: [
        for (var i in widget.events)
          MyMarker(
              keyMap[i.eventId]!,
              provider.organizationsForValidation
                  .singleWhere(
                    (element) => element.organizationId == i.organizationId,
                    orElse: () => Constants.ORG_HOLDER,
                  )
                  .organizationUrl),
        GoogleMap(
          onTap: (lat) {
            setState(() {
              _pinPillPosition = -300;
            });
          },
          markers: _markers,
          mapType: MapType.normal,
          initialCameraPosition: city,
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedCustomButton(
                  text: 'See events',
                  press: addMarkers,
                  color: Constants.BUTTON_COLOR)),
        ),
        AnimatedBox(
            pillPosition: _pinPillPosition,
            size: size,
            event: getEventFromId(),
            guestId: widget.guestId)
      ],
    );
  }

  addMarkers() async {
    for (var i in widget.events) {
      _markers.add(Marker(
        onTap: () {
          setState(() {
            _pinPillPosition = 50;
            selectedEventId = i.eventId;
          });
        },
        markerId: MarkerId(i.eventId),
        icon: await MarkerIcon.widgetToIcon(keyMap[i.eventId]!),
        position: LatLng(i.coordinates!.lat, i.coordinates!.long),
      ));
    }

    setState(() {});
  }

  @override
  void initState() {
    provider = Provider.of<MyProvider>(context, listen: false);
    city = CameraPosition(
        target: LatLng(widget.coordinate.lat, widget.coordinate.long),
        tilt: 10,
        zoom: 13);
    // _add(provider);
    generateGlobalKeyMap();

    super.initState();
  }

  @override
  void dispose() {
    _controller.future.then((value) => value.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: getMapBody(size),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: Platform.isIOS ? 90.0 : 40.0, left: 25),
        child: Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton(
            child: Icon(Icons.arrow_back),
            backgroundColor: Constants.BUTTON_COLOR,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class AnimatedBox extends StatelessWidget {
  final double pillPosition;
  final Size size;
  final Event event;
  final String guestId;
  const AnimatedBox(
      {Key? key,
      required this.pillPosition,
      required this.size,
      required this.event,
      required this.guestId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: pillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => Navigation.navigateToEventDetail(context, '1', event, '',
              Constants.CURRENT_USER_HOLDER, '', guestId),
          child: Container(
            margin: EdgeInsets.all(20),
            height: 270,
            width: size.width * 0.86,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5),
                  )
                ]),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      height: 150,
                      width: size.width * 0.82,
                      imageUrl: event.eventUrl,
                      placeholder: (context, url) =>
                          Align(child: new CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    )),
                Container(
                    width: size.width * 0.8,
                    child: Text(
                      event.eventName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Container(
                    width: size.width * 0.8,
                    child: Text(event.eventInformation)),
                SizedBox(height: 5),
                Container(
                    width: size.width * 0.8,
                    child: Text(
                        '${Utils.toDateTranslated(event.eventDate, context)}-${Utils.toTime(event.eventStartTime)}')),
                InkWell(
                  onTap: () => Navigation.navigateToEventDetail(context, '1',
                      event, '', Constants.CURRENT_USER_HOLDER, '', guestId),
                  child: Text('Learn more'.tr(),
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */